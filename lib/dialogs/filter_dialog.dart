import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:MTGMoe/model/filter.dart';
import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/util/type_ahead_textfield.dart';

Widget filterWidgetBuilder(BuildContext context, Animation<double> animation, Animation<double> secondAnimation, CardFilter filter) {
  return Dialog(
    child: StatefulBuilder(
      builder: (context, dialogSetState) {
        TextEditingController nameController = TextEditingController(text: filter?.name);
        TextEditingController textController = TextEditingController(text: filter?.text);
        TextEditingController setController = TextEditingController(text: filter?.set);
        TextEditingController powerController = TextEditingController(text: filter?.power);
        TextEditingController toughnessController = TextEditingController(text: filter?.toughness);
        TextEditingController typeController = TextEditingController(text: filter?.type);
        TextEditingController subtypeController = TextEditingController(text: filter?.subtype);
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color: MoeStyle.cardListDialogColor,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(color: Color(0xffff88ff))
            ),
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Center(
                        child: Text('Card Filter', style: MoeStyle.defaultBoldText)
                    ),
                    SizedBox(
                      height: 20,
                      width: 50,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        child: Text('clear', style: MoeStyle.smallText),
                        onPressed: () {
                          dialogSetState(() {
                            filter.clear();
                          });
                        },
                      ),
                    )
                  ],
                ),
                Divider(color: MoeStyle.dividerColor),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                  child: Text('Name', style: MoeStyle.smallText),
                ),
                typeAheadTextField(nameController, MTGDB.loadNames, (v) { filter.name = v; }, null),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                  child: Text('Card Text', style: MoeStyle.smallText),
                ),
                Container(
                  height: 40,
                  child: PlatformTextField(
                    onChanged: (v) { filter.text = v; },
                    material: (context, platform) =>
                        MaterialTextFieldData(controller: textController, decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor)),
                    style: MoeStyle.textFieldStyle,
                    cupertino: (context, platform) =>
                        CupertinoTextFieldData(controller: textController, decoration: BoxDecoration(color: MoeStyle.defaultAppColor), clearButtonMode: OverlayVisibilityMode.editing),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                  child: Text('Set', style: MoeStyle.smallText),
                ),
                typeAheadTextField(setController, MTGDB.loadSetNames, (v) { filter.set = v; }, null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                        child: Text('Type', style: MoeStyle.smallText),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                        child: Text('Subtype', style: MoeStyle.smallText),
                      ),
                    ),
                  ],
                ),//type label
                Row(
                  children: [
                    Expanded(flex: 1,
                      child: typeAheadTextField(typeController, MTGDB.loadTypeNames, (v) { filter.type = v; }, null),
                    ),
                    VerticalDivider(color: MoeStyle.dividerColor, width: 10),
                    Expanded(flex: 1,
                      child: typeAheadTextField(subtypeController, MTGDB.loadSubtypeNames, (v) { filter.subtype = v; }, null),
                    ),
                  ],
                ),//type textfield
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                        child: Text('Power', style: MoeStyle.smallText),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                        child: Text('Toughness', style: MoeStyle.smallText),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(flex: 1,
                          child: PlatformTextField(
                            material: (context, platform) =>
                                MaterialTextFieldData(controller: powerController, decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor)),
                            style: MoeStyle.textFieldStyle,
                            cupertino: (context, platform) =>
                                CupertinoTextFieldData(controller: powerController, decoration: BoxDecoration(color: MoeStyle.defaultAppColor), clearButtonMode: OverlayVisibilityMode.editing),
                          )
                      ),
                      VerticalDivider(color: Colors.transparent, width: 10),
                      Expanded(flex: 1,
                          child: PlatformTextField(
                            material: (context, platform) =>
                                MaterialTextFieldData(controller: toughnessController, decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor)),
                            style: MoeStyle.textFieldStyle,
                            cupertino: (context, platform) =>
                                CupertinoTextFieldData(controller: toughnessController, decoration: BoxDecoration(color: MoeStyle.defaultAppColor), clearButtonMode: OverlayVisibilityMode.editing),
                          )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                  child: Text('Rarity', style: MoeStyle.smallText),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _colorButton(filter.rarities.contains('common'), Colors.black54, 70, () {
                        dialogSetState(() {
                          if (filter.rarities.contains('common')) {
                            filter.rarities.remove('common');
                          }
                          else {
                            filter.rarities.add('common');
                          }
                        });
                      }),
                    ), //rarityCommon
                    Expanded(
                      child: _colorButton(filter.rarities.contains('uncommon'), Colors.white54, 70, () {
                        dialogSetState(() {
                          if (filter.rarities.contains('uncommon')) {
                            filter.rarities.remove('uncommon');
                          }
                          else {
                            filter.rarities.add('uncommon');
                          }
                        });
                      }),
                    ), //rarityUncommon
                    Expanded(
                      child: _colorButton(filter.rarities.contains('rare'), Colors.orangeAccent, 100, () {
                        dialogSetState(() {
                          if (filter.rarities.contains('rare')) {
                            filter.rarities.remove('rare');
                          }
                          else {
                            filter.rarities.add('rare');
                          }
                        });
                      }),
                    ), //rarityRare
                    Expanded(
                      child: _colorButton(filter.rarities.contains('mythic'), Colors.red, 100, () {
                        dialogSetState(() {
                          if (filter.rarities.contains('mythic')) {
                            filter.rarities.remove('mythic');
                          }
                          else {
                            filter.rarities.add('mythic');
                          }
                        });
                      }),
                    ), //rarityMythic
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                  child: Text('Color', style: MoeStyle.smallText),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _colorButton(filter.colors.contains('G'), Colors.green, 70, () {
                        dialogSetState(() {
                          if (filter.colors.contains('G')) {
                            filter.colors.remove('G');
                          }
                          else {
                            filter.colors.add('G');
                          }
                        });
                      }),
                    ),
                    Expanded(
                      child: _colorButton(filter.colors.contains('W'), Color(0xffffffbb), 70, () {
                        dialogSetState(() {
                          if (filter.colors.contains('W')) {
                            filter.colors.remove('W');
                          }
                          else {
                            filter.colors.add('W');
                          }
                        });
                      }),
                    ),
                    Expanded(
                      child: _colorButton(filter.colors.contains('U'), Colors.lightBlue, 70, () {
                        dialogSetState(() {
                          if (filter.colors.contains('U')) {
                            filter.colors.remove('U');
                          }
                          else {
                            filter.colors.add('U');
                          }
                        });
                      }),
                    ),
                    Expanded(
                      child: _colorButton(filter.colors.contains('B'), Colors.black, 70, () {
                        dialogSetState(() {
                          if (filter.colors.contains('B')) {
                            filter.colors.remove('B');
                          }
                          else {
                            filter.colors.add('B');
                          }
                        });
                      }),
                    ),
                    Expanded(
                      child: _colorButton(filter.colors.contains('R'), Colors.red, 70, () {
                        dialogSetState(() {
                          if (filter.colors.contains('R')) {
                            filter.colors.remove('R');
                          }
                          else {
                            filter.colors.add('R');
                          }
                        });
                      }),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                  child: Text('Color Match', style: MoeStyle.smallText),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: MaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          shape: RoundedRectangleBorder(side: filter.colorMatch==ColorMatch.MIN ? BorderSide(color: MoeStyle.defaultIconColor) : BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(10))),
                          onPressed: () { dialogSetState(() {
                            filter.colorMatch = ColorMatch.MIN;
                          });},
                          child: Text('Min', style: filter.colorMatch==ColorMatch.MIN ? MoeStyle.defaultText : MoeStyle.smallText),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: MaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          shape: RoundedRectangleBorder(side: filter.colorMatch==ColorMatch.MAX ? BorderSide(color: MoeStyle.defaultIconColor) : BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(10))),
                          onPressed: () { dialogSetState(() {
                            filter.colorMatch = ColorMatch.MAX;
                          });},
                          child: Text('Max', style: filter.colorMatch==ColorMatch.MAX ? MoeStyle.defaultText : MoeStyle.smallText),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: MaterialButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          shape: RoundedRectangleBorder(side: filter.colorMatch==ColorMatch.EXACT ? BorderSide(color: MoeStyle.defaultIconColor) : BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(10))),
                          onPressed: () { dialogSetState(() {
                            filter.colorMatch = ColorMatch.EXACT;
                          });},
                          child: Text('Exact', style: filter.colorMatch==ColorMatch.EXACT ? MoeStyle.defaultText : MoeStyle.smallText),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                        child: RaisedButton(
                          child: Text('Cancel', style: MoeStyle.defaultBoldText),
                          onPressed: ()  {
                            Navigator.of(context).pop('Cancel');
                          },
                        ),
                      ),
                    ),
                    Divider(color: MoeStyle.dividerColor),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
                        child: RaisedButton(
                          color: MoeStyle.filterButtonColor,
                          child: Text('Filter', style: MoeStyle.defaultBoldText),
                          onPressed: () {
                            Navigator.of(context).pop('Filter');
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _colorButton(bool active, Color color, int alpha, void Function() onPressed) {
  return SizedBox(
    width: 30,
    height: 30,
    child: MaterialButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onPressed: onPressed,
      child: Container(
        width: 25,
        height: 25,
        decoration: ShapeDecoration(
          color: active ? color : color.withAlpha(alpha),
          shape: CircleBorder(side: active ? BorderSide(width: 2, color: Color(0xffffffff)) : BorderSide.none),
        ),
      ),
    ),
  );
}