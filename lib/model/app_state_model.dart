import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:MTGMoe/model/filter.dart';
import 'package:MTGMoe/model/order.dart';

enum UpdateStatus {
  IDLE,
  INITIALIZING,
  DOWNLOADING,
}

class AppStateModel extends ChangeNotifier {

  UpdateStatus updateStatus = UpdateStatus.IDLE;

  Future<Map<String, Object>> updateFuture;
  CancelToken cancelToken;

  int bytesFromDownload = 0;
  int updateProgress = 0;

  bool doUpdate = false;

  void update() {
    notifyListeners();
  }

  CardFilter filter = CardFilter();
  CardOrder order = CardOrder(OrderType.DATE_DESC, OrderType.NUMBER_ASC, OrderType.RARITY_DESC, OrderType.CMC_DESC, OrderType.NAME_ASC);
}