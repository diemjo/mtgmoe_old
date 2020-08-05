// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mtg_card_prices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MTGCardPrices _$MTGCardPricesFromJson(Map<String, dynamic> json) {
  return MTGCardPrices(
    usd: json['usd'] as String,
    usdFoil: json['usd_foil'] as String,
    eur: json['eur'] as String,
  );
}

Map<String, dynamic> _$MTGCardPricesToJson(MTGCardPrices instance) =>
    <String, dynamic>{
      'usd': instance.usd,
      'usd_foil': instance.usdFoil,
      'eur': instance.eur,
    };
