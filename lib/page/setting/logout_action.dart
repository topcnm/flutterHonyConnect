import 'dart:convert';
import 'package:flutter/material.dart';
import '../../model/appState.dart';
import '../../model/user.dart';
import '../../constant/http.dart';

import '../login/login_action.dart';

import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';

import '../language/language-redux.dart';

class UserLogoutAction {}

class UserSwitchLanguage {
  final Language lg;
  UserSwitchLanguage(this.lg);
}

final Function userLogoutActionCreator = ({ Function callback }) {
  return (Store<AppState> store) async {
    String accessToken = store.state.loginUser.accessToken;
    String refreshToken = store.state.loginUser.refreshToken;

    http.Response logoutRes = await _logout(
      accessToken: accessToken,
      refreshToken: refreshToken
    );

    Map<String, dynamic> logoutResData = jsonDecode(logoutRes.body);
    print(logoutResData);
    if (logoutResData['success'] != true) {
      store.dispatch(UserLoginFailAction(logoutResData['message']));
      return callback(false);
    }
    store.dispatch(UserLogoutAction());
    callback(true);
  };
};

final Function _logout = ({String accessToken, String refreshToken}) async {
  http.Response logoutResponse = await http.delete(
    Uri.encodeFull('$urlHost/ucm/oauth/logout'),
    headers: {
      "Accept": "application/json, text/plain, */*",
      "Authorization": 'bearer $accessToken',
      "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
    }
  );
  return logoutResponse;
};

final Function userSwitchLanguageActionCreator = ({ Language newLanguage, Function callback}) {
  return (Store<AppState> store) async {
    String accessToken = store.state.loginUser.accessToken;
    String refreshToken = store.state.loginUser.refreshToken;

    http.Response lgRes = await _userSwitchLanguage(
      accessToken: accessToken,
      refreshToken: refreshToken,
      newLanguage: newLanguage
    );

    Map<String, dynamic> lgResData = jsonDecode(lgRes.body);
    if (lgResData['success'] != true) {
      store.dispatch(UserLoginFailAction(lgResData['message']));
      return callback(false);
    }

    Locale locale;

    if (newLanguage == Language.en) {
      locale = Locale('en');
    }
    if (newLanguage == Language.zh) {
      locale = Locale('zh');
    }

    store.dispatch(ChangeLocaleAction(locale));
    store.dispatch(UserSwitchLanguage(newLanguage));
    return callback(true);
  };
};

final Function _userSwitchLanguage = ({String accessToken, String refreshToken, Language newLanguage}) async {
  String _lg = "en";

  if (newLanguage == Language.zh) {
    _lg = "zh_CN";
  }

  http.Response logoutResponse = await http.post(
      Uri.encodeFull('$urlHost/ucm/user/localeUpdate'),
      body: jsonEncode({
        "locale": _lg,
      }),
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        "content-type": 'application/json',
      }
  );
  return logoutResponse;
};