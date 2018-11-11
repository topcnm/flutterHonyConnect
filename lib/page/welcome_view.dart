import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 手机基本尺寸设置

import '../constant/colors.dart';
import '../constant/sizes.dart';
import '../helper/pixelCompact.dart';
import './login/login_view.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => new _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    return null;
    new Timer(new Duration(milliseconds: 2000), () {
      try{
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()),
        (Route route) => route == null);
      } catch(e) {
        print('Leading page error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);

    return new Material(
      color: pressColor,
      child: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Padding(padding: EdgeInsets.only(top: ScreenUtil().setWidth(450))),
              new Text("Hony Connect", style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setWidth(50)
              ),)
            ],
          ),
        ],
      ),
    );
  }
}
