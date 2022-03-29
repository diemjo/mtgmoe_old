// ignore_for_file: deprecated_member_use

import 'package:json_annotation/json_annotation.dart';

part 'mtg_card_image_uris.g.dart';

@JsonSerializable(nullable: true)
class MTGCardImageURIs {

  @JsonKey(nullable: true)
  String? png;

  @JsonKey(nullable: true, name: 'border_crop')
  String? borderCrop;

  @JsonKey(nullable: true, name: 'art_crop')
  String? artCrop;

  @JsonKey(nullable: true)
  String? large;

  @JsonKey(nullable: true)
  String? normal;

  @JsonKey(nullable: true)
  String? small;


  MTGCardImageURIs({this.png, this.borderCrop, this.artCrop, this.large,
      this.normal, this.small});

  factory MTGCardImageURIs.fromJson(Map<String, dynamic> json) => _$MTGCardImageURIsFromJson(json);
  Map<String, dynamic> toJson() => _$MTGCardImageURIsToJson(this);
}