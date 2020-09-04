import 'package:MTGMoe/util/order.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/model/mtg_set.dart';
import 'package:MTGMoe/util/filter.dart';

class MTGDB {
  static Future<Database> get _database => _openDB();
  static Database database;

  static CardFilter _filter = CardFilter();
  static CardOrder _order = CardOrder(type1: OrderType.DATE_DESC, type2: OrderType.RARITY_DESC, type3: OrderType.NUMBER_ASC);

  static List<MTGCard> _cards;
  static List<MTGSet> _sets;

  static Future<List<MTGCard>> loadCards({CardFilter filter, CardOrder order}) async {
    if (_cards==null || (filter!=null && _filter!=filter) || (order!=null && _order!=order)) {
      print("refreshing cards");
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
      _cards = maps.map((e) => MTGCard.fromMap(e)).toList();
      print("refreshed cards");
      return _cards;
    }
    else {
      return _cards;
    }
  }

  static Future<List<MTGSet>> loadSets() async {
    if (_sets==null) {
      final Database db = await _database;
      final List<Map<String, dynamic>> maps = await db.query('mtg_sets');
      _sets = maps.map((e) => MTGSet.fromMap(e)).toList();
    }
    return _sets;
  }

  static Future<void> saveCards(List<MTGCard> cards) async {
    _cards = null;
    final Database db = await _database;
    await db.transaction((txn) {
      for(MTGCard card in cards) {
        txn.insert('mtg_cards', card.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return;
    });
  }

  static Future<void> saveSets(List<MTGSet> sets) async {
    _sets = null;
    final Database db = await _database;
    await db.transaction((txn) {
      for(MTGSet set in sets) {
        txn.insert('mtg_sets', set.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      return;
    });
  }

  static Future<List<Map<String, dynamic>>> createCardQuery(Database db, CardFilter filter, CardOrder order) async {
    String where = '1=1';
    List<String> whereArgs = List<String>();
    if ((filter.name??'')!='') {
      where = where + ' AND c.name LIKE ?' ;
      whereArgs.add("%${filter.name}%");
    }
    if ((filter.set??'')!='') {
      where = where + ' AND c.cardSet = ?' ;
      whereArgs.add(filter.set);
    }
    if ((filter.type??'')!='') {
      where = where + ' AND c.types LIKE ?' ;
      whereArgs.add("%${filter.type}%");
    }
    if ((filter.subtype??'')!='') {
      where = where + ' AND c.types LIKE ?' ;
      whereArgs.add("%${filter.subtype}%");
    }
    if (filter.rarities!=null && (filter.rarities.length>0 && filter.rarities.length<4)) {
      where = where + ' AND c.rarity in (?)' ;
      whereArgs.add(filter.rarities?.map((e) => MTGCard.rarityFromString(e))?.join(',')??'');
    }
    if (filter.colors!=null) {
      for (String color in ['B', 'G', 'R', 'U', 'W']) {
        switch(filter.colorMatch) {
          case ColorMatch.EXACT:
            where = where + ' AND c.colorIdentity ' + (filter.colors.contains(color) ? '' : 'NOT ') + 'LIKE ?' ;
            whereArgs.add("%$color%");
            break;
          case ColorMatch.MAX:
            if (!filter.colors.contains(color)) {
              where = where + ' AND c.colorIdentity NOT LIKE ?' ;
              whereArgs.add("%$color%");
            }
            break;
          case ColorMatch.MIN:
            if (filter.colors.contains(color)) {
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
      where = where + ' AND c.oracleText LIKE ?' ;
      whereArgs.add("%${filter.text}%");
    }
    String orderBy;
    orderBy = _addOrder(orderBy, order.type1);
    orderBy = _addOrder(orderBy, order.type2);
    orderBy = _addOrder(orderBy, order.type3);
    if (orderBy==null)
      orderBy = "s.releasedAt DESC, c.rarity DESC";
    return db.rawQuery('SELECT c.*, s.releasedAt FROM mtg_cards c LEFT JOIN mtg_sets s on c.cardSet=s.code WHERE '+where+' ORDER BY '+orderBy, whereArgs);
  }

  static String _addOrder(String order, OrderType type) {
    switch(type) {
      case OrderType.DATE_ASC:
        return (order==null ? '' : order + ', ') + "s.releasedAt ASC";
      case OrderType.DATE_DESC:
        return (order==null ? '' : order + ', ') + "s.releasedAt DESC";
      case OrderType.NAME_ASC:
        return (order==null ? '' : order + ', ') + "c.name ASC";
      case OrderType.NAME_DESC:
        return (order==null ? '' : order + ', ') + "c.name DESC";
      case OrderType.RARITY_ASC:
        return (order==null ? '' : order + ', ') + "c.rarity ASC";
      case OrderType.RARITY_DESC:
        return (order==null ? '' : order + ', ') + "c.rarity DESC";
      case OrderType.CMC_ASC:
        return (order==null ? '' : order + ', ') + "c.cmc ASC";
      case OrderType.CMC_DESC:
        return (order==null ? '' : order + ', ') + "c.cmc DESC";
      case OrderType.NUMBER_ASC:
        return (order==null ? '' : order + ', ') + "c.collectorNumber ASC";
      case OrderType.NUMBER_DESC:
        return (order==null ? '' : order + ', ') + "c.collectorNumber DESC";
      case OrderType.NONE:
        return order;
      default:
        throw Exception("Illegal OrderType");
    }
  }

  static void closeDB() {
    if (database!=null && database.isOpen)
      database.close();
  }

  static Future<Database> _openDB() async {
    if (database!=null && database.isOpen)
      return database;
    return openDatabase(
        join(await getDatabasesPath(), 'mtg_moe_database.db'),
      version: 1,
      onCreate: (db, version) {
          print('creating tables');
          return db.transaction((txn) async {
            txn.execute('''
              CREATE TABLE mtg_sets(
                code TEXT PRIMARY KEY,
                name TEXT,
                cardCount INTEGER,
                setType TEXT,
                releasedAt TEXT,
                blockCode TEXT,
                block TEXT,
                iconScvURI TEXT,
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
                cardSet TEXT,
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
                cardFace1_types TEXT
              );
            ''');
          });
      }
    );
  }

}