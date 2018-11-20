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

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin{
  AnimationController controller;
  Animation<double> animation;
  var animationStateListener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new AnimationController(vsync: this, duration: new Duration(seconds: 2));
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeIn);
    animationStateListener = (status){
      if (status == AnimationStatus.completed) {
        try{
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()),
          (Route route) => route == null);
        } catch(e) {
          print('Leading page error');
        }
      }
    };

    animation.addStatusListener(animationStateListener);
    controller.forward();

    return null;
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
    void dispose() {
      // TODO: implement dispose
      animation.removeStatusListener(animationStateListener);
      controller.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);

    return new Material(
      child: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // new ClipRect(
          //   child: new Align(
          //     alignment: Alignment.center,
          //     child: new Image.asset('lib/images/welcome.jpg'),
          //   )
          // ),
          new FadeTransition(
            opacity: animation,
            child: new Image(
              image: new AssetImage('lib/images/welcome.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          
       
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
