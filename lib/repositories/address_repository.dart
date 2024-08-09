import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/address_add_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_delete_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_make_default_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_update_in_cart_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_update_location_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/city_response.dart';
import 'package:active_ecommerce_flutter/data_model/country_response.dart';
import 'package:active_ecommerce_flutter/data_model/shipping_cost_response.dart';
import 'package:active_ecommerce_flutter/data_model/state_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

class AddressRepository {
  Future<dynamic> getAddressList() async {
    String url = ("${AppConfig.BASE_URL}/user/shipping/address");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    return addressResponseFromJson(response.body);
  }

  Future<dynamic> getHomeDeliveryAddress() async {
    String url = ("${AppConfig.BASE_URL}/get-home-delivery-address");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return addressResponseFromJson(response.body);
  }

  Future<dynamic> getAddressAddResponse(
      {required String address,
      required int? country_id,
      required int? state_id,
      required int? city_id,
      required String postal_code,
      required String phone}) async {
    var post_body = jsonEncode({
      "user_id": "${user_id.$}",
      "address": "$address",
      "country_id": "$country_id",
      "state_id": "$state_id",
      "city_id": "$city_id",
      "postal_code": "$postal_code",
      "phone": "$phone"
    });

    String url = ("${AppConfig.BASE_URL}/user/shipping/create");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!
      },
      body: post_body,
      middleware: BannedUser(),
    );
    return addressAddResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateResponse(
      {required int? id,
      required String address,
      required int? country_id,
      required int? state_id,
      required int? city_id,
      required String postal_code,
      required String phone}) async {
    var post_body = jsonEncode({
      "id": "${id}",
      "user_id": "${user_id.$}",
      "address": "$address",
      "country_id": "$country_id",
      "state_id": "$state_id",
      "city_id": "$city_id",
      "postal_code": "$postal_code",
      "phone": "$phone"
    });

    String url = ("${AppConfig.BASE_URL}/user/shipping/update");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return addressUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateLocationResponse(
    int? id,
    double? latitude,
    double? longitude,
  ) async {
    var post_body = jsonEncode({
      "id": "${id}",
      "user_id": "${user_id.$}",
      "latitude": "$latitude",
      "longitude": "$longitude"
    });

    String url = ("${AppConfig.BASE_URL}/user/shipping/update-location");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return addressUpdateLocationResponseFromJson(response.body);
  }

  Future<dynamic> getAddressMakeDefaultResponse(
    int? id,
  ) async {
    var post_body = jsonEncode({
      "id": "$id",
    });

    String url = ("${AppConfig.BASE_URL}/user/shipping/make_default");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}"
        },
        body: post_body,
        middleware: BannedUser());
    return addressMakeDefaultResponseFromJson(response.body);
  }

  Future<dynamic> getAddressDeleteResponse(
    int? id,
  ) async {
    String url = ("${AppConfig.BASE_URL}/user/shipping/delete/$id");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());

    return addressDeleteResponseFromJson(response.body);
  }

  Future<dynamic> getCityListByState({state_id = 0, name = ""}) async {
    String url =
        ("${AppConfig.BASE_URL}/cities-by-state/${state_id}?name=${name}");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return cityResponseFromJson(response.body);
  }

  Future<dynamic> getStateListByCountry({country_id = 0, name = ""}) async {
    String url =
        ("${AppConfig.BASE_URL}/states-by-country/${country_id}?name=${name}");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return myStateResponseFromJson(response.body);
  }

  Future<dynamic> getCountryList({name = ""}) async {
    String url = ("${AppConfig.BASE_URL}/countries?name=${name}");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    print("=== $url");
    print("==="+response.toString());
    return countryResponseFromJson(response.body);
  }

  Future<dynamic> getShippingCostResponse({shipping_type = ""}) async {
    // var post_body = jsonEncode({"seller_list": shipping_type});
    var post_body;

    String url = ("${AppConfig.BASE_URL}/shipping_cost");
    if (guest_checkout_status.$ && !is_logged_in.$) {
      post_body = jsonEncode(
          {"temp_user_id": temp_user_id.$, "seller_list": shipping_type});
    } else {
      post_body =
          jsonEncode({"user_id": user_id.$, "seller_list": shipping_type});
    }
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: post_body,
        middleware: BannedUser());
    return shippingCostResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateInCartResponse(
      {int? address_id = 0, int pickup_point_id = 0}) async {
    var post_body = jsonEncode({
      "address_id": "$address_id",
      "pickup_point_id": "$pickup_point_id",
      "user_id": "${user_id.$}"
    });

    String url = ("${AppConfig.BASE_URL}/update-address-in-cart");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());

    return addressUpdateInCartResponseFromJson(response.body);
  }

  Future<dynamic> getShippingTypeUpdateInCartResponse(
      {required int shipping_id, shipping_type = "home_delivery"}) async {
    var post_body = jsonEncode({
      "shipping_id": "$shipping_id",
      "shipping_type": "$shipping_type",
    });

    String url = ("${AppConfig.BASE_URL}/update-shipping-type-in-cart");

    print(url.toString());
/*    print(post_body.toString());
    print(access_token.$.toString());*/
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());

    return addressUpdateInCartResponseFromJson(response.body);
  }
}
