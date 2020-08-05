
import 'package:flutter/widgets.dart';

abstract class MoeStyle {

  static const TextStyle settingsUpdateText = TextStyle(
    color: Color(0xffffbbff),
    fontSize: 18,
  );

  static const TextStyle cardTabNoCardsText = TextStyle(
    color: Color(0xccffbbff),
    fontWeight: FontWeight.bold,
    fontSize: 20,
    height: 1,
  );

  static const Color defaultIconColor = Color(0xffffddff);
  static const Color navigationBarIconColor = Color(0xffffffff);
  static const Color navigationBarIconColorActive = Color(0xffff88ff);
}