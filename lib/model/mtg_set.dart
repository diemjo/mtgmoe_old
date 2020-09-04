import 'package:json_annotation/json_annotation.dart';

part 'mtg_set.g.dart';

@JsonSerializable(nullable: false)
class MTGSet {

  String code;

  String name;

  @JsonKey(name: 'card_count')
  int cardCount;

  @JsonKey(name: 'set_type')
  String setType;

  @JsonKey(nullable: true, name: 'released_at', toJson: dateToJson, fromJson: dateFromJson)
  DateTime releasedAt;

  @JsonKey(nullable: true, name: 'block_code')
  String blockCode;

  @JsonKey(nullable: true)
  String block;

  @JsonKey(name: 'icon_scv_uri')
  String iconScvURI;

  @JsonKey(name: 'search_uri')
  String searchURI;

  bool digital;

  MTGSet({this.code, this.name, this.cardCount, this.setType,
      this.releasedAt, this.blockCode, this.block, this.iconScvURI, this.searchURI, this.digital});

  factory MTGSet.fromJson(Map<String, dynamic> json) => _$MTGSetFromJson(json);
  Map<String, dynamic> toJson() => _$MTGSetToJson(this);
  factory MTGSet.fromMap(Map<String, dynamic> map) => MTGSetHelper.fromMap(map);
  Map<String, dynamic> toMap() => MTGSetHelper.toMap(this);

  static DateTime dateFromJson(dynamic json) {
    return DateTime.parse(json);
  }

  static Map<String, dynamic> dateToJson(DateTime releasedAt) {
    return { 'release_at': '${releasedAt.year}-${releasedAt.month >= 10 ? '' : '0'}${releasedAt.month}-${releasedAt.day >= 10 ? '' : '0' }${releasedAt.day}' };
  }
}

class MTGSetHelper {
  static Map<String, dynamic> toMap(MTGSet set) {
    return {
      'code': set.code,
      'name': set.name,
      'cardCount': set.cardCount,
      'setType': set.setType,
      'releasedAt': set.releasedAt != null ? '${set.releasedAt.year}-${set.releasedAt.month >= 10 ? '' : '0'}${set.releasedAt.month}-${set.releasedAt.day >= 10 ? '' : '0' }${set.releasedAt.day}' : null,
      'blockCode': set.blockCode,
      'block': set.block,
      'iconScvURI': set.iconScvURI,
      'searchURI': set.searchURI,
      'digital': set.digital ? 1 : 0,
    };
  }

  static MTGSet fromMap(Map<String, dynamic> map) {
    return MTGSet(
      code: map['code'],
      name: map['name'],
      cardCount: map['cardCount'],
      setType: map['setType'],
      releasedAt: DateTime.parse(map['releasedAt'] as String),
      blockCode: map['blockCode'],
      block: map['block'],
      iconScvURI: map['iconScvURI'],
      searchURI: map['searchURI'],
      digital: map['digital'] == 1,
    );
  }
}