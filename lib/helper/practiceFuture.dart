import 'dart:async';
import 'dart:convert';
import '../constant/http.dart';
import 'package:http/http.dart' as http;

void main() {
  getToken().then((res){
    Map<String, dynamic> responseData = jsonDecode(res.body);

    if (responseData['error'] != null) {
      throw(responseData["error_description"]);
    }

    String accessToken = responseData['access_token'];
    String refreshToken = responseData['refresh_token'];

    return getUsername(accessToken, refreshToken);

  }).then((res1){
    Map<String, dynamic> userResData = jsonDecode(res1.body);

    if (userResData['success'] == false) {
      throw(userResData['message']);
    }
    print(userResData);

  }).catchError((value){
      print("error is $value");
  }).whenComplete((){
      print("Anyway, we should close connection");
  });
}

Future getToken() async {
  http.Response tokenResponse = await http.post(
    Uri.encodeFull('http://10.122.251.62:12345/ucm/oauth/token'),
    body: {
      "username": "otzhaoning1",
      "password": "1",
      "grant_type": "password",
      "scope": "",
    },
    headers: {
      "Accept": "application/json, application/x-www-form-urlencoded",
      "Authorization": "Basic aG9ueWNvbm5lY3Q6MTIzNDU2",
    }
  );
  return tokenResponse;
}

Future getUsername(String accessToken, String refreshToken) async {
  http.Response userResponse = await http.get(
      Uri.encodeFull('http://10.122.251.62:12345/ucm/user/currentUser'),
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      }
  );
  return userResponse;
}


class HttpHelper {
  Future getData(Map<String, dynamic> queryPrams, String api) async {
    String accessToken = 'aaaa';
    String refreshToken = 'bbbb';

    http.Response userResponse = await http.get(
        Uri.encodeFull('$urlHost'),
        headers: {
          "Accept": "application/json, text/plain, */*",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        }
    );
    return userResponse;
  }
}