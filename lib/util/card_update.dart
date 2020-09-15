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
  CancelToken cancelToken = CancelToken();

  model.cancelToken = cancelToken;
  Response bulkResponse = await dio.get('https://api.scryfall.com/bulk-data/default_cards', cancelToken: cancelToken);
  if (bulkResponse.statusCode != 200) {
    return {'status': 'error', 'error': '${bulkResponse.statusCode}: ${bulkResponse.statusMessage}'};
  }
  final downloadURI = bulkResponse.data['download_uri'] as String;
  if (!model.doUpdate) {
    return {'status': 'cancel'};
  }
  model.updateStatus = UpdateStatus.DOWNLOADING;
  model.updateProgress = 0;
  model.update();
  Response<ResponseBody> response;
  try {
    response = await dio.get(downloadURI, cancelToken: cancelToken, options: Options(responseType: ResponseType.stream),
        onReceiveProgress: (current, total) {
      model.bytesFromDownload = current;
      print(model.bytesFromDownload);
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
  List<MTGCard> cards = [];
  Future dbop = Future.delayed(Duration.zero);
  Function reviver = (key, value) {
    //print('$key: $value');
    if (value is Map<String, dynamic> && value['object']=='card') {
      //print(value);
      cards.add(MTGCard.fromJson(value));
      final currentCards = cards;
      if (currentCards.length>=500) {
        dbop = dbop.then((_) {
          if (model.doUpdate)
            MTGDB.saveCards(currentCards).then((_) {
              model.updateProgress += currentCards.length;
              model.update();
            });
        });
        cards = [];
      }
      return null;
    }
    return value;
  };
  Completer completer = Completer();
  response.data.stream.cast<List<int>>().transform(utf8.decoder).transform(JsonDecoder(reviver)).listen(null , onDone: () {
    if(!completer.isCompleted)
      completer.complete(null);
  }, onError: (e) {
    if(!completer.isCompleted)
      completer.complete(e);
  });
  final error = await completer.future;
  await dbop;
  await MTGDB.saveCards(cards);
  if (model.updateProgress!=null) {
    model.updateProgress += cards.length;
    model.update();
  }
  print('settings status to idle');
  model.updateStatus = UpdateStatus.IDLE;
  model.update();
  if (error==null) {
    return {'status': 'success'};
  }
  else {
    return {'status': 'error', 'error': error.toString()};
  }

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

/*class JsonTransformer extends DefaultTransformer {

  @override
  Future transformResponse(RequestOptions options, ResponseBody response) {
    if (options.responseType!=ResponseType.json)
      return super.transformResponse(options, response);
    return JsonDecoder().bind(utf8.decoder.bind(response.stream)).first;
  }
}*/