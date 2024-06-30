import 'package:active_ecommerce_flutter/data_model/guest_customer_info_check_response.dart';
import 'package:active_ecommerce_flutter/data_model/login_response.dart';

import '../app_config.dart';
import '../helpers/shared_value_helper.dart';
import '../middlewares/banned_user.dart';
import 'api-request.dart';

class GuestCheckoutRepository {
  Future<GuestCustomerInfoCheckResponse> guestCustomerInfoCheck(
      postBody) async {
    String url = ("${AppConfig.BASE_URL}/guest-customer-info-check");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!
      },
      body: postBody,
      middleware: BannedUser(),
    );
    return guestCustomerInfoCheckResponseFromJson(response.body);
  }

  Future<dynamic> guestUserAccountCreate(postBody) async {
    String url = ("${AppConfig.BASE_URL}/guest-user-account-create");

    final response = await ApiRequest.post(
      url: url,
      body: postBody,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    // print("guest -user - create -account");

    return loginResponseFromJson(response.body);
  }
}
