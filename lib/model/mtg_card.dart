import 'package:MTGMoe/model/mtg_card_legalities.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:MTGMoe/model/mtg_card_face.dart';
import 'package:MTGMoe/model/mtg_card_image_uris.dart';
import 'package:MTGMoe/model/mtg_card_prices.dart';

part 'mtg_card.g.dart';

@JsonSerializable(nullable: false)
class MTGCard {

  @JsonKey(nullable: true, name: 'multiverse_ids')
  List<int> multiverseIds;

  String id;

  @JsonKey(name: 'oracle_id')
  String oracleId;

  @JsonKey(name: 'collector_number')
  String collectorNumber;

  double cmc;

  @JsonKey(nullable: true, name: 'mana_cost')
  String manaCost;

  @JsonKey(nullable: true, name: 'color_identity')
  List<String> colorIdentity;

  @JsonKey(nullable: true, name: 'card_faces')
  List<MTGCardFace> cardFaces;

  List<String> keywords;

  String layout;

  String name;

  @JsonKey(nullable: true, name: 'oracle_text')
  String oracleText;

  @JsonKey(nullable: true)
  String power;

  @JsonKey(nullable: true)
  String toughness;

  @JsonKey(nullable: true)
  String loyalty;

  @JsonKey(nullable: true, name: 'type_line', fromJson: typesFromJson, toJson: typesToJson)
  List<List<String>> types;

  @JsonKey(name: 'full_art')
  bool fullArt;

  @JsonKey(nullable: true, name: 'image_uris')
  MTGCardImageURIs imageURIs;

  MTGCardPrices prices;

  @JsonKey(toJson: rarityToJson, fromJson: rarityFromJson)
  int rarity;

  String set;

  MTGCardLegalities legalities;


  MTGCard({
      this.multiverseIds,
      this.id,
      this.oracleId,
      this.collectorNumber,
      this.cmc,
      this.manaCost,
      this.colorIdentity,
      this.cardFaces,
      this.keywords,
      this.layout,
      this.name,
      this.oracleText,
      this.power,
      this.toughness,
      this.loyalty,
      this.types,
      this.fullArt,
      this.imageURIs,
      this.prices,
      this.rarity,
      this.set,
      this.legalities});

