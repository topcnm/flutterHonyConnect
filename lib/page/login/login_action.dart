import 'dart:convert';
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

final Function userLoginActionCreator = ({String username, String password, Function callback}) {
  return (Store<AppState> store) async {
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
    if (authResData['error'] !=null) {
      store.dispatch(UserFinishLoginAction());
      store.dispatch(UserLoginFailAction(authResData['error_description']));
      return callback(false);
    }

    String accessToken = authResData['access_token'];
    String refreshToken = authResData['refresh_token'];

    http.Response userInfo = await fetchUserInfoActionCreator(
        accessToken: accessToken,
        refreshToken: refreshToken
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

      accessToken: accessToken,
      refreshToken: refreshToken,

      userId: userResData['result']['userId'],
      userType: userResData['result']['userType'],
      username: userResData['result']['username'],
      account: userResData['result']['account'],
      accountId: userResData['result']['accountId'],

      locale: userResData['result']['locale'],
      mobile: userResData['result']['mobile'],

      mail: userResData['result']['mail'],
      photoUrl: userResData['result']['photoUrl'],
      name: userResData['result']['name'],
      position: userResData['result']['position'],
    );

    store.dispatch(UserFinishLoginAction());
    store.dispatch(UserLoginSuccessAction(user));

    callback(true);
    return null;
  };
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
