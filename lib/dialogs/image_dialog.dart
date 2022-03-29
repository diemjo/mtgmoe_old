import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void imageDialog(BuildContext context, Image cardImage) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => _imageDialogBuilder(context, animation, secondaryAnimation, cardImage),
    barrierColor: Color(0xaa000000),
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: Duration(milliseconds: 100),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return Transform.scale(scale: animation.value, child: child);
    },
  );
}

Widget _imageDialogBuilder(BuildContext context, Animation animation, Animation secondaryAnimation, Image image) {
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(5.0),
    child: MaterialButton(
      child: image,
      padding: EdgeInsets.zero,
      onPressed: Navigator.of(context).pop,
    ),
  );
}

Widget imageDialogButton({required BuildContext context, required Image child}) {
  return FittedBox(
    child: MaterialButton(
      splashColor: Colors.transparent,
      padding: EdgeInsets.zero,
      onPressed: () => imageDialog(context, child),
      child: child,
    ),
  );
}