enum ColorMatch {
  EXACT,
  MIN,
  MAX,
}
class CardFilter {
  String name;
  String type;
  String subtype;
  String text;
  String set;
  String power;
  String toughness;
  List<String> rarities;
  List<String> colors = List<String>();
  ColorMatch colorMatch;

  CardFilter({this.name='', this.type='', this.subtype='', this.text='', this.set='',
      this.power='', this.toughness='', this.rarities, this.colors, this.colorMatch=ColorMatch.MIN}) {
    if (colors==null)
      colors = List<String>();
    if (rarities==null)
      rarities = ['common', 'uncommon', 'rare', 'mythic'];
  }

  CardFilter.fromFilter(CardFilter filter) {
    this.name = filter.name??'';
    this.type = filter.type??'';
    this.subtype = filter.subtype??'';
    this.text = filter.text??'';
    this.set = filter.set??'';
    this.power = filter.power??'';
    this.toughness = filter.toughness??'';
    this.rarities = filter.rarities?.toList()??List<String>();
    this.colors = filter.colors?.toList()??List<String>();
    this.colorMatch = filter.colorMatch??'';
  }

  @override
  bool operator ==(Object _other) {
    if (_other is! CardFilter)
      return false;
    CardFilter other = _other;

    bool colorsEqual = true;
    if (colors!=null && other.colors!=null) {
      if (colors.length!=other.colors.length)
        colorsEqual = false;
      else
        colorsEqual = colors.every((element) => other.colors.contains(element));
    }
    else if (colors==null && other.colors==null)
      colorsEqual = true;
    else
      colorsEqual = false;

    bool rarityEqual = true;
    if (rarities!=null && other.rarities!=null) {
      if (rarities.length!=other.rarities.length)
        rarityEqual = false;
      else
        rarityEqual = rarities.every((element) => other.rarities.contains(element));
    }
    else if (rarities==null && other.rarities==null)
      rarityEqual = true;
    else
      rarityEqual = false;

    return colorsEqual && rarityEqual &&
      name == other.name &&
      type == other.type &&
      subtype == other.subtype &&
      text == other.text &&
      set == other.set &&
      power == other.power &&
      toughness == other.power &&
      colorMatch == other.colorMatch;
  }

  void clear() {
    name = '';
    type = '';
    subtype = '';
    text = '';
    set = '';
    power = '';
    toughness = '';
    colors = List<String>();
    colorMatch = ColorMatch.MIN;
    rarities = ['common', 'uncommon', 'rare', 'mythic'];
  }

  @override
  String toString() {
    return 'CardFilter(\n'
        "name:      '$name'\n"
        "type:      '$type'\n"
        "subtype:   '$subtype'\n"
        "text:      '$text'\n"
        "power:     '$power'\n"
        "toughness: '$toughness'\n"
        "set:       '$set'\n"
        "colors:    '${colors?.join('|')}'\n"
        "match:     '$colorMatch'\n";
  }
}