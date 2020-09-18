import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/tabs/card_grid_consumer_builder.dart';
import 'package:MTGMoe/model/card/mtg_card.dart';
import 'package:MTGMoe/model/card/mtg_card_face.dart';
import 'package:MTGMoe/model/card/mtg_set.dart';
import 'package:MTGMoe/util/extensions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';


class CardInfo extends StatefulWidget {
  final String cardId, cardName;

  CardInfo({@required this.cardId,@required this.cardName});

  @override
  _CardInfoState createState() => _CardInfoState(cardId: cardId, cardName: cardName);
}

class _CardInfoState extends State<CardInfo> {
  String cardId, cardName;

  _CardInfoState({@required this.cardId, @required this.cardName});

  Future<MTGCard> card;

  @override
  void initState() {
    super.initState();
    card = MTGDB.loadCard(cardId);
  }

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
          actions: [
            FutureBuilder(
              future: card,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PopupMenuButton(itemBuilder: (context) => [
                      PopupMenuItem<String>(child: Text((snapshot.data as MTGCard).imageURIs==null ? 'Share Images' : 'Share Image'), value: 'image'),
                      PopupMenuItem<String>(child: Text('Share URL'), value: 'url'),
                    ],
                    onSelected: (value) { print(value); onMenuItemSelected(value, snapshot.data as MTGCard); },
                    icon: Icon(PlatformIcons(context).share),
                    enabled: true,
                  );
                }
                return Container();
              },
            ),
          ],
        ),
        backgroundColor: MoeStyle.defaultAppColor,
        body: FutureBuilder(
          future: card,
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
    List<Widget> items = cardInfoItems(card);
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index==0) {
              return Container(
                  height: MediaQuery.of(context).size.width/2*(680.0/488.0),
                  child: cardImages(card.id, card.name, 2, withDialog: true)
              );
            }
            int listIndex = index-1;
            if (listIndex < items.length) {
              return items[listIndex];
            }
            else {
              return null;
            }
          }),
        )
      ]
    );
  }

  List<Widget> cardInfoItems(MTGCard card)  {
    List<Widget> items = [];
    items.add(cardInfoEntry('NAME', textWithPadding(card.name), top: true));
    items.add(cardInfoEntry('SET', setName(card.setCode)));
    if (card.cardFaces?.atOrNull(0)?.types==null && card.types!=null)
      items.add(cardInfoEntry('TYPE', textWithPadding(card.types.toJsonString())));
    if (card.cardFaces?.atOrNull(0)?.colorIdentity==null && card.colorIdentity!=null)
      items.add(cardInfoEntry('COLORS', colorInfo(card.colorIdentity)));
    if (card.oracleText!=null && card.oracleText!='')
      items.add(cardInfoEntry('TEXT', textWithPadding(card.oracleText)));
    if (card.power!=null && card.toughness!=null)
      items.add(cardInfoEntry('POWER / TOUGHNESS', textWithPadding('${card.power} / ${card.toughness}')));

    if (card.cardFaces!=null && card.cardFaces.length>1) {
      List<Widget> frontItems = itemsForCardFace(card.cardFaces[0]);

      List<Widget> backItems = itemsForCardFace(card.cardFaces[1]);

      items.add(ExpansionTile(
        title: textWithPadding('FRONT', style: MoeStyle.smallText),
        backgroundColor: MoeStyle.defaultDecorationColor.withAlpha(30),
        tilePadding: EdgeInsets.zero,
        children: frontItems,
        childrenPadding: const EdgeInsets.only(left: 10.0),
      ));
      items.add(Divider(color: MoeStyle.defaultDecorationColor));

      items.add(ExpansionTile(
        title: textWithPadding('BACK', style: MoeStyle.smallText),
        backgroundColor: MoeStyle.defaultDecorationColor.withAlpha(30),
        tilePadding: EdgeInsets.zero,
        children: backItems,
        childrenPadding: const EdgeInsets.only(left: 10.0),
      ));
      items.add(Divider(color: MoeStyle.defaultDecorationColor));
    }
    return items;
  }

  List<Widget> itemsForCardFace(MTGCardFace face) {
    List<Widget> items = [];
    items.add(cardInfoEntry('NAME', textWithPadding(face.name), top: true));
    items.add(cardInfoEntry('TYPE', textWithPadding(face.types.toJsonString())));
    if (face.colorIdentity!=null)
      items.add(cardInfoEntry('COLORS', colorInfo(face.colorIdentity)));
    if (face.oracleText!=null && face.oracleText!='')
      items.add(cardInfoEntry('TEXT', textWithPadding(face.oracleText)));
    if (face.power!=null && face.toughness!=null)
      items.add(cardInfoEntry('POWER / TOUGHNESS', textWithPadding('${face.power} / ${face.toughness}')));
    return items;
  }

  Widget colorInfo(List<String> colorIdentity) {
    List<Widget> icons = [];
    Map<String, Color> colors = {
      'G': MoeStyle.forestColor,
      'W': MoeStyle.plainsColor,
      'U': MoeStyle.islandColor,
      'B': MoeStyle.swampColor,
      'R': MoeStyle.mountainColor,
    };
    for (String color in colors.keys) {
      if (colorIdentity.contains(color))
        icons.add(Container(
          margin: const EdgeInsets.all(5.0),
          width: 25,
          height: 25,
          decoration: ShapeDecoration(
            color: colors[color],
            shape: CircleBorder(side: BorderSide(color: Colors.white, width: 0.8)),
          ),
        ));
    }
    if (icons.length==0) {
      icons.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Text('—'),
      ));
    }
    return Row(
      children: icons,
    );
  }
  
  Widget textWithPadding(String text, {TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Align(alignment: Alignment.centerLeft, child: SelectableText(text, style: style)),
    );
  }

  Widget setName(String setCode) {
    return FutureBuilder(
      future: MTGDB.setFromCode(setCode),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          MTGSet set = snapshot.data;
          return Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 5.0, top: 2.0),
                decoration: BoxDecoration(color: MoeStyle.defaultIconColor),
                padding: const EdgeInsets.all(3.0),
                child: SvgPicture.network(set.iconSvgURI, width: 20, height: 20),
              ),
              textWithPadding(set.name),
            ],
          );
        }
        else {
          return textWithPadding(setCode);
        }
      },
    );
  }

  Widget cardInfoEntry(String title, Widget content, {bool top=false}) {
    if (top) {
      return Column(
        children: [
          Divider(color: top ? MoeStyle.defaultDecorationColor : Colors.transparent, height: 7),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                child: Text(title, style: MoeStyle.smallText, textAlign: TextAlign.left),
              )),
          content,
          Divider(color: MoeStyle.defaultDecorationColor, height: 7),
        ],
      );
    }
    else {
      return Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                child: Text(title, style: MoeStyle.smallText, textAlign: TextAlign.left),
              )),
          content,
          Divider(color: MoeStyle.defaultDecorationColor, height: 7),
        ],
      );
    }
  }

  void onMenuItemSelected(String value, MTGCard card) async {
    switch (value) {
      case 'image':
        shareImages(card, card.imageURIs==null);
        break;
      case 'url':
        shareURL(card.scryfallURI);
        break;
      default:
    }
  }

  void shareImages(MTGCard card, bool two) async {
    String cardId = card.id;
    String dirPath = (await getApplicationDocumentsDirectory()).path;
    List<String> paths = [];
    if (two) {
      File front = File(join(dirPath, 'images/${cardId}_0.png'));
      if (front.existsSync()) {
        paths.add(front.path);
      }
      File back = File(join(dirPath, 'images/${cardId}_1.png'));
      if (back.existsSync()) {
        paths.add(back.path);
      }
    }
    else {
      File f = File(join(dirPath, 'images/$cardId.png'));
      if (f.existsSync()) {
        paths.add(f.path);
      }
    }
    print('sharing: $paths ($cardName)');
    Share.shareFiles(paths, text: cardName);
  }

  void shareURL(String url) {
    print('sharing: $url ($cardName)');
    Share.share('$cardName\n$url', subject: cardName);
  }
}
