import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/data_model/profile_image_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/user_info_response.dart';
import 'dart:convert';
import 'package:active_ecommerce_flutter/data_model/profile_counters_response.dart';
import 'package:active_ecommerce_flutter/data_model/profile_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/device_token_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/phone_email_availability_response.dart';

import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {


  Future<dynamic> getProfileCountersResponse() async {

    String url=("${AppConfig.BASE_URL}/profile/counters");
    final response = await ApiRequest.get(
      url:url,
      headers: {
        "Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,
      },
    );

    return profileCountersResponseFromJson(response.body);
  }

  Future<dynamic> getProfileUpdateResponse(
      {required String post_body}) async {

    String url=("${AppConfig.BASE_URL}/profile/update");
    final response = await ApiRequest.post(url:url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,},body: post_body );

    return profileUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getDeviceTokenUpdateResponse(
       String device_token) async {

    var post_body = jsonEncode({"device_token": "${device_token}"});

    String url=("${AppConfig.BASE_URL}/profile/update-device-token");
    final response = await ApiRequest.post(url:url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,},body: post_body );

    return deviceTokenUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getProfileImageUpdateResponse(
       String image, String filename) async {

    var post_body = jsonEncode({"image": "${image}", "filename": "$filename"});
    print(post_body.toString());

    String url=("${AppConfig.BASE_URL}/profile/update-image");
    final response = await ApiRequest.post(url:url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,},body: post_body );

    return profileImageUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getPhoneEmailAvailabilityResponse() async {

    //var post_body = jsonEncode({"user_id":"${user_id.$}"});

    String url=("${AppConfig.BASE_URL}/profile/check-phone-and-email");
    final response = await ApiRequest.post(url:url,
        headers: {"Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,},body: '');


    return phoneEmailAvailabilityResponseFromJson(response.body);
  }


    Future<dynamic> getUserInfoResponse() async {

    String url=("${AppConfig.BASE_URL}/customer/info");

    final response = await ApiRequest.get(url: url,
        headers: {"Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,});


    return userInfoResponseFromJson(response.body);
  }



}
