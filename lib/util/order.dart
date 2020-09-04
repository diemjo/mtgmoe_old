enum OrderType {
  RARITY_ASC,
  RARITY_DESC,
  CMC_ASC,
  CMC_DESC,
  DATE_ASC,
  DATE_DESC,
  NAME_ASC,
  NAME_DESC,
  NUMBER_ASC,
  NUMBER_DESC,
  NONE,
}

class CardOrder {
  OrderType type1;
  OrderType type2;
  OrderType type3;

  CardOrder({this.type1=OrderType.NONE, this.type2=OrderType.NONE, this.type3=OrderType.NONE});

  CardOrder.fromOrder(CardOrder order) {
    this.type1 = order.type1;
    this.type2 = order.type2;
    this.type3 = order.type3;
  }

  @override
  bool operator ==(Object _other) {
    if (_other is! CardOrder)
      return false;
    CardOrder other = _other;
    return type1==other.type1 &&
      type2 == other.type2 &&
      type3 == other.type3;
  }
}