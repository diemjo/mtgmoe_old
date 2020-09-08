import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_typeahead/cupertino_flutter_typeahead.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:MTGMoe/moe_style.dart';

Widget typeAheadTextField(TextEditingController controller, FutureOr<Iterable<String>> Function(String) suggestionFunction, void Function(dynamic) onChanged, void Function() onEditingComplete) {
  Widget suggestionContent(String suggestion) => Container(
      height: 35,
      color: MoeStyle.defaultAppColor,
      padding: const EdgeInsets.all(5),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(suggestion, textScaleFactor: 0.9)
      )
  );
  controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  return Container(
    height: 40,
    child: PlatformWidget(
      material: (context, platform) => TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
          decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor, border: UnderlineInputBorder(borderSide: BorderSide(color: MoeStyle.defaultIconColor))),
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          maxLines: 1,
          style: TextStyle(fontSize: 14),
        ),
        suggestionsBoxDecoration: SuggestionsBoxDecoration(color: MoeStyle.defaultAppColor, hasScrollbar: false),
        suggestionsCallback: suggestionFunction,
        itemBuilder: (context, suggestion) {
          return suggestionContent(suggestion);
        },
        onSuggestionSelected: (suggestion) { controller.text = suggestion; if (onEditingComplete!=null) onEditingComplete(); },
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      ),
      cupertino: (context, platform) => CupertinoTypeAheadField(
        textFieldConfiguration: CupertinoTextFieldConfiguration(
          controller: controller,
          decoration: BoxDecoration(color: MoeStyle.defaultAppColor, border: Border(bottom: BorderSide(color: MoeStyle.defaultIconColor))),
          clearButtonMode: OverlayVisibilityMode.editing,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          maxLines: 1,
          style: TextStyle(fontSize: 14),
        ),
        suggestionsCallback: suggestionFunction,
        suggestionsBoxDecoration: CupertinoSuggestionsBoxDecoration(color: MoeStyle.defaultAppColor, hasScrollbar: false),
        itemBuilder: (context, suggestion) {
          return suggestionContent(suggestion);
        },
        onSuggestionSelected: (suggestion) { controller.text = suggestion; if (onEditingComplete!=null) onEditingComplete(); },
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true,
      ),
    ),
  );
}