import 'package:json_annotation/json_annotation.dart';

import 'package:mtgmoe/util/extensions.dart';
import 'package:mtgmoe/model/card/mtg_card_face.dart';
import 'package:mtgmoe/model/card/mtg_card_image_uris.dart';
import 'package:mtgmoe/model/card/mtg_card_legalities.dart';
import 'package:mtgmoe/model/card/mtg_card_prices.dart';
import 'package:mtgmoe/model/card/mtg_card_type.dart';

part 'mtg_card.g.dart';

@JsonSerializable(nullable: false)
class MTGCard {

  @JsonKey(nullable: true, name: 'multiverse_ids')
  List<int?>? multiverseIds;

  String id;

  @JsonKey(name: 'oracle_id')
  String? oracleId;

  @JsonKey(name: 'collector_number')
  String collectorNumber;

  double? cmc;

  @JsonKey(nullable: true, name: 'mana_cost')
  String? manaCost;

  @JsonKey(nullable: true, name: 'color_identity')
  List<String>? colorIdentity;

  @JsonKey(nullable: true, name: 'card_faces')
  List<MTGCardFace>? cardFaces;

  List<String> keywords;

  String layout;

  String name;

  @JsonKey(nullable: true, name: 'oracle_text')
  String? oracleText;

  @JsonKey(nullable: true)
  String? power;

  @JsonKey(nullable: true)
  String? toughness;

  @JsonKey(nullable: true)
  String? loyalty;

  @JsonKey(name: 'type_line', fromJson: MTGCardTypes.typesFromJson, toJson: MTGCardTypes.typesToJson)
  MTGCardTypes types;

  @JsonKey(name: 'full_art')
  bool fullArt;

  @JsonKey(nullable: true, name: 'image_uris')
  MTGCardImageURIs? imageURIs;

  MTGCardPrices? prices;

  @JsonKey(toJson: rarityToJson, fromJson: rarityFromJson)
  int rarity;

  @JsonKey(name: 'set')
  String setCode;

  @JsonKey(name: 'set_name')
  String setName;

  MTGCardLegalities legalities;

  @JsonKey(name: 'rulings_uri')
  String rulingsURI;

  @JsonKey(name: 'scryfall_uri')
  String scryfallURI;

  MTGCard({
      this.multiverseIds,
      required this.id,
      required this.oracleId,
      required this.collectorNumber,
      required this.cmc,
      this.manaCost,
      this.colorIdentity,
      this.cardFaces,
      required this.keywords,
      required this.layout,
      required this.name,
      this.oracleText,
      this.power,
      this.toughness,
      this.loyalty,
      required this.types,
      required this.fullArt,
      this.imageURIs,
      this.prices,
      required this.rarity,
      required this.setCode,
      required this.setName,
      required this.scryfallURI,
      required this.rulingsURI,
      required this.legalities});

  factory MTGCard.fromJson(Map<String, dynamic> json) => _$MTGCardFromJson(json);
  Map<String, dynamic> toJson() => _$MTGCardToJson(this);
  factory MTGCard.fromMap(Map<String, dynamic> map) => MTGCardHelper.fromMap(map);
  Map<String, dynamic> toMap() => MTGCardHelper.toMap(this);

  static int rarityFromJson(dynamic json) {
    return rarityFromString(json as String);
  }

  static int rarityFromString(String rarity) {
    if (rarity=='common') return 1;
    else if (rarity=='uncommon') return 2;
    else if (rarity=='rare') return 3;
    else if (rarity=='mythic') return 4;
    else return 0;
  }

  static Map<String, dynamic> rarityToJson(int rarity) {
    switch(rarity) {
      case 1: return { 'rarity': 'common' };
      case 2: return { 'rarity': 'uncommon' };
      case 3: return { 'rarity': 'rare' };
      case 4: return { 'rarity': 'mythic' };
      default: return { 'rarity': 'none' };
    }
  }
}

