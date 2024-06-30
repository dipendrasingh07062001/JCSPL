// To parse this JSON data, do
//
//     final catResponse = catResponseFromJson(jsonString);

import 'dart:convert';

CatResponse catResponseFromJson(String str) =>
    CatResponse.fromJson(json.decode(str));

String catResponseToJson(CatResponse data) => json.encode(data.toJson());

class CatResponse {
  List<CatData>? data;

  CatResponse({
    this.data,
  });

  factory CatResponse.fromJson(Map<String, dynamic> json) => CatResponse(
        data: json["data"] == null
            ? []
            : List<CatData>.from(json["data"]!.map((x) => CatData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CatData {
  int? id;
  int? parentId;
  int? level;
  String? name;
  String? banner;
  String? icon;
  bool? featured;
  bool? digital;
  List<CatData>? child;

  CatData({
    this.id,
    this.parentId,
    this.level,
    this.name,
    this.banner,
    this.icon,
    this.featured,
    this.digital,
    this.child,
  });

  factory CatData.fromJson(Map<String, dynamic> json) => CatData(
        id: json["id"],
        parentId: json["parent_id"],
        level: json["level"],
        name: json["name"],
        banner: json["banner"],
        icon: json["icon"],
        featured: json["featured"],
        digital: json["digital"],
        child: json["child"] == null
            ? []
            : List<CatData>.from(
                json["child"]!.map((x) => CatData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "level": level,
        "name": name,
        "banner": banner,
        "icon": icon,
        "featured": featured,
        "digital": digital,
        "child": child == null
            ? []
            : List<dynamic>.from(child!.map((x) => x.toJson())),
      };
}
