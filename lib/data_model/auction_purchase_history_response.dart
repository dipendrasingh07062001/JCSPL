// To parse this JSON data, do
//
//     final auctionPurchaseHistoryResponse = auctionPurchaseHistoryResponseFromJson(jsonString);

import 'dart:convert';

AuctionPurchaseHistoryResponse auctionPurchaseHistoryResponseFromJson(String str) => AuctionPurchaseHistoryResponse.fromJson(json.decode(str));

String auctionPurchaseHistoryResponseToJson(AuctionPurchaseHistoryResponse data) => json.encode(data.toJson());

class AuctionPurchaseHistoryResponse {
  List<AuctionPurchaseHistory>? data;
  Links? links;
  Meta? meta;

  AuctionPurchaseHistoryResponse({
    this.data,
    this.links,
    this.meta,
  });

  factory AuctionPurchaseHistoryResponse.fromJson(Map<String, dynamic> json) => AuctionPurchaseHistoryResponse(
    data: json["data"] == null ? [] : List<AuctionPurchaseHistory>.from(json["data"]!.map((x) => AuctionPurchaseHistory.fromJson(x))),
    links: json["links"] == null ? null : Links.fromJson(json["links"]),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "links": links?.toJson(),
    "meta": meta?.toJson(),
  };
}

class AuctionPurchaseHistory {
  int? id;
  String? code;
  String? date;
  String? amount;
  String? deliveryStatus;
  String? paymentStatus;

  AuctionPurchaseHistory({
    this.id,
    this.code,
    this.date,
    this.amount,
    this.deliveryStatus,
    this.paymentStatus,
  });

  factory AuctionPurchaseHistory.fromJson(Map<String, dynamic> json) => AuctionPurchaseHistory(
    id: json["id"],
    code: json["code"],
    date: json["date"],
    amount: json["amount"],
    deliveryStatus: json["delivery_status"],
    paymentStatus: json["payment_status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "date": date,
    "amount": amount,
    "delivery_status": deliveryStatus,
    "payment_status": paymentStatus,
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
    links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    path: json["path"],
    perPage: json["per_page"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "links": links == null ? [] : List<dynamic>.from(links!.map((x) => x.toJson())),
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
