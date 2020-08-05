import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/model/mtg_set.dart';

class MTGDB {
  static Future<Database> get _database => _initDB();

  static Future<Iterable<MTGCard>> loadCards() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('mtg_cards');
    final Iterable<MTGCard> cards = maps.map((e) => MTGCard.fromMap(e));
    return cards;
  }

  static Future<Iterable<MTGSet>> loadSets() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('mtg_sets');
    final Iterable<MTGSet> sets = maps.map((e) => MTGSet.fromMap(e));
    return sets;
  }

  static void saveCards(List<MTGCard> cards) async {
    //print('started saveCards for ${cards.length} cards');
    final Database db = await _database;
    await db.transaction((txn) async {
      for(MTGCard card in cards) {
        txn.insert('mtg_cards', card.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    //print('finished saveCards for ${cards.length} cards');
  }

  static void saveSets(List<MTGSet> sets) async {
    //print('started saveSets for ${sets.length} sets');
    final Database db = await _database;
    await db.transaction((txn) async {
      for(MTGSet set in sets) {
        txn.insert('mtg_sets', set.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    //print('finished saveSets for ${sets.length} sets');
  }

  static void initDB() {
    _database;
  }

  static Future<Database> _initDB() async {
    return openDatabase(
        join(await getDatabasesPath(), 'mtg_moe_database.db'),
      version: 1,
      onCreate: (db, version) {
          print('creaing tables');
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
                searchURI TEXT
              );
            ''');
            txn.execute('''
              CREATE TABLE mtg_cards(
                id TEXT PRIMARY KEY,
                multiverseId0 INTEGER,
                multiverseId1 INTEGER,
                oracleId TEXT,
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
                typeLine TEXT,
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
                rarity TEXT,
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
                cardFace0_typeLine TEXT,
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
                cardFace1_typeLine TEXT
              );
            ''');
          });
      }
    );
  }

}