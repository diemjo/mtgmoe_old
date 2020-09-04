import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:MTGMoe/util/filter.dart';
import 'package:MTGMoe/util/order.dart';

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
  CardOrder order = CardOrder(type1: OrderType.DATE_DESC, type2: OrderType.RARITY_DESC, type3: OrderType.NUMBER_ASC);
}