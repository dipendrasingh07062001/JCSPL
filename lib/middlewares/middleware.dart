import 'package:http/http.dart' as http;

abstract class Middleware{
  bool next(http.Response response);
}