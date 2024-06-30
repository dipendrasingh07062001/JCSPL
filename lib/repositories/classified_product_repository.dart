import 'dart:convert';

import '../app_config.dart';
import '../data_model/classified_ads_details_response.dart';
import '../data_model/classified_ads_response.dart';
import '../data_model/common_response.dart';
import '../helpers/shared_value_helper.dart';
import 'api-request.dart';

class ClassifiedProductRepository {
  Future<ClassifiedAdsResponse> getClassifiedProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/all?page=$page");
    // print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getOwnClassifiedProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/own-products?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
    });
    // print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getClassifiedOtherAds({
    required slug,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/related-products/$slug");
    // print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedProductDetailsResponse> getClassifiedProductsDetails(
      slug) async {
    String url = ("${AppConfig.BASE_URL}/classified/product-details/$slug");
    // print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return classifiedProductDetailsResponseFromJson(response.body);
  }

  Future<CommonResponse> getDeleteClassifiedProductResponse(id) async {
    String url = ("${AppConfig.BASE_URL}/classified/delete/$id");
    // print(url.toString());

    final response = await ApiRequest.delete(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
    });

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> getStatusChangeClassifiedProductResponse(
      id, status) async {
    String url = ("${AppConfig.BASE_URL}/classified/change-status/$id");

    var post_body = jsonEncode({"status": status});
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: post_body,
    );

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> addProductResponse(postBody) async {
    String url = ("${AppConfig.BASE_URL}/classified/store");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> updateCustomerProductResponse(
      postBody, id, lang) async {
    String url = ("${AppConfig.BASE_URL}/classified/update/$id?lang=$lang");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }
}
