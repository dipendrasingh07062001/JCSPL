import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/currency_response.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

class CurrencyRepository{
Future<CurrencyResponse> getListResponse() async{
  String url=('${AppConfig.BASE_URL}/currencies');

  final response = await ApiRequest.get(url: url);
  return currencyResponseFromJson(response.body);
}
}