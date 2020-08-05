import 'dart:io';

import 'package:MTGMoe/model/mtg_set.dart';
import 'file:///C:/Users/jdiem/IdeaProjects/mtgmoe/lib/mtg_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/model/app_state_model.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}
class _SettingsTabState extends State<SettingsTab> {
  UpdateStatus updateStatus;
  String updateSet;
  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    updateStatus = UpdateStatus.DEFAULT;
    updateSet = "";
  }

  Widget _buildUpdateIcon(BuildContext context) {
    final model = Provider.of<AppStateModel>(context);
    updateStatus = model.updateStatus;
    if (model.updateStatus==UpdateStatus.SUCCESS || model.updateStatus==UpdateStatus.ERROR || model.updateStatus==UpdateStatus.CANCELLED) {
      model.updateStatus = UpdateStatus.DEFAULT;
    }
    switch(updateStatus) {
      case UpdateStatus.DEFAULT:
        return Container(
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Update cards from database'),
            ],
          ),
        );
      case UpdateStatus.LOADING:
        return Container(
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Updating cards${updateSet != "" ? ' ($updateSet)' : ''}'),
              Container(
                padding: const EdgeInsets.only(left: 8.0),
                child: PlatformCircularProgressIndicator(),
              ),
            ],
          ),
        );
      case UpdateStatus.SUCCESS:
        return Container(
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Updated cards'),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(context.platformIcons.checkMark, color: MoeStyle.defaultIconColor, size: 32),
              ),
            ],
          ),
        );
      case UpdateStatus.ERROR:
        return Container(
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Failed to update cards'),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(context.platformIcons.clear, color: MoeStyle.defaultIconColor, size: 32),
              ),
            ],
          ),
        );
      case UpdateStatus.CANCELLED:
        return Container(
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Cancelling update'),
            ],
          ),
        );
      default:
        throw Exception('invalid status');
    }
  }

  void _updateSets(AppStateModel model) async {
    final response = await http.get("https://api.scryfall.com/sets/");
    if (response.statusCode == 200) {
      var rootJson = jsonDecode(response.body);
      var setListJson = rootJson['data'] as List;
      List<MTGSet> sets = setListJson.map((e) => MTGSet.fromJson(e)).toList();
      for(var set in sets) {
        if (!model.sets.containsKey(set.code)) {
          MTGDB.saveSets([set]);
          print('adding ${set.name}\n');
          model.sets[set.code] = set;
          setState(() {updateSet = set.name;});
          sleep(Duration(milliseconds: 50));
          await _updateCards(model, set.searchURI);
          if (!model.doUpdate)
            break;
        }
      }
      model.updateStatus = model.doUpdate ? UpdateStatus.SUCCESS : UpdateStatus.DEFAULT;
      setState(() {
        updateSet = "";
        updateStatus = model.doUpdate ? UpdateStatus.SUCCESS : UpdateStatus.DEFAULT;
      });
    }
    else {
      print(response.statusCode);
      model.updateStatus = UpdateStatus.ERROR;
      setState(() {
        updateStatus = UpdateStatus.ERROR;
      });
    }
  }

  Future<void> _updateCards(AppStateModel model, String searchURI) async {
    bool hasMore = true;
    String uri = searchURI;
    List<MTGCard> cards = [];
    while(hasMore) {
      hasMore = false;
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
    MTGDB.saveCards(cards);
  }

  void _updateDB() {
    final model = Provider.of<AppStateModel>(context, listen: false);
    switch(updateStatus) {
      case UpdateStatus.DEFAULT:
      case UpdateStatus.SUCCESS:
      case UpdateStatus.ERROR:
      case UpdateStatus.CANCELLED:
        model.doUpdate = true;
        _updateSets(model);
        model.updateStatus = UpdateStatus.LOADING;
        setState(() {
          updateStatus = UpdateStatus.LOADING;
        });
        break;
      case UpdateStatus.LOADING:
        model.doUpdate = false;
        model.updateStatus = UpdateStatus.CANCELLED;
        setState(() {
          updateStatus = UpdateStatus.CANCELLED;
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          PlatformButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (updateStatus == UpdateStatus.CANCELLED) ?
                  Icon(
                    context.platformIcons.pause,
                    color: MoeStyle.defaultIconColor,
                  )
                  :
                  Icon(
                    context.platformIcons.refresh,
                    color: MoeStyle.defaultIconColor,
                  ),
                ),
                Text(
                  'Update DB',
                  style: MoeStyle.settingsUpdateText,
                ),
              ],
            ),
            onPressed: _updateDB,
          ),
          _buildUpdateIcon(context),
          Divider(color: Color(0xffffffff)),
        ],
      ),
    );
  }
}
