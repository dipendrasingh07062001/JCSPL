// To parse this JSON data, do
//
//     final sliderResponse = sliderResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';

SliderResponse sliderResponseFromJson(String str) => SliderResponse.fromJson(json.decode(str));

String sliderResponseToJson(SliderResponse data) => json.encode(data.toJson());

class SliderResponse {
  SliderResponse({
    this.sliders,
    this.success,
    this.status,
  });

  List<AIZSlider>? sliders;
  bool? success;
  int? status;

  factory SliderResponse.fromJson(Map<String, dynamic> json) => SliderResponse(
    sliders: List<AIZSlider>.from(json["data"].map((x) => AIZSlider.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(sliders!.map((x) => x.toJson())),
    "success": success,
    "status": status,
  };
}

class AIZSlider {
  AIZSlider({
    this.photo,
    this.url
  });

  String? photo;
  String? url;

  factory AIZSlider.fromJson(Map<String, dynamic> json) => AIZSlider(
    photo: json["photo"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "photo": photo,
    "url":url
  };
}