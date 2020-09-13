import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/model/card/mtg_set.dart';
import 'package:MTGMoe/model/card/mtg_card.dart';

Future<Map<String, dynamic>> updateCards(AppStateModel model) async {
  model.updateStatus = UpdateStatus.INITIALIZING;
  model.update();
  int setStatus = await _updateSets();
  if (setStatus!=200) {
    return {'status': 'error', 'error': '$setStatus: set update failed'};
  }
  Dio dio = Dio(BaseOptions(connectTimeout: 5000));
  dio.transformer = JsonTransformer();
  CancelToken cancelToken = CancelToken();

  model.cancelToken = cancelToken;
  Response bulkResponse = await dio.get('https://api.scryfall.com/bulk-data/default_cards', cancelToken: cancelToken);
  if (bulkResponse.statusCode != 200) {
    return {'status': 'error', 'error': '${bulkResponse.statusCode}: ${bulkResponse.statusMessage}'};
  }
  final downloadURI = bulkResponse.data['download_uri'] as String;
  Response response;
  if (!model.doUpdate) {
    return {'status': 'cancel'};
  }
  model.updateStatus = UpdateStatus.DOWNLOADING;
  model.updateProgress = 0;
  model.update();
  try {
    response = await dio.get(downloadURI, cancelToken: cancelToken, onReceiveProgress: (current, total) {
      model.bytesFromDownload = current;
      model.update();
      if (!model.doUpdate) {
        cancelToken.cancel();
      }
    });
  } on DioError catch (e) {
    print(e);
    return {'status': 'error', 'error': e.message};
  }
  if (!model.doUpdate) {
    return {'status': 'cancel'};
  }
  model.updateStatus = UpdateStatus.STORING;
  model.updateProgress = 0;
  model.update();
  List<dynamic> cards = response.data;
  List<MTGCard> cardSubset = [];
  int progress = 0;
  int saved = 0;
  int total = cards.length;
  while (cards.isNotEmpty) {
    Map<String, dynamic> last = cards.removeLast();
    cardSubset.add(MTGCard.fromJson(last));
    if (cardSubset.length>=75) {
      await MTGDB.saveCards(cardSubset);
      saved += cardSubset.length;
      if (progress<(100.0*saved/total).floor()) {
        progress = (100.0*saved/total).floor();
        model.updateProgress = progress;
        model.update();
      }
      cardSubset.clear();
      if (!model.doUpdate) {
        return {'status': 'cancel'};
      }
    }
  }
  await MTGDB.saveCards(cardSubset);
  model.updateStatus = UpdateStatus.IDLE;
  model.cancelToken = null;
  model.update();
  return {'status': 'success'};
  /*List<Map<String, dynamic>> data = jsonDecode(response.data);
  int len = data.length;
  if (len>0) {
    print(MTGCard.fromJson(data[0]).toMap());
  }
  for (int i=0; i<len; i+=100) {
    List<MTGCard> cards = [];
    for (int j=0; j<100 && i+j<len; j++) {
      cards.add(MTGCard.fromJson(data[i+j]));
    }
    MTGDB.saveCards(cards);
    print('saved: ${(i+100) < len ? i+100 : len}/$len');
  }*/

  /*final response = await http.get("https://api.scryfall.com/sets/");
  if (response.statusCode == 200) {
    var rootJson = jsonDecode(response.body);
    var setListJson = rootJson['data'] as List;
    List<MTGSet> savedSets = await MTGDB.loadSets();
    List<MTGSet> sets = setListJson.map((e) => MTGSet.fromJson(e)).toList();
    for(var i=0; i<sets.length; i++) {
      MTGSet set = sets[i];
      if (!set.digital && !savedSets.any((s) => s.code==set.code)) {
        Map<String, Object> streamValue = { 'set' : set.name, 'progress': (i+1) / sets.length };
        model.updateSet = set.name;
        model.updateProgress = (i+1)/sets.length;
        yield streamValue;
        //print('adding ${set.name}\n');
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
    model.updateSet = '';
    yield { 'set': '_finished_' };
  }
  else {
    yield { 'set': '_error_', 'error': response.statusCode };
  }*/
}

Future<int> _updateSets() async {
  final response = await http.get("https://api.scryfall.com/sets/");
  if (response.statusCode == 200) {
    var rootJson = jsonDecode(response.body);
    var setListJson = rootJson['data'] as List;
    //List<MTGSet> savedSets = await MTGDB.loadSets();
    List<MTGSet> sets = setListJson.map((e) => MTGSet.fromJson(e)).toList();
    await MTGDB.saveSets(sets);
  }
  else {
    print('update sets error: ${response.statusCode}');
  }
  return response.statusCode;
}

/*Future<bool> updateCards(AppStateModel model, String searchURI) async {
  bool hasMore = true;
  String uri = searchURI;
  List<MTGCard> cards = [];
  Stopwatch sw = Stopwatch();
  sw.start();
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
  sw.stop();
  print('updateCards(${cards.length}): ${sw.elapsedMilliseconds}ms');
  return true;
}
*/

class JsonTransformer extends DefaultTransformer {

  @override
  Future transformResponse(RequestOptions options, ResponseBody response) {
    if (options.responseType!=ResponseType.json)
      return super.transformResponse(options, response);
    return JsonDecoder().bind(utf8.decoder.bind(response.stream)).first;
  }
}