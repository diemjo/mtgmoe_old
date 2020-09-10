import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/tabs/card_grid_consumer_builder.dart';
import 'package:MTGMoe/model/card/mtg_card.dart';

class CardInfo extends StatefulWidget {
  final String cardId, cardName;

  CardInfo({@required this.cardId,@required this.cardName});

  @override
  _CardInfoState createState() => _CardInfoState(cardId: cardId, cardName: cardName);
}

class _CardInfoState extends State<CardInfo> {
  String cardId, cardName;

  _CardInfoState({@required this.cardId, @required this.cardName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          primary: true,
          centerTitle: true,
          toolbarHeight: 50,
          title: Text('Card Info', style: TextStyle(color: Colors.white), softWrap: true, maxLines: 2),
          backgroundColor: MoeStyle.filterButtonColor.withAlpha(100),
        ),
        backgroundColor: MoeStyle.defaultAppColor,
        body: FutureBuilder(
          future: MTGDB.loadCard(cardId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Error loading card info for $cardName'),
              );
            }
            else if (snapshot.connectionState==ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: PlatformCircularProgressIndicator(),
                ),
              );
            }
            else if (snapshot.connectionState==ConnectionState.done){
              return _buildCardInfo(snapshot.data as MTGCard);
            }
            else {
              print(snapshot.connectionState);
              return Container();
            }
          },
        ),
      )
    );
  }

  Widget _buildCardInfo(MTGCard card) {
    Map<String,dynamic> cardMap = card.toMap();
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < cardMap.length+1) {
              if (index==0) {
                return Container(
                  height: MediaQuery.of(context).size.width/2*(680.0/488.0),
                  child: cardImages(card.id, card.name, 2, withDialog: true)
                );
              }
              return Container(
                padding: const EdgeInsets.all(3.0),
                decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white.withAlpha(100)))),
                child: Row(
                  children: [
                    Text(cardMap.keys.elementAt(index-1) + ': ', style: MoeStyle.smallText),
                    Flexible(child: Text((cardMap.values.elementAt(index-1)?.toString()??'null'), style: MoeStyle.smallText, softWrap: true, maxLines: 100)),
                  ],
                ),
              );
            }
            else {
              return null;
            }
          }),
        )
      ]
    );
  }
}
