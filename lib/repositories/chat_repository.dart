import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/conversation_response.dart';
import 'package:active_ecommerce_flutter/data_model/message_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

import '../data_model/conversation_create_response.dart';

class ChatRepository {
  Future<dynamic> getConversationResponse({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/chat/conversations?page=${page}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return conversationResponseFromJson(response.body);
  }

  Future<dynamic> getMessageResponse(
      {required conversation_id, page = 1}) async {
    String url =
        ("${AppConfig.BASE_URL}/chat/messages/${conversation_id}?page=${page}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());
    return messageResponseFromJson(response.body);
  }

  Future<dynamic> getInserMessageResponse(
      {required conversation_id, required String message}) async {
    var post_body = jsonEncode({
      "user_id": "${user_id.$}",
      "conversation_id": "${conversation_id}",
      "message": "${message}"
    });

    String url = ("${AppConfig.BASE_URL}/chat/insert-message");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return messageResponseFromJson(response.body);
  }

  Future<dynamic> getNewMessageResponse(
      {required conversation_id, required last_message_id}) async {
    String url =
        ("${AppConfig.BASE_URL}/chat/get-new-messages/${conversation_id}/${last_message_id}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());
    return messageResponseFromJson(response.body);
  }

  Future<dynamic> getCreateConversationResponse(
      {required product_id,
      required String title,
      required String message}) async {
    var post_body = jsonEncode({
      "user_id": "${user_id.$}",
      "product_id": "${product_id}",
      "title": "${title}",
      "message": "${message}"
    });
    String url = ("${AppConfig.BASE_URL}/chat/create-conversation");
    // print("Bearer ${access_token.$}");
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
    return conversationCreateResponseFromJson(response.body);
  }
}
