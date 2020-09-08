import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/routes/card_info.dart';
import 'package:MTGMoe/util/card_image.dart';

Widget cardTabContent(List<List<String>> cardIdNameList) {
  List<String> cardIdList = cardIdNameList.map((e) => e[0]).toList();
  List<String> cardNameList = cardIdNameList.map((e) => e[1]).toList();
  if (cardIdList != null && cardIdList.length > 0) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        childAspectRatio: 488.0 / 680.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index < cardIdList.length) {
            return MaterialButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CardInfo(cardId: cardIdList[index], cardName: cardNameList[index]),
                    settings: RouteSettings()
                  )
                );
              },
              child: cardImages(cardIdList[index], cardNameList[index], 1),
            );
          }
          else {
            return null;
          }
        },
        childCount: cardIdList.length,
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

Widget cardImages(String cardId, String cardName, int num) {
  return FutureBuilder(
    future: getImages(cardId, num),
    builder: (context, snapshot) {
      if (!snapshot.hasError) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Image> images = (snapshot.data as List<Image>);
          if (images.length>1) {
            return Row(
              children: [
                Expanded(
                  child: images[0],
                ),
                Expanded(
                  child: images[1],
                ),
              ],
            );
          }
          else {
            return images[0];
          }
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset('images/card_back.png');
        }
      }
      print(snapshot.error);
      return Center(
        child: Text(cardName),
      );
    },
  );
}