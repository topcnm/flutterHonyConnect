import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user.dart';
import '../../model/appState.dart';
import '../../constant/http.dart';

import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';


class UserStartLoginAction {}

class UserFinishLoginAction {}

class UserAuthSuccessAction {
  final String accessToken;
  final String refreshToken;
  UserAuthSuccessAction(this.accessToken, this.refreshToken);
}

class UserLoginSuccessAction {
  final LoginUser user;
  UserLoginSuccessAction(this.user);
}

class UserLoginFailAction {
  final String errorMsg;
  UserLoginFailAction(this.errorMsg);
}

final Function userLoginActionCreator = ({
  String username, 
  String password,
  String accessToken,
  String refreshToken, 
  Function callback
}) {
  return (Store<AppState> store) async {
    var _accessToken, _refreshToken;
    
    if (accessToken == null) {  // 在值传入用户名时  
      // 1. 开始请求
      store.dispatch(UserStartLoginAction());
      // 2. 请求授权
      http.Response authInfo = await fetchAuthActionCreator(
          username: username,
          password: password
      );
      // 3. 解析授权请求
      Map<String, dynamic> authResData = jsonDecode(authInfo.body);
      // 4. 授权失败
      if (authResData['error'] != null) {
        store.dispatch(UserFinishLoginAction());
        store.dispatch(UserLoginFailAction(authResData['error_description']));
        return callback(false);
      }
      _accessToken = authResData['access_token'];
      _refreshToken = authResData['refresh_token'];
    } else { // 在值传入token时 
      _accessToken = accessToken;
      _refreshToken = refreshToken;
    }

    http.Response userInfo = await fetchUserInfoActionCreator(
        accessToken: _accessToken,
        refreshToken: _refreshToken
    );

    Map<String, dynamic> userResData = jsonDecode(userInfo.body);

    if (userResData['success'] == false || userResData['result'] == null) {
      store.dispatch(UserFinishLoginAction());
      store.dispatch(UserLoginFailAction(userResData['message']));
      return callback(false);
    }

    LoginUser user = new LoginUser(
      isLoading: false,
      errorMsg: '',

      accessToken: _accessToken,
      refreshToken: _refreshToken,

      userId: userResData['result']['userId'],
      userType: userResData['result']['userType'],
      username: userResData['result']['username'],
      account: userResData['result']['account'],
      accountId: userResData['result']['accountId'],

      locale: userResData['result']['locale'] == "en" ? Language.en : Language.zh,
      mobile: userResData['result']['mobile'],

      mail: userResData['result']['mail'],
      photoUrl: userResData['result']['photoUrl'],
      name: userResData['result']['name'],
      position: userResData['result']['position'],
    );

    store.dispatch(UserFinishLoginAction());
    store.dispatch(UserLoginSuccessAction(user));
    recordTokenInfo(_accessToken, _refreshToken);

    callback(true);
    return null;
  };
};

final Function recordTokenInfo = (String accessToken, String refreshToken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('accessToken', accessToken);
  prefs.setString('refreshToken', refreshToken);
};

final Function fetchAuthActionCreator = ({String username, String password}) async {
  http.Response authResponse = await http.post(
    Uri.encodeFull('$urlHost/ucm/oauth/token'),
    body: {
      "username": username,
      "password": password,
      "grant_type": 'password',
      "scope": "",
    },
    headers: {
      "Accept": "application/json, application/x-www-form-urlencoded",
      "Authorization": "Basic aG9ueWNvbm5lY3Q6MTIzNDU2",
    }
  );

  return authResponse;
};

final Function fetchUserInfoActionCreator = ({String accessToken, String refreshToken}) async {
  http.Response userResponse = await http.get(
    Uri.encodeFull('$urlHost/ucm/user/currentUser'),
    headers: {
      "Accept": "application/json, text/plain, */*",
      "Authorization": 'bearer $accessToken',
      "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
    }
  );
  return userResponse;
};
