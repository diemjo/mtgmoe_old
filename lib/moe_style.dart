
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class MoeStyle {

  static const TextStyle defaultText = TextStyle(
    color: Color(0xffffbbff),
    fontSize: 18,
    decoration: TextDecoration.none,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal
  );

  static const TextStyle defaultBoldText = TextStyle(
    color: Color(0xffffbbff),
    fontWeight: FontWeight.bold,
    fontSize: 20,
    height: 1,
    decoration: TextDecoration.none,
  );

  static const TextStyle smallText = TextStyle(
    color: Color(0xffffbbff),
    fontSize: 14,
    decoration: TextDecoration.none,
  );

  static const TextStyle greyText = TextStyle(
      color: Color(0xff777777),
      fontSize: 14,
      decoration: TextDecoration.none,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal
  );

  static const TextStyle textFieldStyle = TextStyle(
    color: Color(0xffcccccc),
    fontSize: 16,
    decoration: TextDecoration.none,
  );

  static const Color defaultAppColor = Color(0xff222222);
  static const Color defaultIconColor = Color(0xffffddff);
  static const Color cardListDialogColor = Color(0xff333333);
  static const Color navigationBarIconColor = Color(0xffffffff);
  static const Color navigationBarIconColorActive = Color(0xffff88ff);
  static const Color filterButtonColor = Color(0xffdd22dd);
  static const Color dividerColor = Color(0xffffffff);
  static const Color defaultDecorationColor = Color(0xffff88ff);

  static const Color forestColor = Colors.green;
  static const Color plainsColor = Color(0xfffffbd5);
  static const Color islandColor = Colors.lightBlue;
  static const Color swampColor = Colors.black;
  static const Color mountainColor = Colors.red;
}