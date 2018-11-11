import 'package:flutter/material.dart';
import 'package:redux/redux.dart';


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

