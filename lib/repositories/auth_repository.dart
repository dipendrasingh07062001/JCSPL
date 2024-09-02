import 'dart:convert';
import 'dart:io';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/loading.dart';
import 'package:active_ecommerce_flutter/data_model/common_response.dart';
import 'package:active_ecommerce_flutter/data_model/confirm_code_response.dart';
import 'package:active_ecommerce_flutter/data_model/login_response.dart';
import 'package:active_ecommerce_flutter/data_model/logout_response.dart';
import 'package:active_ecommerce_flutter/data_model/password_confirm_response.dart';
import 'package:active_ecommerce_flutter/data_model/password_forget_response.dart';
import 'package:active_ecommerce_flutter/data_model/resend_code_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';
import '../custom/toast_component.dart';
import '../helpers/auth_helper.dart';
import '../helpers/main_helpers.dart';
import '../other_config.dart';

class AuthRepository {
  Future<LoginResponse> getLoginResponse(
      String? email, String password, String loginBy) async {
    var post_body = jsonEncode({
      "email": "$email",
      "password": "$password",
      "identity_matrix": AppConfig.purchase_code,
      "login_by": loginBy,
      "temp_user_id": temp_user_id.$
    });

    String url = ("${AppConfig.BASE_URL}/auth/login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);
    print(response.body);

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> getSocialLoginResponse(
    String social_provider,
    String? name,
    String? email,
    String? provider, {
    access_token = "",
    secret_token = "",
  }) async {
    email = email == ("null") ? "" : email;

    var post_body = jsonEncode({
      "name": name,
      "email": email,
      "provider": "$provider",
      "social_provider": "$social_provider",
      "access_token": "$access_token",
      "secret_token": "$secret_token"
    });

    String url = ("${AppConfig.BASE_URL}/auth/social-login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);
    return loginResponseFromJson(response.body);
  }

  Future<LogoutResponse> getLogoutResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/logout");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    return logoutResponseFromJson(response.body);
  }

  Future<CommonResponse> getAccountDeleteResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/account-deletion");

    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    return commonResponseFromJson(response.body);
  }

  Future<void> getSignupResponse(
    BuildContext context, {
    String name = '',
    String? email_or_phone = '',
    String password = '',
    String passowrd_confirmation = '',
    String register_by = '',
    String capchaKey = '',
    String? shop_address,
    String? gst,
    String? gstPhoto,
    String image = '',
    String adharFront = '',
    String adharBack = '',
    String pan = '',
    String? doc1,
    String? doc2,
    String? doc3,
    String whatsappNummber = '',
    String registration_type = '',
    String? businessName = '',
    String? businessImage = '',
    String? businessPhoto = '',
    String business_type = '',
  }) async {
    var post_body = {
      "name": "$name",
      "email_or_phone": "${email_or_phone}",
      "password": "$password",
      "password_confirmation": "${passowrd_confirmation}",
      "register_by": "$register_by",
      "registration_type": registration_type,
      "whatsapp_number": whatsappNummber
      // "g-recaptcha-response": "$capchaKey",
      // "gst": gst,
    };
    if (registration_type == "business") {
      post_body.addAll({"shop_address": "${shop_address}"});
    }
    if (business_type != "") {
      post_body.addAll({"business_type": business_type.toLowerCase()});
    }
    if (gst != "" && gst != null) {
      post_body.addAll({"gst_number": gst});
    }
    if (businessName != "" && businessName != null) {
      post_body.addAll({"business_name": businessName});
    }

    String url = ("${AppConfig.BASE_URL}/auth/signup");
    List<MultipartFile> files = [
      await MultipartFile.fromBytes(
          "profile_image", await File(image).readAsBytes()),

      // await MultipartFile.fromPath("company_one", image,
      //     filename: doc1.split("/").last),
      // await MultipartFile.fromPath("company_two", image,
      //     filename: doc2.split("/").last),
      // await MultipartFile.fromPath("company_three", image,
      //     filename: doc3.split("/").last),
    ];
    if (adharFront != "") {
      post_body.addAll({"adhar_front": adharFront, "adhar_back": adharBack});
      // files.addAll([
      //   await MultipartFile.fromPath("adhar_front", adharFront),
      //   await MultipartFile.fromPath("adhar_back", adharBack),
      // ]);
    }
    if (pan != "") {
      post_body.addAll({"pan_card": pan});
      // files.add(
      //   await MultipartFile.fromPath("pan_card", pan),
      // );
    }
    if (businessImage != null && businessImage != "") {
      files.add(await MultipartFile.fromPath("business_image", businessImage));
    }
    if (businessPhoto != null && businessPhoto != "") {
      files.add(await MultipartFile.fromPath("shop_photo", businessPhoto));
    }
    if (gstPhoto != null && gstPhoto != "") {
      files.add(await MultipartFile.fromPath("gst_photo", gstPhoto));
    }
    Uri uri = Uri.parse(url);
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(currencyHeader);
    print("start");
    headerMap.addAll({
      "Content-Type": "application/json",
      "App-Language": app_language.$!,
    });

    var request = MultipartRequest("POST", uri);
    request.headers.addAll({'System-key': '123456'});
    request.fields.addAll(post_body);
    request.files.addAll(files);
    print(url);
    print(request.fields);
    try {
      var res = await request.send();
      List<int> list = [];
      var responseString;
      await res.stream.listen((data) {
        // Process each data chunk as it arrives.
        // print(data);
        list.addAll(data);
        // var newdata = utf8.decode(data);
        // print(newdata);
      }, onDone: () async {
        print("process is done");
        print(list);
        responseString = utf8.decode(list);
        var data = jsonDecode(responseString);
        print(data);
        Loading.close();
        print("api done");
        var signupResponse = loginResponseFromJson(responseString);
        if (signupResponse.result == false) {
          var message = "";
          signupResponse.message.forEach((value) {
            message += value + "\n";
          });

          ToastComponent.showDialog(message,
              gravity: Toast.center, duration: 3);
        } else {
          ToastComponent.showDialog(signupResponse.message,
              gravity: Toast.center, duration: Toast.lengthLong);
          await AuthHelper().setUserData(signupResponse);

          // redirect to main
          // Navigator.pushAndRemoveUntil(context,
          //     MaterialPageRoute(builder: (context) {
          //       return Main();
          //     }), (newRoute) => false);
          context.go("/");
        }

        // push notification starts
        if (OtherConfig.USE_PUSH_NOTIFICATION) {
          final FirebaseMessaging _fcm = FirebaseMessaging.instance;
          await _fcm.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

          String? fcmToken = await _fcm.getToken();

          if (fcmToken != null) {
            print("--fcm token--");
            print(fcmToken);
            if (is_logged_in.$ == true) {
              // update device token
              await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
            }
          }
        }
      }, onError: (_) {});
      // var responseBytes = await res.stream.toBytes();
      // print(utf8.decode(responseBytes));
      // var data = await response.asFuture();
    } catch (e) {
      print('Error during upload: $e');
      return Future.error(e);
    }
  }

  Future<ResendCodeResponse> getResendCodeResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/resend_code");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
        "Authorization": "Bearer ${access_token.$}",
      },
    );
    return resendCodeResponseFromJson(response.body);
  }

  Future<ConfirmCodeResponse> getConfirmCodeResponse(
      String verification_code) async {
    var post_body = jsonEncode({"verification_code": "$verification_code"});

    String url = ("${AppConfig.BASE_URL}/auth/confirm_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },
        body: post_body);

    return confirmCodeResponseFromJson(response.body);
  }

  Future<PasswordForgetResponse> getPasswordForgetResponse(
      String? email_or_phone, String send_code_by) async {
    var post_body = jsonEncode(
        {"email_or_phone": "$email_or_phone", "send_code_by": "$send_code_by"});

    String url = ("${AppConfig.BASE_URL}/auth/password/forget_request");

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return passwordForgetResponseFromJson(response.body);
  }

  Future<PasswordConfirmResponse> getPasswordConfirmResponse(
      String verification_code, String password) async {
    var post_body = jsonEncode(
        {"verification_code": "$verification_code", "password": "$password"});

    String url = ("${AppConfig.BASE_URL}/auth/password/confirm_reset");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return passwordConfirmResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getPasswordResendCodeResponse(
      String? email_or_code, String verify_by) async {
    var post_body = jsonEncode(
        {"email_or_code": "$email_or_code", "verify_by": "$verify_by"});

    String url = ("${AppConfig.BASE_URL}/auth/password/resend_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return resendCodeResponseFromJson(response.body);
  }

  Future<LoginResponse> getUserByTokenResponse() async {
    var post_body = jsonEncode({"access_token": "${access_token.$}"});

    String url = ("${AppConfig.BASE_URL}/auth/info");
    if (access_token.$!.isNotEmpty) {
      final response = await ApiRequest.post(
          url: url,
          headers: {
            "Content-Type": "application/json",
            "App-Language": app_language.$!,
          },
          body: post_body);

      return loginResponseFromJson(response.body);
    }
    return LoginResponse();
  }
}
