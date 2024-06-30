import 'dart:convert';

import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/guest_checkout_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:toast/toast.dart';

import '../../custom/aiz_route.dart';
import '../../custom/btn.dart';
import '../../custom/loading.dart';
import '../../custom/toast_component.dart';
import '../../data_model/city_response.dart';
import '../../data_model/country_response.dart';
import '../../data_model/state_response.dart';
import '../../my_theme.dart';
import '../../repositories/address_repository.dart';
import '../shipping_info.dart';

class GuestCheckoutAddress extends StatefulWidget {
  const GuestCheckoutAddress({Key? key}) : super(key: key);

  @override
  State<GuestCheckoutAddress> createState() => _GuestCheckoutAddressState();
}

class _GuestCheckoutAddressState extends State<GuestCheckoutAddress> {
  //controllers for add purpose
  TextEditingController _addressController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;

  onSelectCountryDuringAdd(country) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  onSelectStateDuringAdd(state) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  onSelectCityDuringAdd(city) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setState(() {
      _cityController.text = city.name;
    });
  }

  String? name, email, address, country, state, city, postalCode, phone;
  bool? emailValid;
  setValues() async {
    name = _nameController.text.trim();
    email = _emailController.text.trim();
    address = _addressController.text.trim();
    country = _selected_country!.id.toString();
    state = _selected_state!.id.toString();
    city = _selected_city!.id.toString();
    postalCode = _postalCodeController.text.trim();
    phone = _phoneController.text.trim();
  }

  continueToDeliveryInfo() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!requiredFieldVerification()) {
      return;
    }
    Loading.show(context);
    await setValues();

    Map postValue = {};
    postValue.addAll({
      "email": email,
      "phone": phone,
    });
    var postBody = jsonEncode(postValue);
    var response =
        await GuestCheckoutRepository().guestCustomerInfoCheck(postBody);

    Loading.close();
    // print(response.result);
    // if email and phone matched return to page with massage
    if (response.result!) {
      ToastComponent.showDialog(LangText(context).local.already_have_account,
          gravity: Toast.center);
    } else if (!response.result!) {
      postValue.addAll({
        "name": name,
        "email": email,
        "address": address,
        "country_id": country,
        "state_id": state,
        "city_id": city,
        "postal_code": postalCode,
        "phone": phone,
        "longitude": null,
        "latitude": null,
        "temp_user_id": temp_user_id.$
      });
      var postBody = jsonEncode(postValue);

      guestEmail.$ = email!;
      guestEmail.save();
      AIZRoute.push(
        context,
        ShippingInfo(
          // this is only for when guest checkout shipping address to calculate shipping cost
          guestCheckOutShippingAddress: postBody,
        ),
      );
    }
  }

  bool requiredFieldVerification() {
    emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text.trim());

    if (_nameController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.name_required,
          gravity: Toast.center);
      return false;
    } else if (_emailController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.email_required,
          gravity: Toast.center);
      return false;
    } else if (!emailValid!) {
      ToastComponent.showDialog(LangText(context).local.enter_correct_email,
          gravity: Toast.center);
      return false;
    } else if (_addressController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(
          LangText(context).local.shipping_address_required,
          gravity: Toast.center);
      return false;
    } else if (_selected_country == null) {
      ToastComponent.showDialog(LangText(context).local.country_required,
          gravity: Toast.center);
      return false;
    } else if (_selected_state == null) {
      ToastComponent.showDialog(LangText(context).local.state_required,
          gravity: Toast.center);
      return false;
    } else if (_selected_city == null) {
      ToastComponent.showDialog(LangText(context).local.city_required,
          gravity: Toast.center);
      return false;
    } else if (_postalCodeController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.postal_code_required,
          gravity: Toast.center);
      return false;
    } else if (_phoneController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.phone_number_required,
          gravity: Toast.center);
      return false;
    }
    return true;
  }

  // onPopped(value) async {
  //   var location = value;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.transparent,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // continue to delivery button
              Btn.minWidthFixHeight(
                minWidth: MediaQuery.of(context).size.width,
                height: 50,
                color: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: Text(
                  AppLocalizations.of(context)!.continue_to_delivery_info_ucf,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  continueToDeliveryInfo();
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // name
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(AppLocalizations.of(context)!.name_ucf,
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _nameController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(
                        context, AppLocalizations.of(context)!.enter_your_name),
                  ),
                ),
              ),

              // email
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(AppLocalizations.of(context)!.email_ucf,
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _emailController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(
                        context, AppLocalizations.of(context)!.enter_email),
                  ),
                ),
              ),
              // address
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("${AppLocalizations.of(context)!.address_ucf} *",
                    style:
                        TextStyle(color: MyTheme.dark_font_grey, fontSize: 12)),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 55,
                  child: TextField(
                    controller: _addressController,
                    autofocus: false,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: buildAddressInputDecoration(context,
                        AppLocalizations.of(context)!.enter_address_ucf),
                  ),
                ),
              ),

              // country
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("${AppLocalizations.of(context)!.country_ucf} *",
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    suggestionsCallback: (name) async {
                      var countryResponse =
                          await AddressRepository().getCountryList(name: name);
                      return countryResponse.countries;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_countries_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic country) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          country.name,
                          style: TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    noItemsFoundBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.no_country_available,
                            style: TextStyle(color: MyTheme.medium_grey),
                          ),
                        ),
                      );
                    },
                    onSuggestionSelected: (dynamic country) {
                      onSelectCountryDuringAdd(country);
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      onTap: () {},
                      controller: _countryController,
                      onSubmitted: (txt) {},
                      decoration: buildAddressInputDecoration(context,
                          AppLocalizations.of(context)!.enter_country_ucf),
                    ),
                  ),
                ),
              ),
              // state
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("${AppLocalizations.of(context)!.state_ucf} *",
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    suggestionsCallback: (name) async {
                      if (_selected_country == null) {
                        var stateResponse = await AddressRepository()
                            .getStateListByCountry(); // blank response
                        return stateResponse.states;
                      }
                      var stateResponse = await AddressRepository()
                          .getStateListByCountry(
                              country_id: _selected_country!.id, name: name);
                      return stateResponse.states;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_states_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic state) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          state.name,
                          style: TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    noItemsFoundBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .no_state_available,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    onSuggestionSelected: (dynamic state) {
                      onSelectStateDuringAdd(state);
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      onTap: () {},
                      //autofocus: true,
                      controller: _stateController,
                      onSubmitted: (txt) {
                        // _searchKey = txt;
                        // setState(() {});
                        // _onSearchSubmit();
                      },
                      decoration: buildAddressInputDecoration(context,
                          AppLocalizations.of(context)!.enter_state_ucf),
                    ),
                  ),
                ),
              ),
              // city
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("${AppLocalizations.of(context)!.city_ucf} *",
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    suggestionsCallback: (name) async {
                      if (_selected_state == null) {
                        var cityResponse = await AddressRepository()
                            .getCityListByState(); // blank response
                        return cityResponse.cities;
                      }
                      var cityResponse = await AddressRepository()
                          .getCityListByState(
                              state_id: _selected_state!.id, name: name);
                      return cityResponse.cities;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!
                                    .loading_cities_ucf,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic city) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          city.name,
                          style: TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    noItemsFoundBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                AppLocalizations.of(context)!.no_city_available,
                                style: TextStyle(color: MyTheme.medium_grey))),
                      );
                    },
                    onSuggestionSelected: (dynamic city) {
                      onSelectCityDuringAdd(city);
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      onTap: () {},
                      //autofocus: true,
                      controller: _cityController,
                      onSubmitted: (txt) {
                        // keep blank
                      },
                      decoration: buildAddressInputDecoration(context,
                          AppLocalizations.of(context)!.enter_city_ucf),
                    ),
                  ),
                ),
              ),
              // postal code
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(AppLocalizations.of(context)!.postal_code,
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _postalCodeController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(context,
                        AppLocalizations.of(context)!.enter_postal_code_ucf),
                  ),
                ),
              ),
              // phone
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(AppLocalizations.of(context)!.phone_ucf,
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _phoneController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(context,
                        AppLocalizations.of(context)!.enter_phone_number),
                  ),
                ),
              ),

              // TextButton(
              //   onPressed: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) {
              //       return MapLocation();
              //     })).then((value) {
              //       onPopped(value);
              //     });
              //   },
              //   child: Text('set location'),
              // ),

              const SizedBox(
                height: 10,
              ),

              RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: LangText(context).local.existing_email_address,
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          AIZRoute.push(context, Login());
                        },
                      text: LangText(context).local.login_ucf,
                      style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: LangText(context).local.first_to_continue),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration buildAddressInputDecoration(BuildContext context, hintText) {
  return InputDecoration(
      filled: true,
      fillColor: MyTheme.light_grey,
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 0.5),
        borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 1.0),
        borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
        ),
      ),
      contentPadding: EdgeInsets.only(left: 8.0, top: 16.0, bottom: 16.0));
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    centerTitle: false,
    leading: Builder(
      builder: (context) => IconButton(
        icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_font_grey),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.shipping_info,
          style: TextStyle(
              fontSize: 16,
              color: MyTheme.dark_font_grey,
              fontWeight: FontWeight.bold),
        ),
      ],
    ),
    elevation: 0.0,
    titleSpacing: 0,
  );
}