  factory MTGCard.fromJson(Map<String, dynamic> json) => _$MTGCardFromJson(json);
  Map<String, dynamic> toJson() => _$MTGCardToJson(this);
  factory MTGCard.fromMap(Map<String, dynamic> map) => MTGCardHelper.fromMap(map);
  Map<String, dynamic> toMap() => MTGCardHelper.toMap(this);

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
    return {
      'id': card.id,
      'multiverseId0': card.multiverseIds != null && card.multiverseIds.length>0 ? card.multiverseIds[0] : null,
      'multiverseId1': card.multiverseIds != null && card.multiverseIds.length>1 ? card.multiverseIds[1] : null,
      'oracleId': card.oracleId,
      'collectorNumber': card.collectorNumber,
      'cmc': card.cmc,
      'manaCost': card.manaCost,
      'colorIdentity': card.colorIdentity.join('|'),
      'keywords': card.keywords.join('|'),
      'layout': card.layout,
      'name': card.name,
      'oracleText': card.oracleText,
      'power': card.power,
      'toughness': card.toughness,
      'loyalty': card.loyalty,
      'types': card.types.length>1 ? '${card.types[0].join(' ')} - ${card.types[1].join(' ')}' : card.types[0]?.join(' '),
      'fullArt': card.fullArt ? 1 : 0,
      'imageURI_png': card.imageURIs?.png,
      'imageURI_borderCrop': card.imageURIs?.png,
      'imageURI_artCrop': card.imageURIs?.artCrop,
      'imageURI_large': card.imageURIs?.large,
      'imageURI_normal': card.imageURIs?.normal,
      'imageURI_small': card.imageURIs?.small,
      'price_usd': card.prices.usd,
      'price_usdFoil': card.prices.usdFoil,
      'price_eur': card.prices.eur,
      'rarity': card.rarity,
      'cardSet': card.set,
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
      'cardFace0_colorIdentity': card.cardFaces!=null && card.cardFaces[0].colorIdentity!=null ? card.cardFaces[0].colorIdentity.join('|') : null,
      'cardFace0_manaCost': card.cardFaces!=null ? card.cardFaces[0].manaCost : null,
      'cardFace0_imageURI_png': card.cardFaces!=null && card.cardFaces[0].imageURIs!=null ? card.cardFaces[0].imageURIs.png : null,
      'cardFace0_imageURI_borderCrop': card.cardFaces!=null && card.cardFaces[0].imageURIs!=null ? card.cardFaces[0].imageURIs.borderCrop : null,
      'cardFace0_imageURI_artCrop': card.cardFaces!=null && card.cardFaces[0].imageURIs!=null ? card.cardFaces[0].imageURIs.artCrop : null,
      'cardFace0_imageURI_large': card.cardFaces!=null && card.cardFaces[0].imageURIs!=null ? card.cardFaces[0].imageURIs.large : null,
      'cardFace0_imageURI_normal': card.cardFaces!=null && card.cardFaces[0].imageURIs!=null ? card.cardFaces[0].imageURIs.normal : null,
      'cardFace0_imageURI_small': card.cardFaces!=null && card.cardFaces[0].imageURIs!=null ? card.cardFaces[0].imageURIs.small : null,
      'cardFace0_loyalty': card.cardFaces!=null ? card.cardFaces[0].loyalty : null,
      'cardFace0_name': card.cardFaces!=null ? card.cardFaces[0].name : null,
      'cardFace0_oracleText': card.cardFaces!=null ? card.cardFaces[0].oracleText : null,
      'cardFace0_power': card.cardFaces!=null ? card.cardFaces[0].power : null,
      'cardFace0_toughness': card.cardFaces!=null ? card.cardFaces[0].toughness : null,
      'cardFace0_types': card.cardFaces!=null ? ((card.cardFaces[0].types?.length??0)>0 ? '${card.cardFaces[0].types[0].join(' ')} - ${card.cardFaces[0].types[1].join(' ')}' : card.cardFaces[0].types[0]?.join(' ')) : null,
      'cardFace1_colorIdentity': card.cardFaces!=null && card.cardFaces[1].colorIdentity!=null ? card.cardFaces[1].colorIdentity.join('|') : null,
      'cardFace1_manaCost': card.cardFaces!=null ? card.cardFaces[1].manaCost : null,
      'cardFace1_imageURI_png': card.cardFaces!=null && card.cardFaces[1].imageURIs!=null ? card.cardFaces[1].imageURIs.png : null,
      'cardFace1_imageURI_borderCrop': card.cardFaces!=null && card.cardFaces[1].imageURIs!=null ? card.cardFaces[1].imageURIs.borderCrop : null,
      'cardFace1_imageURI_artCrop': card.cardFaces!=null && card.cardFaces[1].imageURIs!=null ? card.cardFaces[1].imageURIs.artCrop : null,
      'cardFace1_imageURI_large': card.cardFaces!=null && card.cardFaces[1].imageURIs!=null ? card.cardFaces[1].imageURIs.large : null,
      'cardFace1_imageURI_normal': card.cardFaces!=null && card.cardFaces[1].imageURIs!=null ? card.cardFaces[1].imageURIs.normal : null,
      'cardFace1_imageURI_small': card.cardFaces!=null && card.cardFaces[1].imageURIs!=null ? card.cardFaces[1].imageURIs.small : null,
      'cardFace1_loyalty': card.cardFaces!=null ? card.cardFaces[1].loyalty : null,
      'cardFace1_name': card.cardFaces!=null ? card.cardFaces[1].name : null,
      'cardFace1_oracleText': card.cardFaces!=null ? card.cardFaces[1].oracleText : null,
      'cardFace1_power': card.cardFaces!=null ? card.cardFaces[1].power : null,
      'cardFace1_toughness': card.cardFaces!=null ? card.cardFaces[1].toughness : null,
      'cardFace1_types': card.cardFaces!=null ? ((card.cardFaces[1].types?.length??0)>0 ? '${card.cardFaces[1].types[0].join(' ')} - ${card.cardFaces[1].types[1].join(' ')}' : card.cardFaces[1].types[0]?.join(' ')) : null,
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
      types: (map['types'] as String)?.split('-')?.map((e) => e.split(' '))?.toList(growable: false),
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
      set: map['cardSet'],
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
      cardFaces: (map['cardFace0_name']!=null) ? [
        MTGCardFace(
          colorIdentity: (map['cardFace0_colorIdentity'] as String)!=null ? (map['cardFace0_colorIdentity'] as String).split('|') : [],
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
          types: (map['cardFace0_types'] as String)?.split('-')?.map((e) => e.split(' '))?.toList(growable: false),
        ),
        MTGCardFace(
          colorIdentity: (map['cardFace1_colorIdentity'] as String)!=null ? (map['cardFace1_colorIdentity'] as String).split('|') : [],
          manaCost: map['cardFace1_manaCost'],
          imageURIs: (map['cardFace1_imageURI_png']!=null) ? MTGCardImageURIs(
            png: map['cardFace0_imageURI_png'],
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
          types: (map['cardFace1_types'] as String)?.split('-')?.map((e) => e.split(' '))?.toList(growable: false),
        )
      ] : [],
    );
  }
}