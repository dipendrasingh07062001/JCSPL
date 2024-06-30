
import 'package:active_ecommerce_flutter/custom/AIZTypeDef.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';

class ConfirmDialog{

  static show(BuildContext context,{String? title,required String message,String? yesText,String? noText,required OnPress pressYes}){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          title: Text("Please ensure us."),
          content: Row(
            children: [
              SizedBox(
                width: DeviceInfo(context).width! * 0.6,
                child: Text(message,style: TextStyle(fontSize: 14,color: MyTheme.font_grey),),)
            ],
          ),
          actions: [
            Btn.basic(
              color: MyTheme.font_grey,
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text(noText??"",style: TextStyle(fontSize: 14,color: MyTheme.white),),
            ),
            Btn.basic(
              color: MyTheme.golden,
              onPressed: () {
                Navigator.pop(context);
                pressYes();
              },
              child: Text("Yes",style: TextStyle(fontSize: 14,color: MyTheme.white),),
            ),
          ],
        );
      },);
  }
}