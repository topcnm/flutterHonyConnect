import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import '../constant/http.dart';

import '../model/user.dart';

Map<String, String> timeOutErrorFactory (String api) {
  return {
    "code": "9999",
    "msg": "$api 请求时间超时，请刷新再试"
  };
}

class HonyHttp {

  /// 常规GET
  static Future<String> get(String api, { Map params, LoginUser user }) async {
    String accessToken = user == null ? "" : user.accessToken;
    String refreshToken = user == null ? "" : user.refreshToken;

    StringBuffer paramStrBuffer = new StringBuffer();
    if (params != null && params.isNotEmpty) {
      params.forEach((key, value) {
        paramStrBuffer.write("$key" + "=" + "$value" + "&");
      });
    }

    String paramStr = paramStrBuffer.toString();

    // 组装api 和参数
    String combinedUrl = '$urlHost$api${paramStr.length > 0 ? "?" : ""}${paramStr.toString()}';

    http.Response response = await http.get(
      Uri.encodeFull(combinedUrl),
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      }
    ).timeout(new Duration(seconds: 10), onTimeout: () {
      throw(timeOutErrorFactory(api));
    });

    return response.body;
  }

  static Future<String> postForm(String api, { Map<String,String> params, LoginUser user }) async {
    String accessToken = user == null ? "" : user.accessToken;
    String refreshToken = user == null ? "" : user.refreshToken;

    String combinedUrl = '$urlHost$api';

    http.Response response = await http.post(
        Uri.encodeFull(combinedUrl),
        body: params,
        headers: {
          "Accept": "application/json, application/x-www-form-urlencoded",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
          "content-type": 'application/json',
        }
    ).timeout(new Duration(seconds: 10), onTimeout: () {
      throw(timeOutErrorFactory(api));
    });

    return response.body;
  }

  static Future<String> postJson(String api, { Map<String,String> params, LoginUser user }) async {
    String accessToken = user == null ? "" : user.accessToken;
    String refreshToken = user == null ? "" : user.refreshToken;

    String combinedUrl = '$urlHost$api';

    http.Response response = await http.post(
        Uri.encodeFull(combinedUrl),
        body: jsonEncode(params),
        headers: {
          "Accept": "application/json, application/x-www-form-urlencoded",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
          "content-type": 'application/json',
        }
    ).timeout(new Duration(seconds: 10), onTimeout: () {
      throw(timeOutErrorFactory(api));
    });

    return response.body;
  }
}
