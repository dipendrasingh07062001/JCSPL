import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/pickup_points_response.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:http/http.dart' as http;

class PickupPointRepository{
  Future<PickupPointListResponse> getPickupPointListResponse()async{
    String url=('${AppConfig.BASE_URL}/pickup-list');

    final response = await ApiRequest.get(url: url);

    //print("response ${response.body}");

    return pickupPointListResponseFromJson(response.body);
  }
}