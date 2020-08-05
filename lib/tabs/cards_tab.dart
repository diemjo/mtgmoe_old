import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;

import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/model/app_state_model.dart';

class CardsTab extends StatefulWidget {
  @override
  _CardsTabState createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  TextEditingController searchController = TextEditingController();
  List<MTGCard> cardList;

  void _filterResults() {

  }

  void _sortResults() {

  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppStateModel>(context);
    if (model.cards.length > 0) {
      cardList = model.cards.values.toList();
    }
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: Row(
              children: <Widget>[
                Expanded(
                  child: PlatformTextField(
                    controller: searchController,
                    keyboardType: TextInputType.text,
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: PlatformButton(
                    materialFlat: (context, platform) =>  MaterialFlatButtonData(),
                    child: Icon(
                      Icons.filter_list,
                      color: MoeStyle.defaultIconColor,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: _filterResults,
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: PlatformButton(
                    materialFlat: (context, platform) =>  MaterialFlatButtonData(),
                    child: Icon(
                      Icons.sort,
                      color: MoeStyle.defaultIconColor,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: _sortResults,
                  ),
                )
              ],
            ),
          ),
          _cardTabContent(cardList),
        ],
      ),
    );
  }

  Widget _cardTabContent(List<MTGCard> cardList) {
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
            }
        ),
      );
    }
    else {
      return SliverToBoxAdapter(
        child: Center(
          heightFactor: 10,
          child: Text(
            'No cards in local database.\n'
            'Update cards in the settings',
            style: MoeStyle.cardTabNoCardsText,
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
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data as Image;
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset('images/card_back.png');
        }
        else {
          return Text('error');
        }
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
}
