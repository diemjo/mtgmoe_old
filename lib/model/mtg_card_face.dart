import 'package:json_annotation/json_annotation.dart';

import 'package:MTGMoe/model/mtg_card_image_uris.dart';

part 'mtg_card_face.g.dart';

@JsonSerializable(nullable: true)
class MTGCardFace {

  @JsonKey(nullable: true, name: 'color_identity')
  List<String> colorIdentity;

  @JsonKey(nullable: true, name: 'mana_cost')
  String manaCost;

  @JsonKey(nullable: true, name: 'image_uris')
  MTGCardImageURIs imageURIs;

  @JsonKey(nullable: true)
  String loyalty;

  String name;

  @JsonKey(nullable: true, name: 'oracle_text')
  String oracleText;

  @JsonKey(nullable: true)
  String power;

  @JsonKey(nullable: true)
  String toughness;

  @JsonKey(nullable: true, name: 'type_line', fromJson: typesFromJson, toJson: typesToJson)
  List<List<String>> types;

  MTGCardFace({this.colorIdentity, this.manaCost, this.imageURIs, this.loyalty,
      this.name, this.oracleText, this.power, this.toughness, this.types});

  factory MTGCardFace.fromJson(Map<String, dynamic> json) => _$MTGCardFaceFromJson(json);
  Map<String, dynamic> toJson() => _$MTGCardFaceToJson(this);

  static List<List<String>> typesFromJson(dynamic json) {
    String typeline = json as String;
    return typeline?.split('-')?.map((e) => e.split(' '))?.toList(growable: false);
  }

  static Map<String, dynamic> typesToJson(List<List<String>> types) {
    if (types.length>1) {
      return { 'type_line': '${types[0].join(' ')} - ${types[1].join(' ')}' };
    }
    else {
      return { 'type_line': types[0].join(' ') };
    }
  }
}