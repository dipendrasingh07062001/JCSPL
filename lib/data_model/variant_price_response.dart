// To parse this JSON data, do
//
//     final variantPriceResponse = variantPriceResponseFromJson(jsonString);

import 'dart:convert';

VariantPriceResponse variantPriceResponseFromJson(String str) =>
    VariantPriceResponse.fromJson(json.decode(str));

String variantPriceResponseToJson(VariantPriceResponse data) =>
    json.encode(data.toJson());

class VariantPriceResponse {
  bool? result;
  Data? data;

  VariantPriceResponse({
    this.result,
    this.data,
  });

  factory VariantPriceResponse.fromJson(Map<String, dynamic> json) =>
      VariantPriceResponse(
        result: json["result"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "data": data!.toJson(),
      };
}

class Data {
  String? price;
  int? quantity;
  int? digital;
  String? variation;
  int? maxLimit;
  int? inStock;

  Data({
    this.price,
    this.quantity,
    this.digital,
    this.variation,
    this.maxLimit,
    this.inStock,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        price: json["price"],
        quantity: json["quantity"],
        digital: json["digital"],
        variation: json["variation"],
        maxLimit: json["max_limit"],
        inStock: json["in_stock"],
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "quantity": quantity,
        "digital": digital,
        "variation": variation,
        "max_limit": maxLimit,
        "in_stock": inStock,
      };
}