class MTGCardHelper {
  static Map<String, dynamic> toMap(MTGCard card) {
    //print(card.name);
    return {
      'id': card.id,
      'multiverseId0': card.multiverseIds?.atOrNull(0),
      'multiverseId1': card.multiverseIds?.atOrNull(1),
      'oracleId': card.oracleId,
      'collectorNumber': '0'*(3-(card.collectorNumber.length))+(card.collectorNumber),
      'cmc': card.cmc,
      'manaCost': card.manaCost,
      'colorIdentity': card.colorIdentity!.join('|'),
      'keywords': card.keywords.join('|'),
      'layout': card.layout,
      'name': card.name,
      'oracleText': card.oracleText,
      'power': card.power,
      'toughness': card.toughness,
      'loyalty': card.loyalty,
      'types': card.types.typesToMapString(),
      'subtypes': card.types.subtypesToMapString(),
      'fullArt': card.fullArt? 1 : 0,
      'imageURI_png': card.imageURIs?.png,
      'imageURI_borderCrop': card.imageURIs?.png,
      'imageURI_artCrop': card.imageURIs?.artCrop,
      'imageURI_large': card.imageURIs?.large,
      'imageURI_normal': card.imageURIs?.normal,
      'imageURI_small': card.imageURIs?.small,
      'price_usd': card.prices?.usd,
      'price_usdFoil': card.prices?.usdFoil,
      'price_eur': card.prices?.eur,
      'rarity': card.rarity,
      'setCode': card.setCode,
      'setName': card.setName,
      'legalities_standard': card.legalities.standard,
      'legalities_future': card.legalities.future,
      'legalities_historic': card.legalities.historic,
      'legalities_pioneer': card.legalities.pioneer,
      'legalities_modern': card.legalities.modern,
      'legalities_legacy': card.legalities.legacy,
      'legalities_pauper': card.legalities.pauper,
      'legalities_vintage': card.legalities.vintage,
      'legalities_penny': card.legalities.penny,
      'legalities_commander': card.legalities.commander,
      'legalities_brawl': card.legalities.brawl,
      'legalities_duel': card.legalities.duel,
      'legalities_oldschool': card.legalities.oldschool,
      'scryfallURI': card.scryfallURI,
      'rulingsURI': card.rulingsURI,
      'cardFace0_colorIdentity': card.cardFaces?.atOrNull(0)?.colorIdentity?.join('|'),
      'cardFace0_manaCost': card.cardFaces?.atOrNull(0)?.manaCost,
      'cardFace0_imageURI_png': card.cardFaces?.atOrNull(0)?.imageURIs?.png,
      'cardFace0_imageURI_borderCrop': card.cardFaces?.atOrNull(0)?.imageURIs?.borderCrop,
      'cardFace0_imageURI_artCrop': card.cardFaces?.atOrNull(0)?.imageURIs?.artCrop,
      'cardFace0_imageURI_large': card.cardFaces?.atOrNull(0)?.imageURIs?.large,
      'cardFace0_imageURI_normal': card.cardFaces?.atOrNull(0)?.imageURIs?.normal,
      'cardFace0_imageURI_small': card.cardFaces?.atOrNull(0)?.imageURIs?.small,
      'cardFace0_loyalty': card.cardFaces?.atOrNull(0)?.loyalty,
      'cardFace0_name': card.cardFaces?.atOrNull(0)?.name,
      'cardFace0_oracleText': card.cardFaces?.atOrNull(0)?.oracleText,
      'cardFace0_power': card.cardFaces?.atOrNull(0)?.power,
      'cardFace0_toughness': card.cardFaces?.atOrNull(0)?.toughness,
      'cardFace0_types': card.cardFaces?.atOrNull(0)?.types?.typesToMapString(),
      'cardFace0_subtypes': card.cardFaces?.atOrNull(0)?.types?.subtypesToMapString(),
      'cardFace1_colorIdentity': card.cardFaces?.atOrNull(1)?.colorIdentity?.join('|'),
      'cardFace1_manaCost': card.cardFaces?.atOrNull(1)?.manaCost,
      'cardFace1_imageURI_png': card.cardFaces?.atOrNull(1)?.imageURIs?.png,
      'cardFace1_imageURI_borderCrop': card.cardFaces?.atOrNull(1)?.imageURIs?.borderCrop,
      'cardFace1_imageURI_artCrop': card.cardFaces?.atOrNull(1)?.imageURIs?.artCrop,
      'cardFace1_imageURI_large': card.cardFaces?.atOrNull(1)?.imageURIs?.large,
      'cardFace1_imageURI_normal': card.cardFaces?.atOrNull(1)?.imageURIs?.normal,
      'cardFace1_imageURI_small': card.cardFaces?.atOrNull(1)?.imageURIs?.small,
      'cardFace1_loyalty': card.cardFaces?.atOrNull(1)?.loyalty,
      'cardFace1_name': card.cardFaces?.atOrNull(1)?.name,
      'cardFace1_oracleText': card.cardFaces?.atOrNull(1)?.oracleText,
      'cardFace1_power': card.cardFaces?.atOrNull(1)?.power,
      'cardFace1_toughness': card.cardFaces?.atOrNull(1)?.toughness,
      'cardFace1_types': card.cardFaces?.atOrNull(1)?.types?.typesToMapString(),
      'cardFace1_subtypes': card.cardFaces?.atOrNull(1)?.types?.subtypesToMapString(),
    };
  }
  static MTGCard fromMap(Map<String, dynamic> map) {
    return MTGCard(
      id: map['id'],
      multiverseIds: (map['multiverseId0']!=null) ? ((map['multiverseId1']!=null) ? ([map['multiverseId0'] as int, map['multiverseId1'] as int]) : [map['multiverseId0']]) : [],
      oracleId: map['oracleId'],
      collectorNumber: map['collectorNumber'],
      cmc: map['cmc'],
      manaCost: map['manaCost'],
      colorIdentity: (map['colorIdentity'] as String).split('|'),
      keywords: (map['keywords'] as String).split('|'),
      layout: map['layout'],
      name: map['name'],
      oracleText: map['oracleText'],
      power: map['power'],
      toughness: map['toughness'],
      loyalty: map['loyalty'],
      types: MTGCardTypes.fromTypesAndSubtypes(map['types'], map['subtypes']),
      fullArt: map['fullArt'] == 1,
      imageURIs: map['imageURI_png']!=null ? MTGCardImageURIs(
        png: map['imageURI_png'],
        borderCrop: map['imageURI_borderCrop'],
        artCrop: map['imageURI_artCrop'],
        large: map['imageURI_large'],
        normal: map['imageURI_normal'],
        small: map['imageURI_small'],
      ) : null,
      prices: map['price_usd']!=null ? MTGCardPrices(
        usd: map['price_usd'],
        usdFoil: map['price_usdFoil'],
        eur: map['price_eur'],
      ) : null,
      rarity: map['rarity'],
      setCode: map['setCode'],
      setName: map['setName'],
      legalities: MTGCardLegalities(
        standard: map['legalities_standard'],
        future: map['legalities_future'],
        historic: map['legalities_historic'],
        pioneer: map['legalities_pioneer'],
        modern: map['legalities_modern'],
        legacy: map['legalities_legacy'],
        pauper: map['legalities_pauper'],
        vintage: map['legalities_vintage'],
        penny: map['legalities_penny'],
        commander: map['legalities_commander'],
        brawl: map['legalities_brawl'],
        duel: map['legalities_duel'],
        oldschool: map['legalities_oldschool'],
      ),
      scryfallURI: map['scryfallURI'],
      rulingsURI: map['rulingsURI'],
      cardFaces: (map['cardFace0_name']!=null) ? [
        MTGCardFace(
          colorIdentity: (map['cardFace0_colorIdentity'] as String?)!=null ? (map['cardFace0_colorIdentity'] as String).split('|') : null,
          manaCost: map['cardFace0_manaCost'],
          imageURIs: (map['cardFace0_imageURI_png']!=null) ? MTGCardImageURIs(
            png: map['cardFace0_imageURI_png'],
            borderCrop: map['cardFace0_imageURI_borderCrop'],
            artCrop: map['cardFace0_imageURI_artCrop'],
            large: map['cardFace0_imageURI_large'],
            normal: map['cardFace0_imageURI_normal'],
            small: map['cardFace0_imageURI_small'],
          ) : null,
          loyalty: map['cardFace0_loyalty'],
          name: map['cardFace0_name'],
          oracleText: map['cardFace0_oracleText'],
          power: map['cardFace0_power'],
          toughness: map['cardFace0_toughness'],
          types: MTGCardTypes.fromTypesAndSubtypes(map['cardFace0_types'], map['cardFace0_subtypes']),
        ),
        MTGCardFace(
          colorIdentity: (map['cardFace1_colorIdentity'] as String?)!=null ? (map['cardFace1_colorIdentity'] as String).split('|') : null,
          manaCost: map['cardFace1_manaCost'],
          imageURIs: (map['cardFace1_imageURI_png']!=null) ? MTGCardImageURIs(
            png: map['cardFace1_imageURI_png'],
            borderCrop: map['cardFace1_imageURI_borderCrop'],
            artCrop: map['cardFace1_imageURI_artCrop'],
            large: map['cardFace1_imageURI_large'],
            normal: map['cardFace1_imageURI_normal'],
            small: map['cardFace1_imageURI_small'],
          ) : null,
          loyalty: map['cardFace1_loyalty'],
          name: map['cardFace1_name'],
          oracleText: map['cardFace1_oracleText'],
          power: map['cardFace1_power'],
          toughness: map['cardFace1_toughness'],
          types: MTGCardTypes.fromTypesAndSubtypes(map['cardFace1_types'], map['cardFace1_subtypes']),
        )
      ] : [],
    );
  }
}