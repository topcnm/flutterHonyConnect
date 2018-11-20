import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 手机基本尺寸设置

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../model/appState.dart';
import '../model/user.dart';

import './login/login_view.dart';
import './login/login_action.dart';
import './home_view.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector(
      converter: (Store<AppState> store) {
        return (String accessToken, String refreshToken, Function callback) => store.dispatch(
            userLoginActionCreator(
              accessToken: accessToken,
              refreshToken: refreshToken,
              callback: callback
            )
          );
        },
      builder: (BuildContext context, Function triggerLogin) => new WelcomeWidget(triggerLogin),
    );
  }
}


class WelcomeWidget extends StatefulWidget {
  final Function triggerLogin;

  WelcomeWidget(this.triggerLogin);
  @override
  _WelcomeWidgetState createState() => new _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> with TickerProviderStateMixin{
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
        getTokenInfo().then((tokenInfo) {
          if (tokenInfo['accessToken'] == null) {
            Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()),
              (Route route) => route == null);
          } else {
            widget.triggerLogin(
              tokenInfo['accessToken'],
              tokenInfo['refreshToken'],
              (bool isSuccess) => Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(builder: (BuildContext context) => new HomePage()),
                (Route route) => route == null)
            );
          }
        });
      }
    };

    animation.addStatusListener(animationStateListener);
    controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animation.removeStatusListener(animationStateListener);
    controller.dispose();
    super.dispose();
  }

  // Future
  Future<Map<String, dynamic>> getTokenInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic accessToken = prefs.get('accessToken');
    dynamic refreshToken = prefs.get('refreshToken');

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
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
