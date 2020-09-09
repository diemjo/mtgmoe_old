import 'package:flutter/widgets.dart';
import 'package:MTGMoe/moe_style.dart';

Widget settingRow({@required Widget child}) {
  return Container(
    height: 45,
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: MoeStyle.defaultDecorationColor, width: 0.5),
        top: BorderSide(color: MoeStyle.defaultDecorationColor, width: 0.5),
      ),
    ),
    child: child,
  );
}