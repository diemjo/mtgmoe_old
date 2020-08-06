import 'package:flutter/foundation.dart';

import 'package:MTGMoe/model/mtg_set.dart';
import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/mtg_db.dart';

enum UpdateStatus {
  DEFAULT,
  LOADING,
  SUCCESS,
  ERROR,
  CANCELLED
}

class AppStateModel extends ChangeNotifier {

  Map<String, MTGCard> _cards;
  Map<String, MTGSet> _sets;
  Map<String, List<MTGCard>> _setCards;

  UpdateStatus updateStatus = UpdateStatus.DEFAULT;
  String updateSet = "";
  int updateSetIndex = 0;
  int updateSetIndexMax = 0;
  bool doUpdate = false;

  void loadData() async {
    if (_cards!=null && _cards.length>0) return;
    Iterable<MTGCard> cardList = await MTGDB.loadCards();
    _cards = Map.fromIterable(cardList, key: (e) => (e as MTGCard).id, value: (e) => e);
    Iterable<MTGSet> setList = await MTGDB.loadSets();
    _sets = Map.fromIterable(setList, key: (e) => (e as MTGSet).code, value: (e) => e);
    _setCards = Map<String, List<MTGCard>>();
    for(String code in _sets.keys) {
      _setCards[code] = _cards.values.where((card) => card.set==code).toList();
    }
  }

  Map<String, MTGSet> get sets {
    if (_sets==null) {
      _sets = Map<String, MTGSet>();
      loadData();
    }
    return _sets;
  }
  set sets(Map<String, MTGSet> newSets) {
    _sets.clear();
    _sets.addAll(newSets);
  }

  Map<String, MTGCard> get cards {
    if (_cards == null) {
      _cards = Map<String, MTGCard>();
      loadData();
    }
    return _cards;
  }
  set cards(Map<String, MTGCard> newCards) {
    _cards.clear();
    _cards.addAll(newCards);
  }

  Map<String, List<MTGCard>> get setCards {
    if (_setCards == null) {
      _setCards = Map<String, List<MTGCard>>();
      loadData();
    }
    return _setCards;
  }
  set setCards(Map<String, List<MTGCard>> newCards) {
    _setCards.clear();
    _setCards.addAll(newCards);
  }

}