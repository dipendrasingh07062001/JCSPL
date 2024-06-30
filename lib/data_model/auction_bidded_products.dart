// To parse this JSON data, do
//
//     final auctionBiddedProducts = auctionBiddedProductsFromJson(jsonString);

import 'dart:convert';

AuctionBiddedProducts auctionBiddedProductsFromJson(String str) =>
    AuctionBiddedProducts.fromJson(json.decode(str));

String auctionBiddedProductsToJson(AuctionBiddedProducts data) =>
    json.encode(data.toJson());

class AuctionBiddedProducts {
  List<AuctionBiddedProduct>? data;
  Links? links;
  Meta? meta;

  AuctionBiddedProducts({
    this.data,
    this.links,
    this.meta,
  });

  factory AuctionBiddedProducts.fromJson(Map<String, dynamic> json) =>
      AuctionBiddedProducts(
        data: json["data"] == null
            ? []
            : List<AuctionBiddedProduct>.from(
                json["data"]!.map((x) => AuctionBiddedProduct.fromJson(x))),
        links: json["links"] == null ? null : Links.fromJson(json["links"]),
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "links": links?.toJson(),
        "meta": meta?.toJson(),
      };
}

class AuctionBiddedProduct {
  int? id;
  String? name;
  String? thumbnailImage;
  String? myBid;
  String? highestBid;
  String? auctionEndDate;
  String? action;
  bool? isBuyable;

  AuctionBiddedProduct({
    this.id,
    this.name,
    this.thumbnailImage,
    this.myBid,
    this.highestBid,
    this.auctionEndDate,
    this.action,
    this.isBuyable,
  });

  factory AuctionBiddedProduct.fromJson(Map<String, dynamic> json) =>
      AuctionBiddedProduct(
        id: json["id"],
        name: json["name"],
        thumbnailImage: json["thumbnail_image"],
        myBid: json["my_bid"],
        highestBid: json["highest_bid"],
        auctionEndDate: json["auction_end_date"],
        action: json["action"],
        isBuyable: json["isBuyable"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "thumbnail_image": thumbnailImage,
        "my_bid": myBid,
        "highest_bid": highestBid,
        "auction_end_date": auctionEndDate,
        "action": action,
        "isBuyable": isBuyable,
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
