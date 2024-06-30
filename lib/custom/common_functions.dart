import 'dart:io';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommonFunctions{
  BuildContext context;

  CommonFunctions(this.context);

  appExitDialog() {
    showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            content: Text(AppLocalizations.of(context)!.do_you_want_close_the_app),
            actions: [
              TextButton(
                  onPressed: () {
                    Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                  },
                  child: Text(AppLocalizations.of(context)!.yes_ucf)),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.no_ucf)),
            ],
          ),
        ));
  }


 static TextStyle dashboardBoxNumber(context){
    return TextStyle(
        fontSize: 16,
        color: MyTheme.white,
        fontWeight: FontWeight.bold
    );
  }

  static TextStyle dashboardBoxText(context){
    return TextStyle(
        fontSize: 12,
        color: MyTheme.white,
        fontWeight: FontWeight.bold
    );
  }



}