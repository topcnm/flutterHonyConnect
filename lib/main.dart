import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './constant/colors.dart';

import './page/welcome_view.dart';
import './page/home_view.dart';

void main() {
  // prevent screen rotation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primaryColor: primaryColor,
      ),
      home: new Welcome(),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => new HomePage()
      },
    );
  }
}
