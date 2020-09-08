import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:MTGMoe/model/filter.dart';
import 'package:MTGMoe/model/order.dart';

enum UpdateStatus {
  DEFAULT,
  LOADING,
  SUCCESS,
  ERROR,
  CANCELLED
}

class AppStateModel extends ChangeNotifier {

  UpdateStatus updateStatus = UpdateStatus.DEFAULT;

  String updateSet = "";

  int updateSetIndex = 0;

  int updateSetIndexMax = 0;

  bool doUpdate = false;

  void update() {
    notifyListeners();
  }

  CardFilter filter = CardFilter();
  CardOrder order = CardOrder(OrderType.DATE_DESC, OrderType.RARITY_DESC, OrderType.NUMBER_ASC, OrderType.CMC_DESC, OrderType.NAME_ASC);
}