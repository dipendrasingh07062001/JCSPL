// To parse this JSON data, do
//
//     final reOrderResponse = reOrderResponseFromJson(jsonString);

import 'dart:convert';

ReOrderResponse reOrderResponseFromJson(String str) =>
    ReOrderResponse.fromJson(json.decode(str));

String reOrderResponseToJson(ReOrderResponse data) =>
    json.encode(data.toJson());

class ReOrderResponse {
  List<String>? successMsgs;
  List<String>? failedMsgs;

  ReOrderResponse({
    this.successMsgs,
    this.failedMsgs,
  });

  factory ReOrderResponse.fromJson(Map<String, dynamic> json) =>
      ReOrderResponse(
        successMsgs: json["success_msgs"] == null
            ? []
            : List<String>.from(json["success_msgs"]!.map((x) => x)),
        failedMsgs: json["failed_msgs"] == null
            ? []
            : List<String>.from(json["failed_msgs"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success_msgs": successMsgs == null
            ? []
            : List<dynamic>.from(successMsgs!.map((x) => x)),
        "failed_msgs": failedMsgs == null
            ? []
            : List<dynamic>.from(failedMsgs!.map((x) => x)),
      };
}
