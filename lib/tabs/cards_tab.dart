import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/model/mtg_card.dart';
import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/tabs/card_grid_consumer_builder.dart';
import 'package:MTGMoe/util/filter.dart';

class CardsTab extends StatefulWidget {
  @override
  _CardsTabState createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  TextEditingController searchController = TextEditingController();
  List<MTGCard> cards;
  bool colorGreen = false, colorWhite = false, colorBlue = false, colorBlack = false, colorRed = false;
  ColorMatch colorMatch = ColorMatch.MIN;
  PageStorageKey _scrollKey = PageStorageKey('CardsTab');

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppStateModel>(context);
    searchController.text = model.filter.name;
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: Row(
              children: <Widget>[
                Expanded(
                  child: PlatformTextField(
                    controller: searchController,
                    keyboardType: TextInputType.text,
                    onEditingComplete: () {
                      setState(() {
                        model.filter.name = searchController.text;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (value) {
                      if (value=='') {
                        setState(() {
                          model.filter.name = searchController.text;
                        });
                      }
                    },
                    cupertino: (context, platform) => CupertinoTextFieldData(clearButtonMode: OverlayVisibilityMode.editing),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: PlatformButton(
                    materialFlat: (context, platform) =>  MaterialFlatButtonData(),
                    child: Icon(
                      Icons.filter_list,
                      color: MoeStyle.defaultIconColor,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _filterDialog(model);
                    },
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: PlatformButton(
                    materialFlat: (context, platform) =>  MaterialFlatButtonData(),
                    child: Icon(
                      Icons.sort,
                      color: MoeStyle.defaultIconColor,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: _sortResults,
                  ),
                )
              ],
            ),
          ),
          FutureBuilder(
            future: MTGDB.loadCards(filter: model.filter, order: model.order),
            builder: (context, snapshot) {
              Widget tabContent;
              PageStorageKey scrollKey = PageStorageKey('CardTabDefault');
              if (snapshot.connectionState==ConnectionState.waiting) {
                tabContent = SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: PlatformCircularProgressIndicator(),
                      ),
                    )
                );
              }
              else if (snapshot.connectionState==ConnectionState.done && !snapshot.hasError) {
                tabContent = cardTabContent(snapshot.data);
                scrollKey = _scrollKey;
              }
              else {
                if (snapshot.hasError)
                  print('error: ${snapshot.error}');
                else
                  print(snapshot.connectionState);
                tabContent = SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error loading cards'),
                  ),
                );
              }
              return Flexible(
                child: CustomScrollView(
                  key: scrollKey,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  slivers: [
                    tabContent,
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filterWidgetBuilder(BuildContext context, Animation<double> animation, Animation<double> secondAnimation) {
    final AppStateModel model = Provider.of<AppStateModel>(context);
    TextEditingController nameController = TextEditingController(text: model.filter?.name);
    TextEditingController textController = TextEditingController(text: model.filter?.text);
    TextEditingController powerController = TextEditingController(text: model.filter?.power);
    TextEditingController toughnessController = TextEditingController(text: model.filter?.toughness);
    TextEditingController typeController = TextEditingController(text: model.filter?.type);
    TextEditingController subtypeController = TextEditingController(text: model.filter?.subtype);
    return Dialog(
      child: StatefulBuilder(
        builder: (context, dialogSetState) {
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  color: MoeStyle.cardFilterColor,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  border: Border.all(color: Color(0xffff88ff))
              ),
              padding: EdgeInsets.all(5.0),
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
                            nameController.clear();
                            textController.clear();
                            powerController.clear();
                            toughnessController.clear();
                            typeController.clear();
                            subtypeController.clear();
                            dialogSetState(() {colorGreen = colorWhite = colorBlue = colorBlack = colorRed = false; colorMatch = ColorMatch.MIN;});
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
                  PlatformTextField(
                    material: (context, platform) =>
                        MaterialTextFieldData(controller: nameController, decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor)),
                    style: MoeStyle.textFieldStyle,
                    cupertino: (context, platform) =>
                        CupertinoTextFieldData(controller: nameController, decoration: BoxDecoration(color: MoeStyle.defaultAppColor), clearButtonMode: OverlayVisibilityMode.editing),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                    child: Text('Card Text', style: MoeStyle.smallText),
                  ),
                  PlatformTextField(
                    material: (context, platform) =>
                        MaterialTextFieldData(controller: textController, decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor)),
                    style: MoeStyle.textFieldStyle,
                    cupertino: (context, platform) =>
                        CupertinoTextFieldData(controller: textController, decoration: BoxDecoration(color: MoeStyle.defaultAppColor), clearButtonMode: OverlayVisibilityMode.editing),
                  ),
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
                  Row(
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
                      VerticalDivider(color: MoeStyle.dividerColor, width: 10),
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
                  Divider(color: MoeStyle.dividerColor),
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
                          child: PlatformTextField(
                            material: (context, platform) =>
                                MaterialTextFieldData(controller: typeController, decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor)),
                            style: MoeStyle.textFieldStyle,
                            cupertino: (context, platform) =>
                                CupertinoTextFieldData(controller: typeController, decoration: BoxDecoration(color: MoeStyle.defaultAppColor), clearButtonMode: OverlayVisibilityMode.editing),
                          )
                      ),
                      VerticalDivider(color: MoeStyle.dividerColor, width: 10),
                      Expanded(flex: 1,
                          child: PlatformTextField(
                            material: (context, platform) =>
                                MaterialTextFieldData(controller: subtypeController, decoration: InputDecoration(filled: true, fillColor: MoeStyle.defaultAppColor)),
                            style: MoeStyle.textFieldStyle,
                            cupertino: (context, platform) =>
                                CupertinoTextFieldData(controller: subtypeController, decoration: BoxDecoration(color: MoeStyle.defaultAppColor), clearButtonMode: OverlayVisibilityMode.editing),
                          )
                      ),
                    ],
                  ),//type textfield
                  Divider(color: MoeStyle.dividerColor),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                    child: Text('Colors', style: MoeStyle.smallText),
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
                            onPressed: () { dialogSetState(() {
                              colorGreen = !colorGreen;
                            });},
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                color: colorGreen ? Colors.green : Colors.green.withAlpha(70),
                                shape: CircleBorder(side: colorGreen ? BorderSide(color: Color(0xffffffff)) : BorderSide.none),
                              ),
                            ),
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
                            onPressed: () { dialogSetState(() {
                              colorWhite = !colorWhite;
                            });},
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                color: colorWhite ? Colors.white : Colors.white.withAlpha(70),
                                shape: CircleBorder(side: colorWhite ? BorderSide(color: Color(0xffffffff)) : BorderSide.none),
                              ),
                            ),
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
                            onPressed: () { dialogSetState(() {
                              colorBlue = !colorBlue;
                            });},
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                color: colorBlue ? Colors.blue : Colors.blue.withAlpha(70),
                                shape: CircleBorder(side: colorBlue ? BorderSide(color: Color(0xffffffff)) : BorderSide.none),
                              ),
                            ),
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
                            onPressed: () { dialogSetState(() {
                              colorBlack = !colorBlack;
                            });},
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                color: colorBlack ? Colors.black : Colors.black.withAlpha(70),
                                shape: CircleBorder(side: colorBlack ? BorderSide(color: Color(0xffffffff)) : BorderSide.none),
                              ),
                            ),
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
                            onPressed: () { dialogSetState(() {
                              colorRed = !colorRed;
                            });},
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: ShapeDecoration(
                                color: colorRed ? Colors.red : Colors.red.withAlpha(70),
                                shape: CircleBorder(side: colorRed ? BorderSide(color: Color(0xffffffff)) : BorderSide.none),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(color: MoeStyle.dividerColor),
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
                            shape: RoundedRectangleBorder(side: colorMatch==ColorMatch.MIN ? BorderSide(color: MoeStyle.defaultIconColor) : BorderSide.none,
                                borderRadius: BorderRadius.all(Radius.circular(10))),
                            onPressed: () { dialogSetState(() {
                              colorMatch = ColorMatch.MIN;
                            });},
                            child: Text('Min', style: colorMatch==ColorMatch.MIN ? MoeStyle.defaultText : MoeStyle.smallText),
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
                            shape: RoundedRectangleBorder(side: colorMatch==ColorMatch.MAX ? BorderSide(color: MoeStyle.defaultIconColor) : BorderSide.none,
                                borderRadius: BorderRadius.all(Radius.circular(10))),
                            onPressed: () { dialogSetState(() {
                              colorMatch = ColorMatch.MAX;
                            });},
                            child: Text('Max', style: colorMatch==ColorMatch.MAX ? MoeStyle.defaultText : MoeStyle.smallText),
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
                            shape: RoundedRectangleBorder(side: colorMatch==ColorMatch.EXACT ? BorderSide(color: MoeStyle.defaultIconColor) : BorderSide.none,
                                borderRadius: BorderRadius.all(Radius.circular(10))),
                            onPressed: () { dialogSetState(() {
                              colorMatch = ColorMatch.EXACT;
                            });},
                            child: Text('Exact', style: colorMatch==ColorMatch.EXACT ? MoeStyle.defaultText : MoeStyle.smallText),
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
                            onPressed: () => Navigator.of(context).pop(),
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
                              List<String> colors = List<String>();
                              if (colorGreen) colors.add('G');
                              if (colorWhite) colors.add('W');
                              if (colorBlue) colors.add('U');
                              if (colorBlack) colors.add('B');
                              if (colorRed) colors.add('R');
                              setState(() {
                                model.filter = CardFilter(name: nameController.text,
                                  text: textController.text,
                                  power: powerController.text,
                                  toughness: toughnessController.text,
                                  type: typeController.text,
                                  subtype: subtypeController.text,
                                  colors: colors,
                                  colorMatch: colorMatch,
                                );
                              });
                              Navigator.of(context).pop();
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

  void _filterDialog(AppStateModel model) {
    colorGreen = model.filter.colors?.contains('G')??false;
    colorWhite = model.filter.colors?.contains('W')??false;
    colorBlue = model.filter.colors?.contains('U')??false;
    colorBlack = model.filter.colors?.contains('B')??false;
    colorRed = model.filter.colors?.contains('R')??false;
    colorMatch = model.filter.colorMatch;
    showGeneralDialog(
      context: context,
      pageBuilder: _filterWidgetBuilder,
      barrierDismissible: true,
      barrierLabel: 'Filter',
      barrierColor: Color(0x77000000),
      transitionDuration: Duration(milliseconds: 100),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        double w = MediaQuery.of(context).size.width;
        double h = MediaQuery.of(context).size.height;
        return Transform.scale(scale: animation.value, origin: Offset((0.82-0.5)*w, (0.09-0.5)*h), child: child);
      },
    );
  }

  void _sortResults() {

  }
}
