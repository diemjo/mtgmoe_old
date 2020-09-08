import 'package:flutter/widgets.dart';
import 'package:MTGMoe/moe_style.dart';

Widget settingRow({@required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: MoeStyle.defaultDecorationColor, width: 0.5),
      ),
    ),
    child: child,
  );
}