// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mtg_card_face.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MTGCardFace _$MTGCardFaceFromJson(Map<String, dynamic> json) {
  return MTGCardFace(
    colorIdentity:
        (json['color_identity'] as List)?.map((e) => e as String)?.toList(),
    manaCost: json['mana_cost'] as String,
    imageURIs: json['image_uris'] == null
        ? null
        : MTGCardImageURIs.fromJson(json['image_uris'] as Map<String, dynamic>),
    loyalty: json['loyalty'] as String,
    name: json['name'] as String,
    oracleText: json['oracle_text'] as String,
    power: json['power'] as String,
    toughness: json['toughness'] as String,
    typeLine: json['type_line'] as String,
  );
}

Map<String, dynamic> _$MTGCardFaceToJson(MTGCardFace instance) =>
    <String, dynamic>{
      'color_identity': instance.colorIdentity,
      'mana_cost': instance.manaCost,
      'image_uris': instance.imageURIs,
      'loyalty': instance.loyalty,
      'name': instance.name,
      'oracle_text': instance.oracleText,
      'power': instance.power,
      'toughness': instance.toughness,
      'type_line': instance.typeLine,
    };
