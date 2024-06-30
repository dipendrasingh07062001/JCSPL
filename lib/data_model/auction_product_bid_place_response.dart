// To parse this JSON data, do
//
//     final auctionProductPlaceBidResponse = auctionProductPlaceBidResponseFromJson(jsonString);

import 'dart:convert';

AuctionProductPlaceBidResponse auctionProductPlaceBidResponseFromJson(
        String str) =>
    AuctionProductPlaceBidResponse.fromJson(json.decode(str));

String auctionProductPlaceBidResponseToJson(
        AuctionProductPlaceBidResponse data) =>
    json.encode(data.toJson());

class AuctionProductPlaceBidResponse {
  AuctionProductPlaceBidResponse({
    this.result,
    this.message,
  });

  bool? result;
  String? message;

  factory AuctionProductPlaceBidResponse.fromJson(Map<String, dynamic> json) =>
      AuctionProductPlaceBidResponse(
        result: json["result"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "message": message,
      };
}
