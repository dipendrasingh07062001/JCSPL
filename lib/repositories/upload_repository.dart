import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../data_model/common_response.dart';
import '../data_model/uploaded_file_list_response.dart';
import '../helpers/shared_value_helper.dart';
import 'api-request.dart';

class FileUploadRepository {
  Future<CommonResponse> fileUpload(File file) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/file/upload");

    Map<String, String> header = {
      "App-Language": app_language.$!,
      "Authorization": "Bearer ${access_token.$}",
      "Content-Type":
          "multipart/form-data; boundary=<calculated when request is sent>",
      "Accept": "*/*",
      "System-Key": AppConfig.system_key
    };

    final httpReq = http.MultipartRequest("POST", url);
    httpReq.headers.addAll(header);

    final image = await http.MultipartFile.fromPath("aiz_file", file.path);

    httpReq.files.add(image);

    final response = await httpReq.send();
    var commonResponse =
        CommonResponse(result: false, message: "File upload failed");

    var responseDecode = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      try {
        commonResponse = commonResponseFromJson(responseDecode);
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
    return commonResponse;
  }

  Future<UploadedFilesListResponse> getFiles(page, search, type, sort) async {
    String url =
        ("${AppConfig.BASE_URL}/file/all?page=$page&search=$search&type=$type&sort=$sort");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      "System-Key": AppConfig.system_key
    });

    return uploadedFilesListResponseFromJson(response.body);
  }

  Future<CommonResponse> deleteFile(id) async {
    String url = ("${AppConfig.BASE_URL}/file/delete/$id");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      "System-Key": AppConfig.system_key
    });

    return commonResponseFromJson(response.body);
  }
}
