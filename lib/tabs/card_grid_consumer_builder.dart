import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/moe_style.dart';

Widget cardTabContent(List<MTGCard> cardList) {
  if (cardList != null && cardList.length > 0) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 488.0 / 680.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index < cardList.length) {
            return _cardImage(cardList[index]);
          }
          else {
            return null;
          }
        },
        childCount: cardList.length,
      ),
    );
  }
  else {
    return SliverToBoxAdapter(
      child: Center(
        heightFactor: 5,
        child: Text(
          'No cards matching filter or \n'
              'no cards in local database\n'
              ' (update cards in the settings tab)',
          style: MoeStyle.defaultText,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

Widget _cardImage(MTGCard card) {
  return FutureBuilder(
    future: getImage(card),
    builder: (context, snapshot) {
      if (!snapshot.hasError) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data as Image;
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset('images/card_back.png');
        }
      }
      return Center(
        child: Text(card.name),
      );
    },
  );
}

Future<Image> getImage(MTGCard card) async {
  final String path = (await getApplicationDocumentsDirectory()).path;
  File imageFile = File('$path/images/${card.id}.png');
  if (imageFile.existsSync()) {
    return Image.file(imageFile, fit: BoxFit.fitWidth);
  }
  else {
    http.Response response = await http.get(card.imageURIs.png);
    if (response.statusCode==200) {
      imageFile.createSync(recursive: true);
      imageFile.writeAsBytes(response.bodyBytes);
      return Image.memory(response.bodyBytes, fit: BoxFit.fitWidth);
    }
    else {
      return Image.asset('images/card_back.png', fit: BoxFit.fitWidth);
    }
  }
}