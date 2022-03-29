import 'package:json_annotation/json_annotation.dart';

part 'mtg_card_legalities.g.dart';

@JsonSerializable(nullable: true)
class MTGCardLegalities {

  @JsonKey(nullable: true)
  String? standard;

  @JsonKey(nullable: true)
  String? future;

  @JsonKey(nullable: true)
  String? historic;

  @JsonKey(nullable: true)
  String? pioneer;

  @JsonKey(nullable: true)
  String? modern;

  @JsonKey(nullable: true)
  String? legacy;

  @JsonKey(nullable: true)
  String? pauper;

  @JsonKey(nullable: true)
  String? vintage;

  @JsonKey(nullable: true)
  String? penny;

  @JsonKey(nullable: true)
  String? commander;

  @JsonKey(nullable: true)
  String? brawl;

  @JsonKey(nullable: true)
  String? duel;

  @JsonKey(nullable: true)
  String? oldschool;


  MTGCardLegalities({
      this.standard,
      this.future,
      this.historic,
      this.pioneer,
      this.modern,
      this.legacy,
      this.pauper,
      this.vintage,
      this.penny,
      this.commander,
      this.brawl,
      this.duel,
      this.oldschool});

  factory MTGCardLegalities.fromJson(Map<String, dynamic> json) => _$MTGCardLegalitiesFromJson(json);
  Map<String, dynamic> toJson() => _$MTGCardLegalitiesToJson(this);
}