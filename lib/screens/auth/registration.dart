// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/google_recaptcha.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/login.dart';
import 'package:active_ecommerce_flutter/screens/common_webview_screen.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toast/toast.dart';
import 'package:validators/validators.dart';

import '../../custom/loading.dart';
import '../../repositories/address_repository.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _register_by = "email"; //phone or email
  String initialCountry = 'US';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";
  String? _whatsappNo = "";

  bool? _isAgree = false;
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";
  File? profilePick;
  bool isindividual = true;
  String businessType = "Distributorship";

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _whatsappNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _shopaddressController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _gstController = TextEditingController();
  TextEditingController _gstPhotoController = TextEditingController();
  TextEditingController _businessPhotoController = TextEditingController();
  TextEditingController _businessImageController = TextEditingController();
  TextEditingController _adharFrontController = TextEditingController();
  TextEditingController _adharBackController = TextEditingController();
  TextEditingController _panCardController = TextEditingController();
  TextEditingController _doc1Controller = TextEditingController();
  TextEditingController _doc2Controller = TextEditingController();
  TextEditingController _doc3Controller = TextEditingController();
  String businessPhoto = "";
  String businessImage = "";
  String gstPhoto = "";
  String adharfront = "";
  String adharback = "";
  String pan = "";
  String doc1 = "";
  String doc2 = "";
  String doc3 = "";
  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressregistrationtype() {
    profilePick = null;
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _passwordConfirmController.clear();
    _whatsappNumberController.clear();
    _adharBackController.clear();
    _adharFrontController.clear();
    _panCardController.clear();
    _shopaddressController.clear();
    _businessPhotoController.clear();
    _businessImageController.clear();
    _businessNameController.clear();
    _gstController.clear();
    _gstPhotoController.clear();
  }

  onPressSignUp() async {
    var name = _nameController.text.toString();
    var email = _emailController.text.trim();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();
    var shop_address = _shopaddressController.text.toString();
    // gst = _gstController.text.toString();
    if (profilePick == null) {
      ToastComponent.showDialog("Profile pick is required",
          gravity: Toast.center, duration: Toast.lengthLong);

      return;
    }
    if (name == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_your_name,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (_register_by == 'email' && (email == "" || !isEmail(email))) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
          gravity: Toast.center, duration: Toast.lengthLong);

      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          gravity: Toast.center,
          duration: Toast.lengthLong);

      return;
    }
    if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password,
          gravity: Toast.center, duration: Toast.lengthLong);

      return;
    }
    if (password_confirm == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.confirm_your_password,
          gravity: Toast.center,
          duration: Toast.lengthLong);

      return;
    }
    if (password.length < 6) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!
              .password_must_contain_at_least_6_characters,
          gravity: Toast.center,
          duration: Toast.lengthLong);

      return;
    }
    if (password != password_confirm) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.passwords_do_not_match,
          gravity: Toast.center,
          duration: Toast.lengthLong);

      return;
    }
    if (_whatsappNo == "") {
      ToastComponent.showDialog("Enter Whatsapp Number",
          gravity: Toast.center, duration: Toast.lengthLong);

      return;
    }
    if (_whatsappNo!.length < 10) {
      ToastComponent.showDialog("Enter complete Whatsapp Number",
          gravity: Toast.center, duration: Toast.lengthLong);

      return;
    }
    if (isindividual) {
      //     if (shop_address.isEmpty) {
      //   ToastComponent.showDialog(
      //       AppLocalizations.of(context)!.shop_address_is_required,
      //       gravity: Toast.center,
      //       duration: Toast.lengthLong);
      //
      //   return;
      // }
      //     if (gst.isEmpty) {
      //   ToastComponent.showDialog("GST is required",
      //       gravity: Toast.center, duration: Toast.lengthLong);
      //
      //   return;
      // }
      // if (adharfront.isEmpty) {
      //   ToastComponent.showDialog("Adhar card is required",
      //       gravity: Toast.center, duration: Toast.lengthLong);

      //   return;
      // }

      //   if (_panCardController.text.isEmpty) {
      //   ToastComponent.showDialog("Pan card is required",
      //       gravity: Toast.center, duration: Toast.lengthLong);
      //
      //   return;
      // }
      //   else if (_doc1Controller.text.isEmpty ||
      //     _doc2Controller.text.isEmpty ||
      //     _doc3Controller.text.isEmpty) {
      //   ToastComponent.showDialog("Company Document are required",
      //       gravity: Toast.center, duration: Toast.lengthLong);
      //
      //   return;
      // }
      Loading.show(context);

      await AuthRepository().getSignupResponse(context,
          name: name,
          email_or_phone: _register_by == 'email' ? email : _phone,
          registration_type: "individual",
          password: password,
          passowrd_confirmation: password_confirm,
          register_by: _register_by,
          business_type: businessType,
          capchaKey: googleRecaptchaKey,
          shop_address: shop_address,
          whatsappNummber: _whatsappNo!,
          // gst: gst,
          image: profilePick!.path,
          adharFront: adharfront,
          adharBack: adharback,
          pan: pan);

      // context.go("/");

      // if ((mail_verification_status.$ && _register_by == "email") ||
      //     _register_by == "phone") {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return Otp(
      //       verify_by: _register_by,
      //       user_id: signupResponse.user_id,
      //     );
      //   }));
      // } else {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return Login();
      //   }));
      // }
    } else {
      if (shop_address.isEmpty) {
        ToastComponent.showDialog("Business address is required.",
            gravity: Toast.center, duration: Toast.lengthLong);

        return;
      }
      if (_businessNameController.text.isEmpty) {
        ToastComponent.showDialog("Business Name is required.",
            gravity: Toast.center, duration: Toast.lengthLong);

        return;
      }
      if (_businessPhotoController.text.isEmpty) {
        ToastComponent.showDialog("Business Photo is required.",
            gravity: Toast.center, duration: Toast.lengthLong);

        return;
      }
      // if (_businessImageController.text.isEmpty) {
      //   ToastComponent.showDialog("Business Image is required.",
      //       gravity: Toast.center, duration: Toast.lengthLong);

      //   return;
      // }
      //     if (gst.isEmpty) {
      //   ToastComponent.showDialog("GST is required",
      //       gravity: Toast.center, duration: Toast.lengthLong);
      //
      //   return;
      // }
      // if (_adharFrontController.text.isEmpty ||
      //     _adharBackController.text.isEmpty) {
      //   ToastComponent.showDialog("Adhar card is required",
      //       gravity: Toast.center, duration: Toast.lengthLong);
      //
      //   return;
      // }
      if (pan.isEmpty) {
        ToastComponent.showDialog("Pan card is required",
            gravity: Toast.center, duration: Toast.lengthLong);

        return;
      }
      //   else if (_doc1Controller.text.isEmpty ||
      //     _doc2Controller.text.isEmpty ||
      //     _doc3Controller.text.isEmpty) {
      //   ToastComponent.showDialog("Company Document are required",
      //       gravity: Toast.center, duration: Toast.lengthLong);

      //   return;
      // }
      Loading.show(context);

      await AuthRepository()
          .getSignupResponse(context,
              name: name,
              email_or_phone: _register_by == 'email' ? email : _phone,
              registration_type: "business",
              password: password,
              passowrd_confirmation: password_confirm,
              register_by: _register_by,
              capchaKey: googleRecaptchaKey,
              shop_address: shop_address,
              whatsappNummber: _whatsappNo!,
              business_type: businessType,
              businessName: _businessNameController.text,
              // businessImage: businessImage,
              businessPhoto: businessPhoto,
              gst: _gstController.text,
              gstPhoto: gstPhoto,
              image: profilePick!.path,
              adharFront: adharfront,
              adharBack: adharback,
              pan: pan)
          .onError((e, _) {
        Loading.close();
        ToastComponent.showDialog(e.toString(),
            gravity: Toast.center, duration: 3);
        return Future.error([]);
      });

      // context.go("/");

      // if ((mail_verification_status.$ && _register_by == "email") ||
      //     _register_by == "phone") {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return Otp(
      //       verify_by: _register_by,
      //       user_id: signupResponse.user_id,
      //     );
      //   }));
      // } else {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return Login();
      //   }));
      // }
    }
  }

  Future<FilePickerResult?> pickSingleFile(
      {List<String>? allowedExtensions}) async {
    return await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ??
            [
              "jpg",
              "jpeg",
              "png",
              "svg",
              "webp",
              "gif",
              "mp4",
              "mpg",
              "mpeg",
              "webm",
              "ogg",
              "avi",
              "mov",
              "flv",
              "swf",
              "mkv",
              "wmv",
              "wma",
              "aac",
              "wav",
              "mp3",
              "zip",
              "rar",
              "7z",
              "doc",
              "txt",
              "docx",
              "pdf",
              "csv",
              "xml",
              "ods",
              "xlr",
              "xls",
              "xlsx"
            ]);
  }

  onTapProfile() async {
    await pickSingleFile(allowedExtensions: ["jpg", "jpeg", "png"])
        .then((value) {
      if (value != null) {
        profilePick = File(value.paths.first!);
      }
    });
    setState(() {
      print(profilePick!.path);
    });
  }

  onTapGST() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        gstPhoto = value.paths.first ?? "";
        _gstPhotoController.text = gstPhoto.split("/").last;
      }
    });
    setState(() {});
  }

  onTapAdharFront() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        adharfront = value.paths.first ?? "";
        _adharFrontController.text = adharfront.split("/").last;
      }
    });
    setState(() {});
  }

  onTapAdharBack() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        adharback = value.paths.first ?? "";
        _adharBackController.text = adharback.split("/").last;
      }
    });
    setState(() {});
  }

  onTapPan() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        pan = value.paths.first ?? "";
        _panCardController.text = pan.split("/").last;
      }
    });
    setState(() {});
  }

  onTapBuisnessPhoto() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        businessPhoto = (value.paths.first ?? "");
        _businessPhotoController.text = businessPhoto.split("/").last;
      }
    });
    setState(() {});
  }

  onTapBuisnessImage() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        businessImage = (value.paths.first ?? "");
        _businessImageController.text = businessImage.split("/").last;
      }
    });
    setState(() {});
  }

  onTapDoc1() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        doc1 = value.paths.first ?? "";
        _doc1Controller.text = doc1.split("/").last;
      }
    });
    setState(() {});
  }

  onTapDoc2() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        doc2 = value.paths.first ?? "";
        _doc2Controller.text = doc2.split("/").last;
      }
    });
    setState(() {});
  }

  onTapDoc3() async {
    await pickSingleFile().then((value) {
      if (value != null) {
        doc3 = value.paths.first ?? "";
        _doc3Controller.text = doc3.split("/").last;
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context,
        "${AppLocalizations.of(context)!.join_ucf} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Column buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTapProfile,
          child: Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: MyTheme.white, width: 1),
                //shape: BoxShape.rectangle,
              ),
              child: profilePick != null
                  ? ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.all(Radius.circular(100.0)),
                      child: Image.file(profilePick!)
                      //  FadeInImage.assetNetwork(
                      //   placeholder: 'assets/placeholder.png',
                      //   image: "${avatar_original.$}",
                      //   fit: BoxFit.fill,
                      // )
                      )
                  : Image.asset(
                      'assets/profile_placeholder.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
        ),
        // Container(
        //   width: _screen_width * (3 / 4),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           AppLocalizations.of(context)!.name_ucf,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _nameController,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "John Doe"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           AppLocalizations.of(context)!.email_ucf,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       if (_register_by == "email")
        //         Padding(
        //           padding: const EdgeInsets.only(bottom: 8.0),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.end,
        //             children: [
        //               Container(
        //                 height: 36,
        //                 child: TextField(
        //                   controller: _emailController,
        //                   autofocus: false,
        //                   decoration: InputDecorations.buildInputDecoration_1(
        //                       hint_text: "johndoe@example.com"),
        //                 ),
        //               ),
        //               otp_addon_installed.$
        //                   ? GestureDetector(
        //                       onTap: () {
        //                         setState(() {
        //                           _register_by = "phone";
        //                         });
        //                       },
        //                       child: Text(
        //                         AppLocalizations.of(context)!
        //                             .or_register_with_a_phone,
        //                         style: TextStyle(
        //                             color: MyTheme.accent_color,
        //                             fontStyle: FontStyle.italic,
        //                             decoration: TextDecoration.underline),
        //                       ),
        //                     )
        //                   : Container()
        //             ],
        //           ),
        //         )
        //       else
        //         // Padding(
        //         //   padding: const EdgeInsets.only(bottom: 4.0),
        //         //   child: Text(
        //         //     AppLocalizations.of(context)!.phone_ucf,
        //         //     style: TextStyle(
        //         //         color: MyTheme.accent_color,
        //         //         fontWeight: FontWeight.w600),
        //         //   ),
        //         // ),
        //         // else
        //         Padding(
        //           padding: const EdgeInsets.only(bottom: 8.0),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.end,
        //             children: [
        //               Container(
        //                 height: 36,
        //                 child: CustomInternationalPhoneNumberInput(
        //                   countries: countries_code,
        //                   maxLength: 10,
        //                   onInputChanged: (PhoneNumber number) {
        //                     print(number.phoneNumber);
        //                     setState(() {
        //                       _phone = number.phoneNumber;
        //                     });
        //                   },
        //                   onInputValidated: (bool value) {
        //                     print(value);
        //                   },
        //                   selectorConfig: SelectorConfig(
        //                     selectorType: PhoneInputSelectorType.DIALOG,
        //                   ),
        //                   ignoreBlank: false,
        //                   autoValidateMode: AutovalidateMode.disabled,
        //                   selectorTextStyle:
        //                       TextStyle(color: MyTheme.font_grey),
        //                   initialValue: countries_code.isEmpty
        //                       ? null
        //                       : PhoneNumber(
        //                           isoCode: countries_code[0].toString()),
        //                   textFieldController: _phoneNumberController,
        //                   formatInput: false,
        //                   keyboardType: TextInputType.numberWithOptions(
        //                       signed: true, decimal: true),
        //                   inputDecoration:
        //                       InputDecorations.buildInputDecoration_phone(
        //                           hint_text: "01XXX XXXXX"),
        //                   onSaved: (PhoneNumber number) {
        //                     //print('On Saved: $number');
        //                   },
        //                 ),
        //               ),
        //               GestureDetector(
        //                 onTap: () {
        //                   setState(() {
        //                     _register_by = "email";
        //                   });
        //                 },
        //                 child: Text(
        //                   AppLocalizations.of(context)!
        //                       .or_register_with_an_email,
        //                   style: TextStyle(
        //                       color: MyTheme.accent_color,
        //                       fontStyle: FontStyle.italic,
        //                       decoration: TextDecoration.underline),
        //                 ),
        //               )
        //             ],
        //           ),
        //         ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           AppLocalizations.of(context)!.password_ucf,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.end,
        //           children: [
        //             Container(
        //               height: 36,
        //               child: TextField(
        //                 controller: _passwordController,
        //                 autofocus: false,
        //                 obscureText: true,
        //                 enableSuggestions: false,
        //                 autocorrect: false,
        //                 decoration: InputDecorations.buildInputDecoration_1(
        //                     hint_text: "• • • • • • • •"),
        //               ),
        //             ),
        //             Text(
        //               AppLocalizations.of(context)!
        //                   .password_must_contain_at_least_6_characters,
        //               style: TextStyle(
        //                   color: MyTheme.textfield_grey,
        //                   fontStyle: FontStyle.italic),
        //             )
        //           ],
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           AppLocalizations.of(context)!.retype_password_ucf,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _passwordConfirmController,
        //             autofocus: false,
        //             obscureText: true,
        //             enableSuggestions: false,
        //             autocorrect: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "• • • • • • • •"),
        //           ),
        //         ),
        //       ),
        //       if (google_recaptcha.$)
        //         Container(
        //           height: _isCaptchaShowing ? 350 : 50,
        //           width: 300,
        //           child: Captcha(
        //             (keyValue) {
        //               googleRecaptchaKey = keyValue;
        //               setState(() {});
        //             },
        //             handleCaptcha: (data) {
        //               if (_isCaptchaShowing.toString() != data) {
        //                 _isCaptchaShowing = data;
        //                 setState(() {});
        //               }
        //             },
        //             isIOS: Platform.isIOS,
        //           ),
        //         ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           AppLocalizations.of(context)!.shop_address,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _shopaddressController,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "Business Address"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           "GST Number",
        //           // AppLocalizations.of(context)!.gst_number,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             onTap: onTapGST,
        //             controller: _gstController,
        //             textCapitalization: TextCapitalization.characters,
        //             readOnly: true,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "GST Number"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           "Adhar Card",
        //           // AppLocalizations.of(context)!.gst_number,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _adharFrontController,
        //             onTap: onTapAdharFront,
        //             readOnly: true,
        //             textCapitalization: TextCapitalization.characters,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "Adhar Front Side"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _adharBackController,
        //             onTap: onTapAdharBack,
        //             readOnly: true,
        //             textCapitalization: TextCapitalization.characters,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "Adhar Back Side"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           "Pan Card",
        //           // AppLocalizations.of(context)!.gst_number,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _panCardController,
        //             onTap: onTapPan,
        //             readOnly: true,
        //             textCapitalization: TextCapitalization.characters,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "Pan Card"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 4.0),
        //         child: Text(
        //           "Company Documents",
        //           // AppLocalizations.of(context)!.gst_number,
        //           style: TextStyle(
        //               color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _doc1Controller,
        //             onTap: onTapDoc1,
        //             readOnly: true,
        //             textCapitalization: TextCapitalization.characters,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "Document 1"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _doc2Controller,
        //             onTap: onTapDoc2,
        //             readOnly: true,
        //             textCapitalization: TextCapitalization.characters,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "Document 2"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(bottom: 8.0),
        //         child: Container(
        //           height: 36,
        //           child: TextField(
        //             controller: _doc3Controller,
        //             onTap: onTapDoc3,
        //             readOnly: true,
        //             textCapitalization: TextCapitalization.characters,
        //             autofocus: false,
        //             decoration: InputDecorations.buildInputDecoration_1(
        //                 hint_text: "Document 3"),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(top: 20.0),
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Container(
        //               height: 15,
        //               width: 15,
        //               child: Checkbox(
        //                   shape: RoundedRectangleBorder(
        //                       borderRadius: BorderRadius.circular(6)),
        //                   value: _isAgree,
        //                   onChanged: (newValue) {
        //                     _isAgree = newValue;
        //                     setState(() {});
        //                   }),
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.only(left: 8.0),
        //               child: Container(
        //                 width: DeviceInfo(context).width! - 130,
        //                 child: RichText(
        //                     maxLines: 2,
        //                     text: TextSpan(
        //                         style: TextStyle(
        //                             color: MyTheme.font_grey, fontSize: 12),
        //                         children: [
        //                           TextSpan(
        //                             text: "I agree to the",
        //                           ),
        //                           TextSpan(
        //                             recognizer: TapGestureRecognizer()
        //                               ..onTap = () {
        //                                 Navigator.push(
        //                                     context,
        //                                     MaterialPageRoute(
        //                                         builder: (context) =>
        //                                             CommonWebviewScreen(
        //                                               page_name:
        //                                                   "Terms Conditions",
        //                                               url:
        //                                                   "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
        //                                             )));
        //                               },
        //                             style:
        //                                 TextStyle(color: MyTheme.accent_color),
        //                             text: " Terms Conditions",
        //                           ),
        //                           TextSpan(
        //                             text: " &",
        //                           ),
        //                           TextSpan(
        //                             recognizer: TapGestureRecognizer()
        //                               ..onTap = () {
        //                                 Navigator.push(
        //                                     context,
        //                                     MaterialPageRoute(
        //                                         builder: (context) =>
        //                                             CommonWebviewScreen(
        //                                               page_name:
        //                                                   "Privacy Policy",
        //                                               url:
        //                                                   "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
        //                                             )));
        //                               },
        //                             text: " Privacy Policy",
        //                             style:
        //                                 TextStyle(color: MyTheme.accent_color),
        //                           )
        //                         ])),
        //               ),
        //             )
        //           ],
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(top: 30.0),
        //         child: Container(
        //           height: 45,
        //           child: Btn.minWidthFixHeight(
        //             minWidth: MediaQuery.of(context).size.width,
        //             height: 50,
        //             color: MyTheme.accent_color,
        //             shape: RoundedRectangleBorder(
        //                 borderRadius:
        //                     const BorderRadius.all(Radius.circular(6.0))),
        //             child: Text(
        //               AppLocalizations.of(context)!.sign_up_ucf,
        //               style: TextStyle(
        //                   color: Colors.white,
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w600),
        //             ),
        //             onPressed: _isAgree!
        //                 ? () {
        //                     // onPressSignUp();
        //                   }
        //                 : null,
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.only(top: 20.0),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Center(
        //                 child: Text(
        //               AppLocalizations.of(context)!.already_have_an_account,
        //               style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
        //             )),
        //             SizedBox(
        //               width: 10,
        //             ),
        //             InkWell(
        //               child: Text(
        //                 AppLocalizations.of(context)!.log_in,
        //                 style: TextStyle(
        //                     color: MyTheme.accent_color,
        //                     fontSize: 14,
        //                     fontWeight: FontWeight.w600),
        //               ),
        //               onTap: () {
        //                 Navigator.push(context,
        //                     MaterialPageRoute(builder: (context) {
        //                   return Login();
        //                 }));
        //               },
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // )
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () => setState(() {
                  isindividual = true;
                  onPressregistrationtype();
                }),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: MyTheme.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: !isindividual
                          ? null
                          : [
                              BoxShadow(
                                  color: MyTheme.blue_grey.withOpacity(.5),
                                  spreadRadius: 2,
                                  blurRadius: 4)
                            ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Individual",
                        style: TextStyle(
                            color: !isindividual
                                ? MyTheme.accent_color_shadow
                                : MyTheme.accent_color,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      Radio(
                          value: isindividual,
                          groupValue: true,
                          onChanged: (value) {
                            isindividual = !value!;
                            onPressregistrationtype();

                            setState(() {
                              print(value);
                            });
                          })
                    ],
                  ),
                ),
              )),
              SizedBox(
                width: 6,
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () => setState(() {
                  isindividual = false;
                  onPressregistrationtype();
                }),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: MyTheme.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isindividual
                          ? null
                          : [
                              BoxShadow(
                                  color: MyTheme.blue_grey.withOpacity(.5),
                                  spreadRadius: 2,
                                  blurRadius: 4)
                            ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Business",
                        style: TextStyle(
                            color: isindividual
                                ? MyTheme.accent_color_shadow
                                : MyTheme.accent_color,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      Radio(
                          value: isindividual,
                          groupValue: false,
                          onChanged: (value) {
                            isindividual = !value!;
                            onPressregistrationtype();

                            setState(() {});
                          })
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
        if (isindividual)
          individual_body(_screen_width)
        else
          busyniess_body(_screen_width)
      ],
    );
  }

  Widget individual_body(double _screen_width) {
    return Container(
      width: _screen_width * (3 / 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              AppLocalizations.of(context)!.name_ucf + "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _nameController,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "John Doe"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              (_register_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.phone_ucf) +
                  "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          if (_register_by == "email")
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 36,
                    child: TextField(
                      controller: _emailController,
                      autofocus: false,
                      decoration: InputDecorations.buildInputDecoration_1(
                          hint_text: "johndoe@example.com"),
                    ),
                  ),
                  otp_addon_installed.$
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _register_by = "phone";
                            });
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .or_register_with_a_phone,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      : Container()
                ],
              ),
            )
          else
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 4.0),
            //   child: Text(
            //     AppLocalizations.of(context)!.phone_ucf,
            //     style: TextStyle(
            //         color: MyTheme.accent_color,
            //         fontWeight: FontWeight.w600),
            //   ),
            // ),
            // else
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 36,
                    child: CustomInternationalPhoneNumberInput(
                      countries: countries_code,
                      maxLength: 10,
                      onInputChanged: (PhoneNumber number) {
                        print(number.phoneNumber);
                        setState(() {
                          _phone = number.phoneNumber;
                        });
                      },
                      onInputValidated: (bool value) {
                        print(value);
                      },
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.DIALOG,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                      initialValue: countries_code.isEmpty
                          ? null
                          : PhoneNumber(isoCode: countries_code[0].toString()),
                      textFieldController: _phoneNumberController,
                      formatInput: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputDecoration:
                          InputDecorations.buildInputDecoration_phone(
                              hint_text: "01XXX XXXXX"),
                      onSaved: (PhoneNumber number) {
                        //print('On Saved: $number');
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _register_by = "email";
                      });
                    },
                    child: Text(
                      AppLocalizations.of(context)!.or_register_with_an_email,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              AppLocalizations.of(context)!.password_ucf + "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 36,
                  child: TextField(
                    controller: _passwordController,
                    autofocus: false,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "• • • • • • • •"),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!
                      .password_must_contain_at_least_6_characters,
                  style: TextStyle(
                      color: MyTheme.textfield_grey,
                      fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              AppLocalizations.of(context)!.retype_password_ucf + "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _passwordConfirmController,
                autofocus: false,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "• • • • • • • •"),
              ),
            ),
          ),
          if (google_recaptcha.$)
            Container(
              height: _isCaptchaShowing ? 350 : 50,
              width: 300,
              child: Captcha(
                (keyValue) {
                  googleRecaptchaKey = keyValue;
                  setState(() {});
                },
                handleCaptcha: (data) {
                  if (_isCaptchaShowing.toString() != data) {
                    _isCaptchaShowing = data;
                    setState(() {});
                  }
                },
                isIOS: Platform.isIOS,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "WhatsApp No*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: CustomInternationalPhoneNumberInput(
                countries: countries_code,
                maxLength: 10,
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _whatsappNo = number.phoneNumber;
                  });
                },
                onInputValidated: (bool value) {
                  print(value);
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                initialValue: countries_code.isEmpty
                    ? null
                    : PhoneNumber(isoCode: countries_code[0].toString()),
                textFieldController: _whatsappNumberController,
                formatInput: false,
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputDecoration: InputDecorations.buildInputDecoration_phone(
                    hint_text: "01XXX XXXXX"),
                onSaved: (PhoneNumber number) {
                  //print('On Saved: $number');
                },
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 4.0),
          //   child: Text(
          //     AppLocalizations.of(context)!.shop_address,
          //     style: TextStyle(
          //         color: MyTheme.accent_color, fontWeight: FontWeight.w600),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       controller: _shopaddressController,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Business Address"),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 4.0),
          //   child: Text(
          //     "GST Number",
          //     // AppLocalizations.of(context)!.gst_number,
          //     style: TextStyle(
          //         color: MyTheme.accent_color, fontWeight: FontWeight.w600),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       onTap: onTapGST,
          //       controller: _gstController,
          //       textCapitalization: TextCapitalization.characters,
          //       readOnly: true,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "GST Number"),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Adhar Card",
              // AppLocalizations.of(context)!.gst_number,
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _adharFrontController,
                // onTap: onTapAdharFront,
                // readOnly: true,
                onChanged: (value) => adharfront = value,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textCapitalization: TextCapitalization.characters,
                autofocus: false, maxLength: 12,
                keyboardType: TextInputType.number,
                decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "Adhar Number")
                    .copyWith(counterText: ""),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       onChanged: (value) => adharback = value,
          //       controller: _adharBackController,
          //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          //       // onTap: onTapAdharBack,
          //       keyboardType: TextInputType.number,
          //       // readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Adhar Back Side"),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Pan Card",
              // AppLocalizations.of(context)!.gst_number,
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _panCardController,
                onChanged: (value) => pan = value,
                // onTap: onTapPan,
                // readOnly: true,
                textCapitalization: TextCapitalization.characters,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "Pan Card"),
              ),
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.only(bottom: 4.0),
          //   child: Text(
          //     "Company Documents",
          //     // AppLocalizations.of(context)!.gst_number,
          //     style: TextStyle(
          //         color: MyTheme.accent_color, fontWeight: FontWeight.w600),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       controller: _doc1Controller,
          //       onTap: onTapDoc1,
          //       readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Document 1"),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       controller: _doc2Controller,
          //       onTap: onTapDoc2,
          //       readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Document 2"),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       controller: _doc3Controller,
          //       onTap: onTapDoc3,
          //       readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Document 3"),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                  width: 15,
                  child: Checkbox(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      value: _isAgree,
                      onChanged: (newValue) {
                        _isAgree = newValue;
                        setState(() {});
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: DeviceInfo(context).width! - 130,
                    child: RichText(
                        maxLines: 2,
                        text: TextSpan(
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12),
                            children: [
                              TextSpan(
                                text: "I agree to the",
                              ),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CommonWebviewScreen(
                                                  page_name: "Terms Conditions",
                                                  url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                                )));
                                  },
                                style: TextStyle(color: MyTheme.accent_color),
                                text: " Terms Conditions",
                              ),
                              TextSpan(
                                text: " &",
                              ),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CommonWebviewScreen(
                                                  page_name: "Privacy Policy",
                                                  url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                                )));
                                  },
                                text: " Privacy Policy",
                                style: TextStyle(color: MyTheme.accent_color),
                              )
                            ])),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Container(
              height: 45,
              child: Btn.minWidthFixHeight(
                minWidth: MediaQuery.of(context).size.width,
                height: 50,
                color: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                child: Text(
                  AppLocalizations.of(context)!.sign_up_ucf,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: _isAgree!
                    ? () {
                        onPressSignUp();
                      }
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  AppLocalizations.of(context)!.already_have_an_account,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                )),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  child: Text(
                    AppLocalizations.of(context)!.log_in,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Login();
                    }));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget busyniess_body(double _screen_width) {
    return Container(
      width: _screen_width * (3 / 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: PopupMenuButton(
              initialValue: businessType,
              child: Row(
                children: [
                  Text(
                    businessType,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down)
                ],
              ),
              // icon: Icon(Icons.keyboard_arrow_down),
              itemBuilder: (_) {
                return [
                  PopupMenuItem(
                    child: Text("Distributorship"),
                    onTap: () {
                      setState(() {
                        businessType = "Distributorship";
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: Text("Retailing"),
                    onTap: () {
                      setState(() {
                        businessType = "Retailing";
                      });
                    },
                  ),
                ];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              AppLocalizations.of(context)!.name_ucf + "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _nameController,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "John Doe"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              (_register_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.phone_ucf) +
                  "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          if (_register_by == "email")
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 36,
                    child: TextField(
                      controller: _emailController,
                      autofocus: false,
                      decoration: InputDecorations.buildInputDecoration_1(
                          hint_text: "johndoe@example.com"),
                    ),
                  ),
                  otp_addon_installed.$
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _register_by = "phone";
                            });
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .or_register_with_a_phone,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      : Container()
                ],
              ),
            )
          else
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 4.0),
            //   child: Text(
            //     AppLocalizations.of(context)!.phone_ucf,
            //     style: TextStyle(
            //         color: MyTheme.accent_color,
            //         fontWeight: FontWeight.w600),
            //   ),
            // ),
            // else
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 36,
                    child: CustomInternationalPhoneNumberInput(
                      countries: countries_code,
                      maxLength: 10,
                      onInputChanged: (PhoneNumber number) {
                        print(number.phoneNumber);
                        setState(() {
                          _phone = number.phoneNumber;
                        });
                      },
                      onInputValidated: (bool value) {
                        print(value);
                      },
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.DIALOG,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                      initialValue: countries_code.isEmpty
                          ? null
                          : PhoneNumber(isoCode: countries_code[0].toString()),
                      textFieldController: _phoneNumberController,
                      formatInput: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputDecoration:
                          InputDecorations.buildInputDecoration_phone(
                              hint_text: "01XXX XXXXX"),
                      onSaved: (PhoneNumber number) {
                        //print('On Saved: $number');
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _register_by = "email";
                      });
                    },
                    child: Text(
                      AppLocalizations.of(context)!.or_register_with_an_email,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              AppLocalizations.of(context)!.password_ucf + "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 36,
                  child: TextField(
                    controller: _passwordController,
                    autofocus: false,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "• • • • • • • •"),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!
                      .password_must_contain_at_least_6_characters,
                  style: TextStyle(
                      color: MyTheme.textfield_grey,
                      fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              AppLocalizations.of(context)!.retype_password_ucf + "*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _passwordConfirmController,
                autofocus: false,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "• • • • • • • •"),
              ),
            ),
          ),
          if (google_recaptcha.$)
            Container(
              height: _isCaptchaShowing ? 350 : 50,
              width: 300,
              child: Captcha(
                (keyValue) {
                  googleRecaptchaKey = keyValue;
                  setState(() {});
                },
                handleCaptcha: (data) {
                  if (_isCaptchaShowing.toString() != data) {
                    _isCaptchaShowing = data;
                    setState(() {});
                  }
                },
                isIOS: Platform.isIOS,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "WhatsApp No*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: CustomInternationalPhoneNumberInput(
                countries: countries_code,
                maxLength: 10,
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _whatsappNo = number.phoneNumber;
                  });
                },
                onInputValidated: (bool value) {
                  print(value);
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                initialValue: countries_code.isEmpty
                    ? null
                    : PhoneNumber(isoCode: countries_code[0].toString()),
                textFieldController: _whatsappNumberController,
                formatInput: false,
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputDecoration: InputDecorations.buildInputDecoration_phone(
                    hint_text: "01XXX XXXXX"),
                onSaved: (PhoneNumber number) {
                  //print('On Saved: $number');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Business Name*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _businessNameController,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "Business Name"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Business Address*",
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _shopaddressController,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "Business Address"),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 4.0),
          //   child: Text(
          //     "GST Photo",
          //     // AppLocalizations.of(context)!.gst_number,
          //     style: TextStyle(
          //         color: MyTheme.accent_color, fontWeight: FontWeight.w600),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       onTap: onTapGST,
          //       controller: _gstPhotoController,
          //       textCapitalization: TextCapitalization.characters,
          //       readOnly: true,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "GST Photo"),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "GST Number",
              // AppLocalizations.of(context)!.gst_number,
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                // onTap: onTapGST,
                controller: _gstController,
                textCapitalization: TextCapitalization.characters,
                // readOnly: true,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "GST Number"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Adhar Card",
              // AppLocalizations.of(context)!.gst_number,
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _adharFrontController,
                // onTap: onTapAdharFront,
                onChanged: (value) => adharfront = value,
                // readOnly: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                textCapitalization: TextCapitalization.characters,
                maxLength: 12,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "Adhar Number")
                    .copyWith(counterText: ""),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       onChanged: (value) => adharback = value,
          //       controller: _adharBackController,
          //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          //       // onTap: onTapAdharBack,
          //       keyboardType: TextInputType.number,
          //       // readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Adhar Back Side"),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Pan Card*",
              // AppLocalizations.of(context)!.gst_number,
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                controller: _panCardController,
                onChanged: (value) => pan = value,
                // onTap: onTapPan,
                // readOnly: true,
                textCapitalization: TextCapitalization.characters,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "Pan Card"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "Business Photo*",
              // AppLocalizations.of(context)!.gst_number,
              style: TextStyle(
                  color: MyTheme.accent_color, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 36,
              child: TextField(
                // controller: _panCardController,
                controller: _businessPhotoController,
                onTap: onTapBuisnessPhoto,
                readOnly: true,
                textCapitalization: TextCapitalization.characters,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "Business Photo"),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 4.0),
          //   child: Text(
          //     "Business Image*",
          //     // AppLocalizations.of(context)!.gst_number,
          //     style: TextStyle(
          //         color: MyTheme.accent_color, fontWeight: FontWeight.w600),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       // controller: _panCardController,
          //       controller: _businessImageController,
          //       onTap: onTapBuisnessImage,
          //       readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Business Image"),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 4.0),
          //   child: Text(
          //     "Company Documents",
          //     // AppLocalizations.of(context)!.gst_number,
          //     style: TextStyle(
          //         color: MyTheme.accent_color, fontWeight: FontWeight.w600),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       controller: _doc1Controller,
          //       onTap: onTapDoc1,
          //       readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Document 1"),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       controller: _doc2Controller,
          //       onTap: onTapDoc2,
          //       readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Document 2"),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Container(
          //     height: 36,
          //     child: TextField(
          //       controller: _doc3Controller,
          //       onTap: onTapDoc3,
          //       readOnly: true,
          //       textCapitalization: TextCapitalization.characters,
          //       autofocus: false,
          //       decoration: InputDecorations.buildInputDecoration_1(
          //           hint_text: "Document 3"),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                  width: 15,
                  child: Checkbox(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      value: _isAgree,
                      onChanged: (newValue) {
                        _isAgree = newValue;
                        setState(() {});
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: DeviceInfo(context).width! - 130,
                    child: RichText(
                        maxLines: 2,
                        text: TextSpan(
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12),
                            children: [
                              TextSpan(
                                text: "I agree to the",
                              ),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CommonWebviewScreen(
                                                  page_name: "Terms Conditions",
                                                  url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                                )));
                                  },
                                style: TextStyle(color: MyTheme.accent_color),
                                text: " Terms Conditions",
                              ),
                              TextSpan(
                                text: " &",
                              ),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CommonWebviewScreen(
                                                  page_name: "Privacy Policy",
                                                  url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                                )));
                                  },
                                text: " Privacy Policy",
                                style: TextStyle(color: MyTheme.accent_color),
                              )
                            ])),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Container(
              height: 45,
              child: Btn.minWidthFixHeight(
                minWidth: MediaQuery.of(context).size.width,
                height: 50,
                color: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                child: Text(
                  AppLocalizations.of(context)!.sign_up_ucf,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: _isAgree!
                    ? () {
                        onPressSignUp();
                      }
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  AppLocalizations.of(context)!.already_have_an_account,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                )),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  child: Text(
                    AppLocalizations.of(context)!.log_in,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Login();
                    }));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
