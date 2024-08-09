import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';

import '../data_model/login_response.dart';

class AuthHelper {
  Future<void> setUserData(LoginResponse loginResponse) async {
    if (loginResponse.result == true) {
      SystemConfig.systemUser = loginResponse.user;
      is_logged_in.$ = true;
      await is_logged_in.save();
      access_token.$ = loginResponse.access_token;
      await access_token.save();
      user_id.$ = loginResponse.user?.id;
      await user_id.save();
      user_name.$ = loginResponse.user?.name;
      await user_name.save();
      user_email.$ = loginResponse.user?.email ?? "";
      await user_email.save();
      user_phone.$ = loginResponse.user?.phone ?? "";
      await user_phone.save();
      avatar_original.$ = loginResponse.user?.avatar_original;
      await avatar_original.save();
      profile_image.$ = loginResponse.user?.profile_image;
      await profile_image.save();
    }
  }

  clearUserData() {
    SystemConfig.systemUser = null;
    is_logged_in.$ = false;
    is_logged_in.save();
    access_token.$ = "";
    access_token.save();
    user_id.$ = 0;
    user_id.save();
    user_name.$ = "";
    user_name.save();
    user_email.$ = "";
    user_email.save();
    user_phone.$ = "";
    user_phone.save();
    avatar_original.$ = "";
    avatar_original.save();

    temp_user_id.$ = "";
    temp_user_id.save();
  }

  fetch_and_set() async {
    var userByTokenResponse = await AuthRepository().getUserByTokenResponse();
    if (userByTokenResponse.result == true) {
      setUserData(userByTokenResponse);
    } else {
      clearUserData();
    }
  }
}
