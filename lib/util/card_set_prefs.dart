import 'package:MTGMoe/mtg_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, bool>> getSetTypeMap() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> setTypes = await MTGDB.loadSetTypes();
  return Map.fromIterable(setTypes, key: (element) => element, value: (element) => prefs.containsKey(element) ? prefs.getBool(element) : false);
}