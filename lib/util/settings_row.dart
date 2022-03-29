import 'package:flutter/widgets.dart';
import 'package:mtgmoe/moe_style.dart';

Widget settingRow({required Widget child, bool top=false}) {
  return Container(
    height: 45,
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: MoeStyle.defaultDecorationColor, width: 0.5),
        top: top ? BorderSide(color: MoeStyle.defaultDecorationColor, width: 0.5) : BorderSide.none,
      ),
    ),
    child: child,
  );
}