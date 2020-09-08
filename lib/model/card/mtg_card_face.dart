import 'package:json_annotation/json_annotation.dart';

import 'package:MTGMoe/model/card/mtg_card_image_uris.dart';
import 'package:MTGMoe/model/card/mtg_card_type.dart';

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

  @JsonKey(nullable: true, name: 'type_line', fromJson: MTGCardTypes.typesFromJson, toJson: MTGCardTypes.typesToJson)
  MTGCardTypes types;

  MTGCardFace({this.colorIdentity, this.manaCost, this.imageURIs, this.loyalty,
      this.name, this.oracleText, this.power, this.toughness, this.types});

  factory MTGCardFace.fromJson(Map<String, dynamic> json) => _$MTGCardFaceFromJson(json);
  Map<String, dynamic> toJson() => _$MTGCardFaceToJson(this);
}