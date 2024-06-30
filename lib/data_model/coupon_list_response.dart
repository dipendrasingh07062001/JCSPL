// To parse this JSON data, do
//
//     final couponListResponse = couponListResponseFromJson(jsonString);

import 'dart:convert';

CouponListResponse couponListResponseFromJson(String str) =>
    CouponListResponse.fromJson(json.decode(str));

String couponListResponseToJson(CouponListResponse data) =>
    json.encode(data.toJson());

class CouponListResponse {
  List<CouponData>? data;
  Links? links;
  Meta? meta;
  bool? success;
  int? status;

  CouponListResponse({
    this.data,
    this.links,
    this.meta,
    this.success,
    this.status,
  });

  factory CouponListResponse.fromJson(Map<String, dynamic> json) =>
      CouponListResponse(
        data: json["data"] == null
            ? []
            : List<CouponData>.from(
                json["data"]!.map((x) => CouponData.fromJson(x))),
        links: json["links"] == null ? null : Links.fromJson(json["links"]),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "links": links?.toJson(),
        "meta": meta?.toJson(),
        "success": success,
        "status": status,
      };
}

class CouponData {
  int? id;
  String? userType;
  var shopId;
  String? shopSlug;
  String? shopName;
  String? couponType;
  String? code;
  var discount;
  List<CouponProductDetail>? couponProductDetails;
  CouponDiscountDetails? couponDiscountDetails;
  String? discountType;
  int? startDate;
  int? endDate;

  CouponData({
    this.id,
    this.userType,
    this.shopId,
    this.shopName,
    this.couponType,
    this.code,
    this.discount,
    this.couponProductDetails,
    this.couponDiscountDetails,
    this.discountType,
    this.startDate,
    this.endDate,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) => CouponData(
        id: json["id"],
        userType: json["user_type"],
        shopId: json["shop_id"],
        shopName: json["shop_name"],
        couponType: json["coupon_type"],
        code: json["code"],
        discount: json["discount"],
        couponProductDetails: json["coupon_product_details"] == null
            ? []
            : List<CouponProductDetail>.from(json["coupon_product_details"]!
                .map((x) => CouponProductDetail.fromJson(x))),
        couponDiscountDetails: json["coupon_discount_details"] == null
            ? null
            : CouponDiscountDetails.fromJson(json["coupon_discount_details"]),
        discountType: json["discount_type"],
        startDate: json["start_date"],
        endDate: json["end_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "shop_id": shopId,
        "shop_name": shopName,
        "coupon_type": couponType,
        "code": code,
        "discount": discount,
        "coupon_product_details": couponProductDetails == null
            ? []
            : List<dynamic>.from(couponProductDetails!.map((x) => x.toJson())),
        "coupon_discount_details": couponDiscountDetails?.toJson(),
        "discount_type": discountType,
        "start_date": startDate,
        "end_date": endDate,
      };
}

class CouponDiscountDetails {
  String? minBuy;
  String? maxDiscount;

  CouponDiscountDetails({
    this.minBuy,
    this.maxDiscount,
  });

  factory CouponDiscountDetails.fromJson(Map<String, dynamic> json) =>
      CouponDiscountDetails(
        minBuy: json["min_buy"],
        maxDiscount: json["max_discount"],
      );

  Map<String, dynamic> toJson() => {
        "min_buy": minBuy,
        "max_discount": maxDiscount,
      };
}

class CouponProductDetail {
  var productId;

  CouponProductDetail({
    this.productId,
  });

  factory CouponProductDetail.fromJson(Map<String, dynamic> json) =>
      CouponProductDetail(
        productId: json["product_id"],
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
      };
}

class Links {
  String? first;
  String? last;
  dynamic prev;
  dynamic next;

  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        first: json["first"],
        last: json["last"],
        prev: json["prev"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "first": first,
        "last": last,
        "prev": prev,
        "next": next,
      };
}

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<Link>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: json["current_page"],
        from: json["from"],
        lastPage: json["last_page"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
        path: json["path"],
        perPage: json["per_page"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "from": from,
        "last_page": lastPage,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
        "path": path,
        "per_page": perPage,
        "to": to,
        "total": total,
      };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
