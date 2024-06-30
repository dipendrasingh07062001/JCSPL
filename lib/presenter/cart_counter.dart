

import 'dart:async';

import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:flutter/material.dart';

class CartCounter extends ChangeNotifier{

  int cartCounter=0;



  getCount()async{
    var res = await CartRepository().getCartCount();
    cartCounter = res.count;
    notifyListeners();
  }

}