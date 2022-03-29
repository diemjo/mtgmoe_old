import 'package:mtgmoe/mtg_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String?, bool?>> getPrefsSetTypes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String?> setTypes = await MTGDB.loadSetTypes();
  Map<String?, bool?> map = Map.fromIterable(setTypes, key: (element) => element, value: (element) => prefs.containsKey('set_type_$element') ? prefs.getBool('set_type_$element') : false);
  return map;
}

Future<void> setPrefsSetType(String key, bool val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('set_type_$key', val);
  MTGDB.invalidate();
}