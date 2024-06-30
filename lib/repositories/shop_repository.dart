import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/data_model/common_response.dart';
import 'package:active_ecommerce_flutter/data_model/followed_sellers_response.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/data_model/shop_response.dart';
import 'package:active_ecommerce_flutter/data_model/shop_details_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_mini_response.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter/foundation.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class ShopRepository {
  Future<dynamic> getShops({name = "", page = 1}) async {
    String url =
        ("${AppConfig.BASE_URL}/shops" + "?page=${page}&name=${name}");

    print(url.toString());

    final response = await ApiRequest.get(url: url,
      headers: {
        "App-Language": app_language.$!,
      },);

    return shopResponseFromJson(response.body);
  }

  Future<ShopDetailsResponse> getShopInfo(slug) async {

    String url =  ("${AppConfig.BASE_URL}/shops/details/$slug");
    print(url.toString());
    final response =
        await ApiRequest.get(url: url,
          headers: {
            "App-Language": app_language.$!,
          },);


    return shopDetailsResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTopFromThisSellerProducts({int? id = 0}) async {

    String url =  ("${AppConfig.BASE_URL}/shops/products/top/" + id.toString());
    final response = await ApiRequest
        .get(url:url,
      headers: {
        "App-Language": app_language.$!,
        "Currency-Code":SystemConfig.systemCurrency!.code!,
        
      },);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getNewFromThisSellerProducts({int? id = 0}) async {

    String url =  ("${AppConfig.BASE_URL}/shops/products/new/" + id.toString());
    final response = await ApiRequest
        .get(url:url,
      headers: {
        "App-Language": app_language.$!,
        "Currency-Code":SystemConfig.systemCurrency!.code!,
        
      },);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getfeaturedFromThisSellerProducts(
      {int? id = 0}) async {

    String url =  ("${AppConfig.BASE_URL}/shops/products/featured/" + id.toString());
    final response = await ApiRequest
        .get(url:url,
      headers: {
        "App-Language": app_language.$!,
        "Currency-Code":SystemConfig.systemCurrency!.code!,
        
      },);
    return productMiniResponseFromJson(response.body);
  }

  Future<CommonResponse> followedCheck(id) async {

    String url =  ("${AppConfig.BASE_URL}/followed-seller/check/$id");
    final response = await ApiRequest
        .get(url:url,
      headers: {
          "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },);
    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> followedAdd(id) async {

    String url =  ("${AppConfig.BASE_URL}/followed-seller/store/$id");
    final response = await ApiRequest
        .get(url:url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },);
    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> followedRemove(id) async {

    String url =  ("${AppConfig.BASE_URL}/followed-seller/remove/$id");
    final response = await ApiRequest
        .get(url:url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },);
    return commonResponseFromJson(response.body);
  }

  Future<FollowedSellersResponse> followedList({page=1}) async {
    String url =  ("${AppConfig.BASE_URL}/followed-seller?page=$page");
    final response = await ApiRequest
        .get(url:url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },);
    print(response.body);
    return followedSellersResponseFromJson(response.body);
  }

  Future<ShopResponse> topSellers()async{
    String url =("${AppConfig.BASE_URL}/seller/top");

    final response = await ApiRequest.get(url: url,
      headers: {
        "App-Language": app_language.$!,
      },);

    return shopResponseFromJson(response.body);
  }


}
