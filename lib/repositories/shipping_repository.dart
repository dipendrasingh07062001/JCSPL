import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/delivery_info_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

class ShippingRepository {
  Future<dynamic> getDeliveryInfo() async {
    String url = ("${AppConfig.BASE_URL}/delivery-info");
    print(url.toString());
    var post_body;
    if (guest_checkout_status.$ && !is_logged_in.$) {
      post_body = jsonEncode({"temp_user_id": temp_user_id.$});
    } else {
      post_body = jsonEncode({"user_id": user_id.$});
    }

    final response = await ApiRequest.post(
      url: url,
      body: post_body,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
/*    print(post_body);
    print(response.body);
    print("response.body");*/

    return deliveryInfoResponseFromJson(response.body);
  }
}
