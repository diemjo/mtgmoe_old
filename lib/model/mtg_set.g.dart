// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mtg_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MTGSet _$MTGSetFromJson(Map<String, dynamic> json) {
  return MTGSet(
    code: json['code'] as String,
    name: json['name'] as String,
    cardCount: json['card_count'] as int,
    setType: json['set_type'] as String,
    releasedAt: MTGSet.dateFromJson(json['released_at']),
    blockCode: json['block_code'] as String,
    block: json['block'] as String,
    iconScvURI: json['icon_scv_uri'] as String,
    searchURI: json['search_uri'] as String,
  );
}

Map<String, dynamic> _$MTGSetToJson(MTGSet instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'card_count': instance.cardCount,
      'set_type': instance.setType,
      'released_at': MTGSet.dateToJson(instance.releasedAt),
      'block_code': instance.blockCode,
      'block': instance.block,
      'icon_scv_uri': instance.iconScvURI,
      'search_uri': instance.searchURI,
    };
