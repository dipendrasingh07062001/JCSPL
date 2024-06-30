// To parse this JSON data, do
//
//     final classifiedProductDetailsResponse = classifiedProductDetailsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:active_ecommerce_flutter/data_model/uploaded_file_list_response.dart';

ClassifiedProductDetailsResponse classifiedProductDetailsResponseFromJson(
        String str) =>
    ClassifiedProductDetailsResponse.fromJson(json.decode(str));

String classifiedProductDetailsResponseToJson(
        ClassifiedProductDetailsResponse data) =>
    json.encode(data.toJson());

class ClassifiedProductDetailsResponse {
  List<ClassifiedProductDetailsResponseDatum>? data;
  bool? success;
  int? status;

  ClassifiedProductDetailsResponse({
    this.data,
    this.success,
    this.status,
  });

  factory ClassifiedProductDetailsResponse.fromJson(
          Map<String, dynamic> json) =>
      ClassifiedProductDetailsResponse(
        data: json["data"] == null
            ? []
            : List<ClassifiedProductDetailsResponseDatum>.from(json["data"]!
                .map((x) => ClassifiedProductDetailsResponseDatum.fromJson(x))),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
        "status": status,
      };
}

class ClassifiedProductDetailsResponseDatum {
  int? id;
  String? name;
  String? addedBy;
  String? phone;
  String? condition;
  MetaImage? photos;
  MetaImage? thumbnailImage;
  List<String>? tags;
  String? location;
  String? unitPrice;
  String? unit;
  String? description;
  String? videoLink;
  Brand? brand;
  String? category;
  String? link;
  dynamic metaTitle;
  dynamic metaDescription;
  MetaImage? metaImage;
  MetaImage? pdf;

  ClassifiedProductDetailsResponseDatum({
    this.id,
    this.name,
    this.addedBy,
    this.phone,
    this.condition,
    this.photos,
    this.thumbnailImage,
    this.tags,
    this.location,
    this.unitPrice,
    this.unit,
    this.description,
    this.videoLink,
    this.brand,
    this.category,
    this.link,
    this.metaTitle,
    this.metaDescription,
    this.metaImage,
    this.pdf,
  });

  factory ClassifiedProductDetailsResponseDatum.fromJson(
          Map<String, dynamic> json) =>
      ClassifiedProductDetailsResponseDatum(
        id: json["id"],
        name: json["name"],
        addedBy: json["added_by"],
        phone: json["phone"],
        condition: json["condition"],
        photos:
            json["photos"] == null ? null : MetaImage.fromJson(json["photos"]),
        thumbnailImage: json["thumbnail_image"] == null
            ? null
            : MetaImage.fromJson(json["thumbnail_image"]),
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"]!.map((x) => x)),
        location: json["location"],
        unitPrice: json["unit_price"],
        unit: json["unit"],
        description: json["description"],
        videoLink: json["video_link"],
        brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
        category: json["category"],
        link: json["link"],
        metaTitle: json["meta_title"],
        metaDescription: json["meta_description"],
        metaImage: json["meta_image"] == null
            ? null
            : MetaImage.fromJson(json["meta_image"]),
        pdf: json["pdf"] == null ? null : MetaImage.fromJson(json["pdf"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "added_by": addedBy,
        "phone": phone,
        "condition": condition,
        "photos": photos?.toJson(),
        "thumbnail_image": thumbnailImage?.toJson(),
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
        "location": location,
        "unit_price": unitPrice,
        "unit": unit,
        "description": description,
        "video_link": videoLink,
        "brand": brand?.toJson(),
        "category": category,
        "link": link,
        "meta_title": metaTitle,
        "meta_description": metaDescription,
        "meta_image": metaImage?.toJson(),
        "pdf": pdf?.toJson(),
      };
}

class Brand {
  int? id;
  String? name;
  String? logo;
  String? slug;

  Brand({
    this.id,
    this.slug,
    this.name,
    this.logo,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        slug: json["slug"],
        name: json["name"],
        logo: json["logo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
        "logo": logo,
      };
}

class MetaImage {
  List<FileInfo>? data;

  MetaImage({
    this.data,
  });

  factory MetaImage.fromJson(Map<String, dynamic> json) => MetaImage(
        data: json["data"] == null
            ? []
            : List<FileInfo>.from(
                json["data"]!.map((x) => FileInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}
