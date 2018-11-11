import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './locale/honyLocalizationDelegate.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 防止显示切换方向
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import './model/appState.dart';
import './reducer/appReducer.dart';

import './constant/colors.dart';

import './page/welcome_view.dart';
import './page/home_view.dart';
import './page/login/login_view.dart';
import './page/setting/setting_view.dart';
import './page/personal/personal_view.dart';

void main() {
  // prevent screen rotation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new MyReduxApp());
  });
}

class MyReduxApp extends StatelessWidget {
  /// 之后的所有组件中，都被注入类store, 可以通过StoreConnector 取到store的状态
  final store = Store<AppState>(
      appReducer,
    initialState: AppState.empty,
    middleware: [thunkMiddleware]
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
        /// 【第四部】引入 flutter_localizations
        /// 1，引入国际化delegate代理
        /// 2，将原本的MaterialApp 用StoreBuilder包裹一层，否则无法实现实时切换，只能刷新切换；
        /// 3，为MaterialApp设置locale、supportedLocales等属性
      child: new StoreBuilder<AppState>(
        builder: (context, store) {
          return new MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              HonyLocalizationDelegate.delegate
            ],
            locale: store.state.locale,
            supportedLocales: [store.state.locale],

            title: 'Flutter Demo',
            theme: new ThemeData(
              primaryColor: primaryColor,
            ),
            home: new Welcome(),
            routes: <String, WidgetBuilder> {
    //          '/': (BuildContext context) => new Welcome(),
              '/main': (BuildContext context) => new HomePage(),
              '/login': (BuildContext context) => new LoginPage(),
              '/setting': (BuildContext context) => new SettingPage(),
              '/personal': (BuildContext context) => new PersonalPage(),
            },
          );
        }
      )
    );
  }
}
