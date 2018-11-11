import 'package:flutter/material.dart';
import 'package:redux/redux.dart';


/// 【第七步】设置关于语言库的redux三板斧
/// 1，设置切换方式
/// 2，设置reducer 和执行方法
final LocaleReducer = combineReducers<Locale>([
  TypedReducer<Locale, ChangeLocaleAction>(_change)
]);

Locale _change(Locale locale, ChangeLocaleAction action) {
  locale = action.locale;
  print('发起后，执行${locale.languageCode}');
  return locale;
}

class ChangeLocaleAction {
  Locale locale;

  ChangeLocaleAction(Locale locale){
    print('ChangeLocaleAction 发起 ${locale.languageCode}');
    this.locale = locale;
  }
}

