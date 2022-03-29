import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:mtgmoe/mtg_db.dart';
import 'package:mtgmoe/model/card/mtg_card.dart';

Future<List<Image?>> getImages(String? cardId, int num) async {
  MTGCard? card = await (MTGDB.loadCard(cardId) as Future<MTGCard?>);
  if (card==null)
    return [];
  final String path = (await getApplicationDocumentsDirectory()).path;
  if ((card.cardFaces?.length??0)>1 && card.cardFaces![0].imageURIs?.png!=null) {
    File imageFile0 = File('$path/images/${cardId}_0.png');
    Image? img0, img1;
    if(imageFile0.existsSync())
      img0 = Image.file(imageFile0, fit: BoxFit.contain);
    else
      img0 = await _imageFromUrl(imageFile0, card.cardFaces![0].imageURIs?.png);
    if (num>1) {
      File imageFile1 = File('$path/images/${cardId}_1.png');
      if (imageFile1.existsSync())
        img1 = Image.file(imageFile1, fit: BoxFit.contain);
      else
        img1 = await _imageFromUrl(imageFile1, card.cardFaces![1].imageURIs?.png);
      return [img0, img1];
    }
    else {
      return [img0];
    }
  }
  else {
    File imageFile = File('$path/images/$cardId.png');
    if (imageFile.existsSync()) {
      return [Image.file(imageFile, fit: BoxFit.contain)];
    }
    else {
      return [await _imageFromUrl(imageFile, card.imageURIs!.png)];
    }
  }
}

Future<Image?> _imageFromUrl(File imageFile, String? url) async {
  if (url==null)
    return null;
  http.Response response = await http.get(Uri.parse(url));
  if (response.statusCode==200) {
    imageFile.createSync(recursive: true);
    imageFile.writeAsBytes(response.bodyBytes);
    return Image.memory(response.bodyBytes);
  }
  else {
    print(response.statusCode);
    return Image.asset('images/card_back.png');
  }
}