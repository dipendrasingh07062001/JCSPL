
import 'dart:convert';

FollowedSellersResponse followedSellersResponseFromJson(String str) => FollowedSellersResponse.fromJson(json.decode(str));

String followedSellersResponseToJson(FollowedSellersResponse data) => json.encode(data.toJson());

class FollowedSellersResponse {
  FollowedSellersResponse({
     this.data,
     this.links,
     this.meta,
  });

  List<SellerInfo>? data;
  Links? links;
  Meta? meta;

  factory FollowedSellersResponse.fromJson(Map<String, dynamic> json) => FollowedSellersResponse(
    data: List<SellerInfo>.from(json["data"].map((x) => SellerInfo.fromJson(x))),
    links: Links.fromJson(json["links"]),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "links": links!.toJson(),
    "meta": meta!.toJson(),
  };
}

class SellerInfo {
  SellerInfo({
     this.shopId,
     this.shopSlug,
     this.shopName,
     this.shopUrl,
     this.shopRating,
     this.shopNumOfReviews,
     this.shopLogo,
  });

  int? shopId;
  String? shopSlug;
  String? shopName;
  String? shopUrl;
  var shopRating;
  int? shopNumOfReviews;
  String? shopLogo;

  factory SellerInfo.fromJson(Map<String, dynamic> json) => SellerInfo(
    shopId: json["shop_id"],
    shopSlug: json["shop_slug"],
    shopName: json["shop_name"],
    shopUrl: json["shop_url"],
    shopRating: json["shop_rating"],
    shopNumOfReviews: json["shop_num_of_reviews"],
    shopLogo: json["shop_logo"],
  );

  Map<String, dynamic> toJson() => {
    "shop_id": shopId,
    "shop_slug": shopSlug,
    "shop_name": shopName,
    "shop_url": shopUrl,
    "shop_rating": shopRating,
    "shop_num_of_reviews": shopNumOfReviews,
    "shop_logo": shopLogo,
  };
}

class Links {
  Links({
     this.first,
     this.last,
    this.prev,
    this.next,
  });

  String? first;
  String? last;
  dynamic prev;
  dynamic next;

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

  int? currentPage;
  int? from;
  int? lastPage;
  List<Link>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    from: json["from"],
    lastPage: json["last_page"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    path: json["path"],
    perPage: json["per_page"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "links": List<dynamic>.from(links!.map((x) => x.toJson())),
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}

class Link {
  Link({
    this.url,
     this.label,
     this.active,
  });

  String? url;
  String? label;
  bool? active;

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
