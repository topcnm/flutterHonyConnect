import 'dart:async';

import 'package:flutter/material.dart';

import '../constant/colors.dart';
import '../constant/sizes.dart';
import '../helper/pixelCompact.dart';
import './login_view.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => new _WelcomeState();
}

class _WelcomeState extends State<Welcome> with PixelCompactMixin{
  Timer _t;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _t = new Timer(new Duration(milliseconds: 2000), () {
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
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;

    return new Material(
      color: pressColor,
      child: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Padding(padding: EdgeInsets.only(top: getWidth(450.0, winWidth))),
              new Text("Hony Connect", style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 50.0
              ),)
            ],
          ),
        ],
      ),
    );
  }
}
