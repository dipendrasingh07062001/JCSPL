import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:shared_value/shared_value.dart';

final SharedValue<bool> is_logged_in = SharedValue(
  value: false, // initial value
  key: "is_logged_in", // disk storage key for shared_preferences
);

final SharedValue<String?> temp_user_id = SharedValue(
  value: "", // initial value
  key: "temp_user_id", // disk storage key for shared_preferences
);

final SharedValue<String?> access_token = SharedValue(
  value: "", // initial value
  key: "access_token", // disk storage key for shared_preferences
);

final SharedValue<int?> user_id = SharedValue(
  value: 0, // initial value
  key: "user_id", // disk storage key for shared_preferences
);

final SharedValue<String?> avatar_original = SharedValue(
  value: "", // initial value
  key: "avatar_original", // disk storage key for shared_preferences
);

final SharedValue<String?> user_name = SharedValue(
  value: "", // initial value
  key: "user_name", // disk storage key for shared_preferences
);

final SharedValue<String> user_email = SharedValue(
  value: "", // initial value
  key: "user_email", // disk storage key for shared_preferences
);

final SharedValue<String> user_phone = SharedValue(
  value: "", // initial value
  key: "user_phone", // disk storage key for shared_preferences
);
final SharedValue<String?> app_language = SharedValue(
  value: AppConfig.default_language, // initial value
  key: "app_language", // disk storage key for shared_preferences
);

final SharedValue<String?> app_mobile_language = SharedValue(
  value: AppConfig.mobile_app_code, // initial value
  key: "app_mobile_language", // disk storage key for shared_preferences
);
final SharedValue<int?> system_currency = SharedValue(
  key: "system_currency", value: 0, // disk storage key for shared_preferences
);

final SharedValue<bool?> app_language_rtl = SharedValue(
  value: AppConfig.app_language_rtl, // initial value
  key: "app_language_rtl", // disk storage key for shared_preferences
);

// addons start

final SharedValue<bool> club_point_addon_installed = SharedValue(
  value: false, // initial value
  key: "club_point_addon_installed", // disk storage key for shared_preferences
);

final SharedValue<bool> whole_sale_addon_installed = SharedValue(
  value: false, // initial value
  key: "whole_sale_addon_installed", // disk storage key for shared_preferences
);

final SharedValue<bool> refund_addon_installed = SharedValue(
  value: false, // initial value
  key: "refund_addon_installed", // disk storage key for shared_preferences
);

final SharedValue<bool> otp_addon_installed = SharedValue(
  value: false, // initial value
  key: "otp_addon_installed", // disk storage key for shared_preferences
);
final SharedValue<bool> auction_addon_installed = SharedValue(
  value: false, // initial value
  key: "auction_addon_installed", // disk storage key for shared_preferences
);
// addon end

// social login start
final SharedValue<bool> allow_google_login = SharedValue(
  value: false, // initial value
  key: "allow_google_login", // disk storage key for shared_preferences
);

final SharedValue<bool> allow_facebook_login = SharedValue(
  value: false, // initial value
  key: "allow_facebook_login", // disk storage key for shared_preferences
);

final SharedValue<bool> allow_twitter_login = SharedValue(
  value: false, // initial value
  key: "allow_twitter_login", // disk storage key for shared_preferences
);
final SharedValue<bool> allow_apple_login = SharedValue(
  value: false, // initial value
  key: "allow_apple_login", // disk storage key for shared_preferences
);
// social login end

// business setting
final SharedValue<bool> pick_up_status = SharedValue(
  value: false, // initial value
  key: "pick_up_status", // disk storage key for shared_preferences
);
// business setting
final SharedValue<bool> carrier_base_shipping = SharedValue(
  value: false, // initial value
  key: "carrier_base_shipping", // disk storage key for shared_preferences
);
// business setting
final SharedValue<bool> google_recaptcha = SharedValue(
  value: false, // initial value
  key: "google_recaptcha", // disk storage key for shared_preferences
);

final SharedValue<bool> wallet_system_status = SharedValue(
  value: false, // initial value
  key: "wallet_system_status", // disk storage key for shared_preferences
);

final SharedValue<bool> mail_verification_status = SharedValue(
  value: false, // initial value
  key: "mail_verification_status", // disk storage key for shared_preferences
);

final SharedValue<bool> conversation_system_status = SharedValue(
  value: false, // initial value
  key: "conversation_system", // disk storage key for shared_preferences
);
final SharedValue<bool> vendor_system = SharedValue(
  value: false, // initial value
  key: "vendor_system", // disk storage key for shared_preferences
);

final SharedValue<bool> classified_product_status = SharedValue(
  value: false, // initial value
  key: "classified_product", // disk storage key for shared_preferences
);
final SharedValue<bool> guest_checkout_status = SharedValue(
  value: false, // initial value
  key: "guest_checkout", // disk storage key for shared_preferences
);
final SharedValue<bool> last_viewed_product_status = SharedValue(
  value: false, // initial value
  key:
      "last_viewed_product_activation", // disk storage key for shared_preferences
);

final SharedValue<String> guestEmail = SharedValue(
  value: "", // initial value
  key: "guest_email", // disk storage key for shared_preferences
);
