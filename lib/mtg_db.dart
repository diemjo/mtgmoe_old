import 'dart:async';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mtgmoe/model/filter.dart';
import 'package:mtgmoe/model/order.dart';
import 'package:mtgmoe/model/card/mtg_card.dart';
import 'package:mtgmoe/model/card/mtg_set.dart';

class MTGDB {
  static Future<Database> get _database => _openDB();

  static CardFilter _filter = CardFilter();
  static CardOrder _order = CardOrder(OrderType.DATE_DESC, OrderType.RARITY_DESC, OrderType.NUMBER_ASC, OrderType.CMC_DESC, OrderType.NAME_ASC);

  static List<List<String?>>? _cards;
  static List<MTGSet>? _sets;

  static void invalidate() {
    _cards = null;
    _sets = null;
  }

  static Future<void> closeDB() async {
    Database db = await _database;
    return db.close();
  }

  static Future<List<List<String?>>?> loadCardIds({CardFilter? filter, CardOrder? order}) async {
    if (_cards==null || (filter!=null && _filter!=filter) || (order!=null && _order!=order)) {
      _cards = null;
      if (order != null) {
        _order = new CardOrder.fromOrder(order);
      }
      if (filter != null) {
        _filter = new CardFilter.fromFilter(filter);
      }
      Database db = await _database;
      List<Map<String, dynamic>> maps = await createCardQuery(db, _filter, _order);
      print(maps.length);
      _cards = maps.map((e) => [e['id'] as String, e['name'] as String]).toList();
      return _cards;
    }
    else {
      return _cards;
    }
  }

  static Future<MTGCard?> loadCard(String? id) async {
    Database db = await _database;
    List<Map<String, dynamic>> maps = await db.query('mtg_cards', where: 'id = ?', whereArgs: [id]);
    if (maps.length>0) {
      return MTGCard.fromMap(maps[0]);
    }
    else
      return null;
  }

  static Future<List<MTGSet>?> loadSets() async {
    if (_sets==null) {
      final Database db = await _database;
      final List<Map<String, dynamic>> maps = await db.query('mtg_sets');
      _sets = maps.map((e) => MTGSet.fromMap(e)).toList();
    }
    return _sets;
  }

