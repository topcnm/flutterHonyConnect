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

//import './storeinstance.dart';

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
      child: new MaterialApp(
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
      )
    );
  }
}
