import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderables/reorderables.dart';

import 'package:mtgmoe/moe_style.dart';
import 'package:mtgmoe/model/order.dart';

Widget orderWidgetBuilder(BuildContext context, Animation<double> animation, Animation<double> secondAnimation, CardOrder? order) {
  return Dialog(
    child: StatefulBuilder(
      builder: (context, dialogSetState) {
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: MoeStyle.cardListDialogColor,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Color(0xffff88ff)),
            ),
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Center(
                    child: Text('CARD ORDER', style: MoeStyle.defaultBoldText)
                ),
                Divider(color: MoeStyle.dividerColor),
                Center(
                  child: Text('PRESS AND HOLD TO CHANGE ORDER', style: MoeStyle.smallText),
                ),
                Row(
                  children: [
                    Column(
                      children: List.generate(5, (index) =>
                        Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: 27,
                          child: Text('${index+1}.', style: MoeStyle.defaultBoldText),
                        )
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: 250,
                        child: ReorderableColumn(
                          scrollController: ScrollController(),
                          onReorder: (oldIndex, newIndex) {
                            dialogSetState((){
                              OrderType oldType = order!.types![oldIndex];
                              order.types!.removeAt(oldIndex);
                              order.types!.insert(newIndex, oldType);
                            });
                          },
                          children: _orderList(order!.types!, dialogSetState),
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
                          child: Text('CANCEL', style: MoeStyle.defaultBoldText),
                          onPressed: () => Navigator.of(context).pop('Cancel'),
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
                          child: Text('SORT', style: MoeStyle.defaultBoldText),
                          onPressed: () {
                            Navigator.of(context).pop('Sort');
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

List<Widget> _orderList(List<OrderType> orderTypes, void Function(void Function()) dialogSetState) {
  return List.generate(orderTypes.length, (index) =>
      Container(
        key: Key("orderKey$index"),
        height: 50,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: MoeStyle.defaultIconColor))),
        child: Row(
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(CardOrder.getOrderName(orderTypes[index]), style: MoeStyle.defaultBoldText),
                )
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: MaterialButton(
                onPressed: () {
                  dialogSetState(() {
                    orderTypes[index] = CardOrder.switchOrderDirection(orderTypes[index]);
                  });
                },
                padding: EdgeInsets.all(1),
                child: Container(
                    width: 35,
                    height: 35,
                    decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: MoeStyle.defaultIconColor), borderRadius: BorderRadius.all(Radius.circular(5)))),
                    child: Icon(CardOrder.isOrderAsc(orderTypes[index]) ? Icons.arrow_upward : Icons.arrow_downward)
                ),
              ),
            )
          ],
        ),
      ),
    growable: false,
  );
}