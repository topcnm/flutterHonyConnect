import 'dart:async';
import 'package:http/http.dart' as http;
import '../constant/http.dart';

class TimHttp {

  static Future<String> get(String url, {Map<String,String> params}) async {
    ///1. 获取redux中的数据；
    /// 2.拼装params

    String accessToken = "accessToken";
    String refreshToken = "refreshToken";

    http.Response response = await http.get(
      Uri.encodeFull('$urlHost/cm/news/findFocus?contentPlatform=CNTNTPLT_NEWS'),
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      }
    );

    return response.body;
  }

}