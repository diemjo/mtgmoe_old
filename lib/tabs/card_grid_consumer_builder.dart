import 'package:mtgmoe/dialogs/image_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mtgmoe/moe_style.dart';
import 'package:mtgmoe/routes/card_info.dart';
import 'package:mtgmoe/util/card_image.dart';

Widget cardTabContent(List<List<String>> cardIdNameList) {
  List<String> cardIdList = cardIdNameList.map((e) => e[0]).toList();
  List<String> cardNameList = cardIdNameList.map((e) => e[1]).toList();
  if (cardIdList.length > 0) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 3.0,
        crossAxisSpacing: 3.0,
        childAspectRatio: 488.0 / 680.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index < cardIdList.length) {
            return MaterialButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => CardInfo(cardId: cardIdList[index], cardName: cardNameList[index]),
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

Widget cardImages(String? cardId, String? cardName, int num,{bool withDialog=false}) {
  return FutureBuilder(
    future: getImages(cardId, num),
    builder: (context, snapshot) {
      if (!snapshot.hasError) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Image?> images = (snapshot.data as List<Image?>);
          Image img0 = images[0]==null ? Image.asset('images/card_back.png') : images[0]!;
          if (images.length>1) {
            Image img1 = images[1]==null ? Image.asset('images/card_back.png') : images[1]!;
            return Row(
              children: [
                Expanded(
                  child: withDialog ? imageDialogButton(context: context, child: img0) : img0,
                ),
                Expanded(
                  child:  withDialog ? imageDialogButton(context: context, child: img1) : img1,
                ),
              ],
            );
          }
          else {
            return  withDialog ? imageDialogButton(context: context, child: img0) : img0;
          }
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset('images/card_back.png');
        }
      }
      print(snapshot.error);
      return Center(
        child: Text(cardName!),
      );
    },
  );
}