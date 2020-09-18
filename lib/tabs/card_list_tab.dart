import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/tabs/card_grid_consumer_builder.dart';
import 'package:MTGMoe/model/filter.dart';
import 'package:MTGMoe/dialogs/filter_dialog.dart';
import 'package:MTGMoe/model/order.dart';
import 'package:MTGMoe/dialogs/order_dialog.dart';
import 'package:MTGMoe/util/type_ahead_textfield.dart';

class CardsTab extends StatefulWidget {
  @override
  _CardsTabState createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  TextEditingController searchController = TextEditingController();
  CardFilter dialogFilter;
  CardOrder dialogOrder;
  PageStorageKey _scrollKey = PageStorageKey('CardsTab');
  ScrollController scrollController = ScrollController(initialScrollOffset: 25);

  @override
  void initState() {
    super.initState();
    print("Cards init");
  }

  @override
  void dispose() {
    print("Cards dispose");
    //MTGDB.closeDB();
    super.dispose();
  }

  void _filterDialog(AppStateModel model) {
    dialogFilter = CardFilter.fromFilter(model.filter);
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => filterWidgetBuilder(context, animation, secondaryAnimation, dialogFilter),
      barrierColor: Color(0x77000000),
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: Duration(milliseconds: 100),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        double w = MediaQuery.of(context).size.width;
        double h = MediaQuery.of(context).size.height;
        return Transform.scale(scale: animation.value, origin: Offset((0.82-0.5)*w, (0.09-0.5)*h), child: child);
      },
    ).then((value) {
      if (value=='Filter' && dialogFilter!=model.filter)
        setState((){
          model.filter = dialogFilter;
          scrollController.jumpTo(25);
        });
    });
  }

  void _sortDialog(AppStateModel model) {
    dialogOrder = CardOrder.fromOrder(model.order);
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => orderWidgetBuilder(context, animation, secondaryAnimation, dialogOrder),
      barrierColor: Color(0x77000000),
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: Duration(milliseconds: 100),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        double w = MediaQuery.of(context).size.width;
        double h = MediaQuery.of(context).size.height;
        return Transform.scale(scale: animation.value, origin: Offset((0.91-0.5)*w, (0.09-0.5)*h), child: child);
      },
    ).then((value) {
      if (value == 'Sort' && dialogOrder != model.order)
        setState(() {
          model.order = dialogOrder;
      });
    });
  }

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
                  child: Container(
                    height: 40,
                    decoration: ShapeDecoration(color: Colors.white10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3)))),
                    child: typeAheadTextField(
                      searchController, MTGDB.loadNames,
                      (val) {
                        if (val=='') {
                          setState(() { model.filter.name = searchController.text; });
                        }
                      },
                      () {
                        setState(() { model.filter.name = searchController.text; });
                        FocusScope.of(context).unfocus();
                      }
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: PlatformButton(
                    materialFlat: (context, platform) =>  MaterialFlatButtonData(splashColor: Colors.transparent),
                    child: Icon(
                      Icons.filter_list,
                      color: MoeStyle.defaultIconColor,
                      size: 30,
                    ),
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _filterDialog(model);
                    },
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: PlatformButton(
                    materialFlat: (context, platform) =>  MaterialFlatButtonData(splashColor: Colors.transparent),
                    child: Icon(
                      Icons.sort,
                      color: MoeStyle.defaultIconColor,
                      size: 30,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _sortDialog(model);
                    },
                  ),
                )
              ],
            ),
          ),
          FutureBuilder(
            future: MTGDB.loadCardIds(filter: model.filter, order: model.order),
            builder: (context, snapshot) {
              Widget tabContent;
              PageStorageKey scrollKey;
              int listLength = 0;
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
                listLength = (snapshot.data as List<List<String>>).length;
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
              List<Widget> slivers = [
                CupertinoSliverRefreshControl(onRefresh: () async => setState((){ MTGDB.invalidate(); }), refreshIndicatorExtent: 50, refreshTriggerPullDistance: 150),
                tabContent,
              ];
              if (listLength>0) {
                slivers.insert(1,
                  SliverToBoxAdapter(
                    child: Container(
                      height: 25,
                      child: Center(child: Text('$listLength results', style: MoeStyle.greyText)),
                    ),
                  )
                );
              }
              return Flexible(
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  key: scrollKey,
                  controller: scrollController,
                  //shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  slivers: slivers,
                ),
              );
            },
          ),
        ],
      ),
    );
  }



}
