import 'package:flutter/material.dart';
import './user.dart';

class AppState {
  static var empty = AppState(
    loginUser: new LoginUser(),
    locale: new Locale('zh')
  );

  /// 这是一个总的state, 但是未关联reducer
  /// loginUser作为一个子state
  /// 可以在后面继续增加多个子state, 以管理其他模块
  LoginUser loginUser;

  /// 【第八步】在根state里，设置语言属性，以方便redux调用
  Locale locale;

  ///
  AppState({
    this.loginUser,
    this.locale,
  });
}