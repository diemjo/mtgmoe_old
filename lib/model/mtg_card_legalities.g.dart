// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mtg_card_legalities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MTGCardLegalities _$MTGCardLegalitiesFromJson(Map<String, dynamic> json) {
  return MTGCardLegalities(
    standard: json['standard'] as String,
    future: json['future'] as String,
    historic: json['historic'] as String,
    pioneer: json['pioneer'] as String,
    modern: json['modern'] as String,
    legacy: json['legacy'] as String,
    pauper: json['pauper'] as String,
    vintage: json['vintage'] as String,
    penny: json['penny'] as String,
    commander: json['commander'] as String,
    brawl: json['brawl'] as String,
    duel: json['duel'] as String,
    oldschool: json['oldschool'] as String,
  );
}

Map<String, dynamic> _$MTGCardLegalitiesToJson(MTGCardLegalities instance) =>
    <String, dynamic>{
      'standard': instance.standard,
      'future': instance.future,
      'historic': instance.historic,
      'pioneer': instance.pioneer,
      'modern': instance.modern,
      'legacy': instance.legacy,
      'pauper': instance.pauper,
      'vintage': instance.vintage,
      'penny': instance.penny,
      'commander': instance.commander,
      'brawl': instance.brawl,
      'duel': instance.duel,
      'oldschool': instance.oldschool,
    };
