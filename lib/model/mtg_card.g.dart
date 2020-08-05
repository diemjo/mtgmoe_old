// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mtg_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MTGCard _$MTGCardFromJson(Map<String, dynamic> json) {
  return MTGCard(
    multiverseIds:
        (json['multiverse_ids'] as List)?.map((e) => e as int)?.toList(),
    id: json['id'] as String,
    oracleId: json['oracle_id'] as String,
    cmc: (json['cmc'] as num).toDouble(),
    manaCost: json['mana_cost'] as String,
    colorIdentity:
        (json['color_identity'] as List)?.map((e) => e as String)?.toList(),
    cardFaces: (json['card_faces'] as List)
        ?.map((e) =>
            e == null ? null : MTGCardFace.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    keywords: (json['keywords'] as List).map((e) => e as String).toList(),
    layout: json['layout'] as String,
    name: json['name'] as String,
    oracleText: json['oracle_text'] as String,
    power: json['power'] as String,
    toughness: json['toughness'] as String,
    loyalty: json['loyalty'] as String,
    typeLine: json['type_line'] as String,
    fullArt: json['full_art'] as bool,
    imageURIs: json['image_uris'] == null
        ? null
        : MTGCardImageURIs.fromJson(json['image_uris'] as Map<String, dynamic>),
    prices: MTGCardPrices.fromJson(json['prices'] as Map<String, dynamic>),
    rarity: json['rarity'] as String,
    set: json['set'] as String,
    legalities:
        MTGCardLegalities.fromJson(json['legalities'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MTGCardToJson(MTGCard instance) => <String, dynamic>{
      'multiverse_ids': instance.multiverseIds,
      'id': instance.id,
      'oracle_id': instance.oracleId,
      'cmc': instance.cmc,
      'mana_cost': instance.manaCost,
      'color_identity': instance.colorIdentity,
      'card_faces': instance.cardFaces,
      'keywords': instance.keywords,
      'layout': instance.layout,
      'name': instance.name,
      'oracle_text': instance.oracleText,
      'power': instance.power,
      'toughness': instance.toughness,
      'loyalty': instance.loyalty,
      'type_line': instance.typeLine,
      'full_art': instance.fullArt,
      'image_uris': instance.imageURIs,
      'prices': instance.prices,
      'rarity': instance.rarity,
      'set': instance.set,
      'legalities': instance.legalities,
    };
