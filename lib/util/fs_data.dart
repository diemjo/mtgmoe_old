import 'dart:io';

import 'package:MTGMoe/mtg_db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<int> fsGetDatabaseSize() async {
  final File dbFile = File(join(await getDatabasesPath(), 'mtg_moe_database.db'));
  if (dbFile.existsSync())
    return dbFile.lengthSync();
  else
    return 0;
}

Future<int> fsGetImagesSize() async {
  final Directory imageDir = Directory(join((await getApplicationDocumentsDirectory()).path, 'images', ));
  if (imageDir.existsSync()) {
    int count = 0;
    await imageDir.list(recursive: true).forEach((element) {
      count += element.statSync().size;
    });
    return count;
  }
  return 0;
}

Future<void> deleteDatabaseData() async {
  final File dbFile = File(join(await getDatabasesPath(), 'mtg_moe_database.db'));
  dbFile.deleteSync();
  MTGDB.invalidate();
}

Future<void> deleteImagesData() async {
  final Directory imageDir = Directory(join((await getApplicationDocumentsDirectory()).path, 'images'));
  await imageDir.delete(recursive: true);
}