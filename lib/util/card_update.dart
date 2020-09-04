import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/model/mtg_set.dart';
import 'package:MTGMoe/mtg_db.dart';

Stream<Map<String, Object>> updateSets(AppStateModel model) async* {
  final response = await http.get("https://api.scryfall.com/sets/");
  if (response.statusCode == 200) {
    var rootJson = jsonDecode(response.body);
    var setListJson = rootJson['data'] as List;
    List<MTGSet> savedSets = await MTGDB.loadSets();
    List<MTGSet> sets = setListJson.map((e) => MTGSet.fromJson(e)).toList();
    for(var i=0; i<sets.length; i++) {
      MTGSet set = sets[i];
      if (!set.digital && !savedSets.any((s) => s.code==set.code)) {
        Map<String, Object> streamValue = { 'set' : set.name, 'progress': (i+1) / sets.length };
        yield streamValue;
        print('adding ${set.name}\n');
        sleep(Duration(milliseconds: 50));
        if (await updateCards(model, set.searchURI))
          await MTGDB.saveSets([set]);
        model.update();
        if (!model.doUpdate) {
          yield { 'set': '_cancelled_' };
          return;
        }
      }
    }
    yield { 'set': '_finished_' };
  }
  else {
    yield { 'set': '_error_', 'error': response.statusCode };
  }
}

Future<bool> updateCards(AppStateModel model, String searchURI) async {
  bool hasMore = true;
  String uri = searchURI;
  List<MTGCard> cards = [];
  while(hasMore) {
    hasMore = false;
    if (!model.doUpdate)
      return false;
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var rootJson = jsonDecode(response.body);
      var cardListJson = rootJson['data'] as List;
      int totalCards = rootJson['total_cards'] as int;
      var cardListPart = cardListJson.map((e) => MTGCard.fromJson(e)).toList();
      cards.addAll(cardListPart);
      print('${cards.length}/$totalCards');
      if (rootJson['has_more'] as bool) {
        hasMore = true;
        uri = rootJson['next_page'] as String;
        sleep(Duration(milliseconds: 50));
      }
    }
    else {
      print(response.statusCode);
    }
  }
  await MTGDB.saveCards(cards);
  return true;
}