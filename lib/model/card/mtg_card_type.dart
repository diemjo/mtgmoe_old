import 'package:mtgmoe/util/extensions.dart';

class MTGCardTypes {
  List<String>? types;
  List<String>? subtypes;
  List<String>? typesBack;
  List<String>? subtypesBack;

  MTGCardTypes();

  String toJsonString() {
    String front = _frontString();
    String? back = _backString();
    return back!=null ? front + ' // ' + back : front;
  }

  String _frontString() {
    return subtypes!=null ? types!.join(' ') + ' — ' + subtypes!.join(' ') : types!.join(' ');
  }

  String? _backString() {
    if (typesBack==null) return null;
    return subtypesBack!=null ? typesBack!.join(' ') + ' — ' + subtypesBack!.join(' ') : typesBack?.join(' ');
  }

  String typesToMapString() {
    if (types==null)
      return '';
    if (typesBack!=null) {
      return types!.join(' ') + ' // ' + typesBack!.join(' ');
    }
    else {
      return types!.join(' ');
    }
  }

  String? subtypesToMapString() {
    if (typesBack!=null && subtypes!=null && subtypesBack!=null) {
      return subtypes!.join(' ') + ' // ' + subtypesBack!.join(' ');
    }
    else if (typesBack!=null && subtypes!=null) {
      return subtypes!.join(' ') + ' // ';
    }
    else if (typesBack!=null && subtypesBack!=null) {
      return ' // '+subtypesBack!.join(' ');
    }
    else {
      return subtypes?.join(' ');
    }
  }

  MTGCardTypes.fromTypesAndSubtypes(String? types, String? subtypes) {
    if (types!=null) {
      //print('types: $types');
      this.types = types.split(' // ')[0].split(' ');
      if (types.contains(' // '))
        this.typesBack = types.split(' // ')[1].split(' ');
      //print('this.types: ${this.types} + ${this.typesBack}');
    }
    if (subtypes!=null) {
      //print('subtypes $subtypes');
      this.subtypes = subtypes.split(' // ')[0].split(' ');
      if (subtypes.contains(' // '))
        this.subtypesBack = subtypes.split(' // ')[1].split(' ');
      //print('this.subtypes: ${this.subtypes} + ${this.subtypesBack}');
    }
  }

  static MTGCardTypes typesFromJson(dynamic json) {
    MTGCardTypes cardTypes = MTGCardTypes();
    if (!(json is String))
      return cardTypes;
    List<String> doubleFaceTypes = (json as String).split(' // ');
    if (doubleFaceTypes.length>0) {
      List<String> faceTypes = doubleFaceTypes[0].split(' — ');
      cardTypes.types = faceTypes.atOrNull(0)?.split(' ');
      cardTypes.subtypes = faceTypes.atOrNull(1)?.split(' ');
    }
    if (doubleFaceTypes.length>1) {
      List<String> faceTypes = doubleFaceTypes[1].split(' — ');
      cardTypes.typesBack = faceTypes.atOrNull(0)?.split(' ');
      cardTypes.subtypesBack = faceTypes.atOrNull(1)?.split(' ');
    }
    return cardTypes;
  }

  static Map<String, dynamic> typesToJson(MTGCardTypes? types) {
    return { 'type_line': types?.toJsonString() };
  }

  @override
  String toString() {
    return "$types - $subtypes\n"
        "$typesBack - $subtypesBack";
  }
}