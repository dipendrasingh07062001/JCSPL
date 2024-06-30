// To parse this JSON data, do
//
//     final guestCustomerInfoCheckResponse = guestCustomerInfoCheckResponseFromJson(jsonString);

import 'dart:convert';

GuestCustomerInfoCheckResponse guestCustomerInfoCheckResponseFromJson(
        String str) =>
    GuestCustomerInfoCheckResponse.fromJson(json.decode(str));

String guestCustomerInfoCheckResponseToJson(
        GuestCustomerInfoCheckResponse data) =>
    json.encode(data.toJson());

class GuestCustomerInfoCheckResponse {
  bool? result;

  GuestCustomerInfoCheckResponse({
    this.result,
  });

  factory GuestCustomerInfoCheckResponse.fromJson(Map<String, dynamic> json) =>
      GuestCustomerInfoCheckResponse(
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
      };
}
