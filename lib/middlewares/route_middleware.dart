import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

abstract class RouteMiddleware{
  Widget next();
}