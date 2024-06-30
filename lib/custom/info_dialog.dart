import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

class InfoDialog {
  static show(
      {required String title,
      Widget? content}) {
    return OneContext().showDialog(
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,

        title: Container(
          decoration: BoxDecoration(color: MyTheme.accent_color,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(4),topRight:Radius.circular(4), ),
          ),
          padding: EdgeInsets.only(left: 24,top: 8,bottom: 8),

          child: Text(
            title,
            style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: MyTheme.white),
          ),
        ),
        content: content ??Text(""),
        actions: [
          Btn.basic(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: MyTheme.grey_153,
            onPressed: () => Navigator.pop(context),
            child: Text(LangText(context).local.ok,style: TextStyle(fontSize: 14,color:MyTheme.white )),
          ),
        ],
      ),
    );
  }
}