  static Future<List<String?>> loadSetTypes() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('mtg_sets', columns: ['setType'], groupBy: 'setType', distinct: true);
    return maps.map((e) => e['setType'] as String?).toList(growable: false);
  }

  static Future<MTGSet> setFromCode(String? code) async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('mtg_sets', where: 'setCode = ?', whereArgs: [code], limit: 1);
    return MTGSet.fromMap(maps.first);
  }

  static Future<void> saveCards(List<MTGCard> cards) async {
    _cards = null;
    final Database db = await _database;
    await db.transaction((txn) async {
      for(MTGCard card in cards) {
        txn.insert('mtg_cards', card.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<void> saveSets(List<MTGSet> sets) async {
    _sets = null;
    final Database db = await _database;
    await db.transaction((txn) async {
      for(MTGSet set in sets) {
        txn.insert('mtg_sets', set.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> createCardQuery(Database db, CardFilter filter, CardOrder order) async {
    String where = '1=1';
    List<String?> whereArgs = <String?>[];
    if ((filter.name??'')!='') {
      where = where + ' AND c.name LIKE ?' ;
      whereArgs.add("%${filter.name}%");
    }
    if ((filter.set??'')!='') {
      where = where + ' AND s.setName LIKE ?' ;
      whereArgs.add('%${filter.set}%');
    }
    if ((filter.type??'')!='') {
      where = where + ' AND c.types LIKE ?' ;
      whereArgs.add("%${filter.type}%");
    }
    if ((filter.subtype??'')!='') {
      where = where + ' AND c.subtypes LIKE ?' ;
      whereArgs.add("%${filter.subtype}%");
    }
    if (filter.rarities!=null && filter.rarities!.length<4) {
      where = where + ' AND c.rarity in (${filter.rarities?.map((e) => '?').join(',')??''})' ;
      whereArgs.addAll(filter.rarities?.map((e) => MTGCard.rarityFromString(e).toString()).toList()??<String?>[]);
    }
    if (filter.colors!=null) {
      for (String color in ['B', 'G', 'R', 'U', 'W']) {
        switch(filter.colorMatch) {
          case ColorMatch.EXACT:
            where = where + ' AND c.colorIdentity ' + (filter.colors!.contains(color) ? '' : 'NOT ') + 'LIKE ?' ;
            whereArgs.add("%$color%");
            break;
          case ColorMatch.MAX:
            if (!filter.colors!.contains(color)) {
              where = where + ' AND c.colorIdentity NOT LIKE ?' ;
              whereArgs.add("%$color%");
            }
            break;
          case ColorMatch.MIN:
            if (filter.colors!.contains(color)) {
              where = where + ' AND c.colorIdentity LIKE ?' ;
              whereArgs.add("%$color%");
            }
            break;
        }
      }
    }
    if ((filter.power??'')!='') {
      where = where + ' AND c.power = ?' ;
      whereArgs.add(filter.power);
    }
    if ((filter.toughness??'')!='') {
      where = where + ' AND c.toughness = ?' ;
      whereArgs.add(filter.toughness);
    }
    if ((filter.text??'')!='') {
      for (String word in filter.text!.split(' ')) {
        where = where + ' AND c.oracleText LIKE ?';
        whereArgs.add("%$word%");
      }
    }
    List<dynamic> setTypes = await _setTypeFilter();
    where = where + setTypes[0];
    whereArgs.addAll(setTypes[1]);
    String orderBy = order.types!.map((e) => CardOrder.typeToSqlString(e)).join(',');
    return db.rawQuery('SELECT c.id, c.name FROM mtg_cards c LEFT JOIN mtg_sets s on c.setCode=s.setCode WHERE '+where+' ORDER BY '+orderBy, whereArgs);
  }

  static Future<Iterable<String>> loadTypeNames(String _pattern) async {
    if (_pattern.length < 1)
      return [];
    String pattern = _pattern.toLowerCase();
    Database db = await _database;
    String where = 'c.types LIKE ?';
    List<String> whereArgs = ["%$pattern%"];
    List<dynamic> setTypes = await _setTypeFilter();
    where = where + setTypes[0];
    whereArgs.addAll(setTypes[1]);
    List<Map<String,dynamic>> maps = await db.rawQuery('SELECT DISTINCT c.types FROM mtg_cards c LEFT JOIN mtg_sets s on c.setCode=s.setCode WHERE '+where, whereArgs);
    Iterable<List<String>> types = maps.map((e) => (e['types'] as String).split(' '));
    Iterable<String> matchingTypes = types.expand((element) => element)
        .where((element) => element!='' && element!='//' && element.toLowerCase().contains(pattern))
        .toSet()
        .toList(growable: false);
    return matchingTypes;
  }

  static Future<List<String>> loadSubtypeNames(String _pattern) async {
    if (_pattern.length < 1)
      return [];
    String pattern = _pattern.toLowerCase();
    Database db = await _database;
    String where = 'c.subtypes LIKE ?';
    List<String> whereArgs = ["%$pattern%"];
    List<dynamic> setTypes = await _setTypeFilter();
    where = where + setTypes[0];
    whereArgs.addAll(setTypes[1]);
    List<Map<String,dynamic>> maps = await db.rawQuery('SELECT DISTINCT c.subtypes FROM mtg_cards c LEFT JOIN mtg_sets s on c.setCode=s.setCode WHERE '+where, whereArgs);
    Iterable<List<String>> types = maps.map((e) => (e['subtypes'] as String).split(' '));
    Iterable<String> matchingTypes = types.expand((element) => element)
        .where((element) => element!='' && element!='//' && element.toLowerCase().contains(pattern))
        .toSet()
        .toList(growable: false);
    return matchingTypes as FutureOr<List<String>>;
  }

  static Future<List<String?>> loadNames(String _pattern) async {
    if (_pattern.length < 1)
      return [];
    String pattern = _pattern.toLowerCase();
    Database db = await _database;
    String where = 'c.name LIKE ?';
    List<String> whereArgs = ["%$pattern%"];
    List<dynamic> setTypes = await _setTypeFilter();
    where = where + setTypes[0];
    whereArgs.addAll(setTypes[1]);
    List<Map<String,dynamic>> maps = await db.rawQuery('SELECT DISTINCT c.name FROM mtg_cards c LEFT JOIN mtg_sets s on c.setCode=s.setCode WHERE '+where, whereArgs);
    return maps.map((e) => (e['name'] as String?)).toList(growable: false);
  }

  static Future<List<String?>> loadSetNames(String _pattern) async {
    if (_pattern.length < 1)
      return [];
    String pattern = _pattern.toLowerCase();
    Database db = await _database;
    String where = 'setName LIKE ?';
    List<String> whereArgs = ["%$pattern%"];
    List<dynamic> setTypes = await _setTypeFilter();
    where = where + (setTypes[0] as String);
    whereArgs.addAll(setTypes[1] as List<String>);
    List<Map<String,dynamic>> maps = await db.query('mtg_sets', columns: ['setName'] ,where: where, whereArgs: whereArgs, distinct: true);
    return maps.map((e) => (e['setName'] as String?)).toList(growable: false);
  }

  static Future<List<dynamic>> _setTypeFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String?> allSetTypes = await loadSetTypes();
    Iterable<String?> enabledSetTypes = allSetTypes.where((element) => prefs.containsKey('set_type_$element') && prefs.getBool('set_type_$element')!);
    String where = ' AND setType IN (${enabledSetTypes.map((e) => '?').join(',')})';
    List<String?> whereArgs = enabledSetTypes.toList(growable: false);
    return [where, whereArgs];
  }

  static Future<Database> _openDB() async {
    return openDatabase(
        join(await getDatabasesPath(), 'mtg_moe_database.db'),
      version: 1,
      onCreate: (db, version) {
          print('creating tables');
          return db.transaction((txn) async {
            txn.execute('''
              CREATE TABLE mtg_sets(
                setCode TEXT PRIMARY KEY,
                setName TEXT,
                cardCount INTEGER,
                setType TEXT,
                releasedAt TEXT,
                blockCode TEXT,
                block TEXT,
                iconSvgURI TEXT,
                searchURI TEXT,
                digital INTEGER
              );
            ''');
            txn.execute('''
              CREATE TABLE mtg_cards(
                id TEXT PRIMARY KEY,
                multiverseId0 INTEGER,
                multiverseId1 INTEGER,
                oracleId TEXT,
                collectorNumber TEXT,
                cmc REAL,
                manaCost TEXT,
                colorIdentity TEXT,
                keywords TEXT,
                layout TEXT,
                name TEXT,
                oracleText TEXT,
                power TEXT,
                toughness TEXT,
                loyalty TEXT,
                types TEXT,
                subtypes TEXT,
                fullArt INTEGER,
                imageURI_png TEXT,
                imageURI_borderCrop TEXT,
                imageURI_artCrop TEXT,
                imageURI_large TEXT,
                imageURI_normal TEXT,
                imageURI_small TEXT,
                price_usd TEXT,
                price_usdFoil TEXT,
                price_eur TEXT,
                rarity INTEGER,
                setCode TEXT,
                setName TEXT,
                legalities_standard TEXT,
                legalities_future TEXT,
                legalities_historic TEXT,
                legalities_pioneer TEXT,
                legalities_modern TEXT,
                legalities_legacy TEXT,
                legalities_pauper TEXT,
                legalities_vintage TEXT,
                legalities_penny TEXT,
                legalities_commander TEXT,
                legalities_brawl TEXT,
                legalities_duel TEXT,
                legalities_oldschool TEXT,
                rulingsURI TEXT,
                scryfallURI TEXT,
                cardFace0_colorIdentity TEXT,
                cardFace0_manaCost TEXT,
                cardFace0_imageURI_png TEXT,
                cardFace0_imageURI_borderCrop TEXT,
                cardFace0_imageURI_artCrop TEXT,
                cardFace0_imageURI_large TEXT,
                cardFace0_imageURI_normal TEXT,
                cardFace0_imageURI_small TEXT,
                cardFace0_loyalty TEXT,
                cardFace0_name TEXT,
                cardFace0_oracleText TEXT,
                cardFace0_power TEXT,
                cardFace0_toughness TEXT,
                cardFace0_types TEXT,
                cardFace0_subtypes TEXT,
                cardFace1_colorIdentity TEXT,
                cardFace1_manaCost TEXT,
                cardFace1_imageURI_png TEXT,
                cardFace1_imageURI_borderCrop TEXT,
                cardFace1_imageURI_artCrop TEXT,
                cardFace1_imageURI_large TEXT,
                cardFace1_imageURI_normal TEXT,
                cardFace1_imageURI_small TEXT,
                cardFace1_loyalty TEXT,
                cardFace1_name TEXT,
                cardFace1_oracleText TEXT,
                cardFace1_power TEXT,
                cardFace1_toughness TEXT,
                cardFace1_types TEXT,
                cardFace1_subtypes TEXT
              );
            ''');
          });
      }
    );
  }

}