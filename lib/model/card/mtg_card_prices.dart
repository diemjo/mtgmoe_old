import 'package:json_annotation/json_annotation.dart';

part 'mtg_card_prices.g.dart';

@JsonSerializable(nullable: true)
class MTGCardPrices {

  @JsonKey(nullable: true)
  String? usd;

  @JsonKey(nullable: true, name: 'usd_foil')
  String? usdFoil;

  @JsonKey(nullable: true)
  String? eur;


  MTGCardPrices({this.usd, this.usdFoil, this.eur});

  factory MTGCardPrices.fromJson(Map<String, dynamic> json) => _$MTGCardPricesFromJson(json);
  Map<String, dynamic> toJson() => _$MTGCardPricesToJson(this);
}