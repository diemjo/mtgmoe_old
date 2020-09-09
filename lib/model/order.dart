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
}

class CardOrder {
  List<OrderType> types;

  CardOrder(OrderType type1, OrderType type2, OrderType type3, OrderType type4, OrderType type5) {
    types = [type1, type2, type3, type4, type5];
    for (int i=0; i<5; i++) {
      for (int j=i+1; j<5; j++) {
        if (types[i]==types[j]) {
          print(types);
          throw Exception('CardOrder required the OrderTypes to be unique: ${types[i]} is used at least twice');
        }
      }
    }
  }

  CardOrder.fromOrder(CardOrder order) {
    types = order.types.toList();
  }

  @override
  bool operator ==(Object _other) {
    if (_other is! CardOrder)
      return false;
    CardOrder other = _other;
    for (int i=0; i<types.length; i++) {
      if (types[i]!=other.types[i])
        return false;
    }
    return true;
  }

  static OrderType switchOrderDirection(OrderType type) {
    switch (type) {
      case OrderType.DATE_ASC: return OrderType.DATE_DESC; break;
      case OrderType.DATE_DESC: return OrderType.DATE_ASC; break;
      case OrderType.RARITY_ASC: return OrderType.RARITY_DESC; break;
      case OrderType.RARITY_DESC: return OrderType.RARITY_ASC; break;
      case OrderType.NUMBER_ASC: return OrderType.NUMBER_DESC; break;
      case OrderType.NUMBER_DESC: return OrderType.NUMBER_ASC; break;
      case OrderType.CMC_ASC: return OrderType.CMC_DESC; break;
      case OrderType.CMC_DESC: return OrderType.CMC_ASC; break;
      case OrderType.NAME_ASC: return OrderType.NAME_DESC;break;
      case OrderType.NAME_DESC: return OrderType.NAME_ASC;break;
      default: throw Exception('Invalid OrderType: $type');
    }
  }

  static String getOrderName(OrderType type) {
    switch(type) {
      case OrderType.DATE_DESC:
      case OrderType.DATE_ASC:
        return "Date & Set";
      case OrderType.RARITY_DESC:
      case OrderType.RARITY_ASC:
        return "Rarity";
      case OrderType.NUMBER_DESC:
      case OrderType.NUMBER_ASC:
        return "Collector number";
      case OrderType.CMC_DESC:
      case OrderType.CMC_ASC:
        return "Mana cost";
      case OrderType.NAME_DESC:
      case OrderType.NAME_ASC:
        return "Name";
      default:
        throw Exception("Illegal OrderType: $type");
    }
  }

  static bool isOrderAsc(OrderType type) {
    return [OrderType.DATE_ASC, OrderType.RARITY_ASC, OrderType.NUMBER_ASC, OrderType.CMC_ASC, OrderType.NAME_ASC].contains(type);
  }

  static String typeToSqlString(OrderType type) {
    switch(type) {
      case OrderType.DATE_ASC:
        return "s.releasedAt ASC, s.setName DESC";
      case OrderType.DATE_DESC:
        return "s.releasedAt DESC, s.setName ASC";
      case OrderType.NAME_ASC:
        return "c.name ASC";
      case OrderType.NAME_DESC:
        return "c.name DESC";
      case OrderType.RARITY_ASC:
        return "c.rarity ASC";
      case OrderType.RARITY_DESC:
        return "c.rarity DESC";
      case OrderType.CMC_ASC:
        return "c.cmc ASC";
      case OrderType.CMC_DESC:
        return "c.cmc DESC";
      case OrderType.NUMBER_ASC:
        return "c.collectorNumber ASC";
      case OrderType.NUMBER_DESC:
        return "c.collectorNumber DESC";
      default:
        throw Exception("Illegal OrderType");
    }
  }
}