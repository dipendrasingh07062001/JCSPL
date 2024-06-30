import 'package:active_ecommerce_flutter/data_model/business_setting_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/business_setting_repository.dart';

class BusinessSettingHelper {
  setBusinessSettingData() async {
    BusinessSettingListResponse businessLists =
        await BusinessSettingRepository().getBusinessSettingList();

    businessLists.data!.forEach((element) {
      switch (element.type) {
        case 'facebook_login':
          {
            if (element.value.toString() == "1") {
              allow_facebook_login.$ = true;
            } else {
              allow_facebook_login.$ = false;
            }
          }
          break;
        case 'google_login':
          {
            if (element.value.toString() == "1") {
              allow_google_login.$ = true;
            } else {
              allow_google_login.$ = false;
            }
          }
          break;
        case 'twitter_login':
          {
            if (element.value.toString() == "1") {
              allow_twitter_login.$ = true;
            } else {
              allow_twitter_login.$ = false;
            }
          }
          break;
        case 'apple_login':
          {
            if (element.value.toString() == "1") {
              allow_apple_login.$ = true;
            } else {
              allow_apple_login.$ = false;
            }
          }
          break;
        case 'pickup_point':
          {
            if (element.value.toString() == "1") {
              pick_up_status.$ = true;
            } else {
              pick_up_status.$ = false;
            }
          }
          break;
        case 'wallet_system':
          {
            if (element.value.toString() == "1") {
              wallet_system_status.$ = true;
            } else {
              wallet_system_status.$ = false;
            }
          }
          break;
        case 'email_verification':
          {
            if (element.value.toString() == "1") {
              mail_verification_status.$ = true;
            } else {
              mail_verification_status.$ = false;
            }
          }
          break;
        case 'conversation_system':
          {
            if (element.value.toString() == "1") {
              conversation_system_status.$ = true;
            } else {
              conversation_system_status.$ = false;
            }
          }
          break;
        case 'classified_product':
          {
            if (element.value.toString() == "1") {
              classified_product_status.$ = true;
            } else {
              classified_product_status.$ = false;
            }
          }
          break;

        case 'shipping_type':
          {
            // print(element.value.toString());
            if (element.value.toString() == "carrier_wise_shipping") {
              carrier_base_shipping.$ = true;
            } else {
              carrier_base_shipping.$ = false;
            }
          }
          break;
        case 'google_recaptcha':
          {
            // print(element.type.toString());
            // print(element.value.toString());
            if (element.value.toString() == "1") {
              google_recaptcha.$ = true;
            } else {
              google_recaptcha.$ = false;
            }
          }
          break;
        case 'vendor_system_activation':
          {
            // print(element.type.toString());
            // print(element.value.toString());
            if (element.value.toString() == "1") {
              vendor_system.$ = true;
            } else {
              vendor_system.$ = false;
            }
          }
          break;
        case 'guest_checkout_activation':
          {
            // print(element.type.toString());
            // print(element.value.toString());
            if (element.value.toString() == "1") {
              guest_checkout_status.$ = true;
            } else {
              guest_checkout_status.$ = false;
            }
          }
          break;
        case 'last_viewed_product_activation':
          {
            if (element.value.toString() == "1") {
              last_viewed_product_status.$ = true;
            } else {
              last_viewed_product_status.$ = false;
            }
          }
          break;

        default:
          {}
          break;
      }
    });
  }
}
