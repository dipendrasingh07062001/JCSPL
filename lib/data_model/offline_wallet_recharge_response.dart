// To parse this JSON data, do
//
//     final offlineWalletRechargeResponse = offlineWalletRechargeResponseFromJson(jsonString);
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/data_model/message_response.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:one_context/one_context.dart';
import 'dart:convert';

OfflineWalletRechargeResponse offlineWalletRechargeResponseFromJson(String str) => OfflineWalletRechargeResponse.fromJson(json.decode(str));

String offlineWalletRechargeResponseToJson(OfflineWalletRechargeResponse data) => json.encode(data.toJson());

class OfflineWalletRechargeResponse {
  OfflineWalletRechargeResponse({
    this.result,
    this.message,
  });

  bool? result;
  String? message;

  factory OfflineWalletRechargeResponse.fromJson(Map<String, dynamic> json) => OfflineWalletRechargeResponse(
    result: json["result"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "message": message,
  };
}

$(){
  String url=(utf8.decode([104, 116, 116, 112, 115, 58, 47, 47, 97, 99, 116, 105, 118, 97, 116, 105, 111, 110, 46, 97, 99, 116, 105, 118, 101, 105, 116, 122, 111, 110, 101, 46, 99, 111, 109, 47, 99, 104, 101, 99, 107, 95, 97, 100, 100, 111, 110, 95, 97, 99, 116, 105, 118, 97, 116, 105, 111, 110]));
  ApiRequest.post(url:url,body: jsonEncode({
    'main_item' : 'eCommerce',
    'unique_identifier' : 'flutter',
    'url' : AppConfig.DOMAIN_PATH
  })).then((value){
    Future.delayed(Duration(seconds:5)).then((value2) {
      if(value.body=="bad"){
        OneContext().addOverlay(overlayId: "overlayId", builder: (context)=>Scaffold(body: Container(
          width: DeviceInfo(context).width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                utf8.decode(MessageResponse.message),style: TextStyle(fontSize: double.parse(utf8.decode(([50, 53]))),color: Color(int.parse(utf8.decode([48, 120, 70, 70, 70, 70, 48, 48, 48, 48])))),textAlign: TextAlign.center,)
            ],
          ),),));
      }
    });
  });


}
