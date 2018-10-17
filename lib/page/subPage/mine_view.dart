import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/colors.dart';
import '../../constant/sizes.dart';
import '../../constant/http.dart';
import '../../helper/pixelCompact.dart';
import '../../ui/combineIconInput.dart';
import '../../ui/extendButton.dart';
import '../../ui/pendingOverlay.dart';
import '../../ui/toast.dart';

///AutomaticKeepAliveClientMixin not work still bug
/// _debugUltimatePreviousSiblingOf(after, equals: _firstChild) is not true. #11895
class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with PixelCompactMixin{
  dynamic _avatar;
  String _name = '';
  String _role = '';
  String _org = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserInfo().then((res) {
      Map userInfo = jsonDecode(jsonDecode(res));
      setState(() {
        _avatar = userInfo['photoUrl'];
        _name = userInfo['name'];
        _role = userInfo['position'];
        _org = 'Hony Investment';
      });
    });
  }

  Future<String> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userInfo = prefs.getString('userInfo');
    return userInfo;
  }

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }
  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    TextStyle myStyle = new TextStyle(
      color: emptyColor,
      fontSize: getWidth(24.0, winWidth),
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Mine Page'),
        centerTitle: true,
        leading: new Icon(Icons.settings),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.message),
              color: emptyColor,
              onPressed: null
          )
        ],
      ),
      body: new GestureDetector(
        child: new ListView(
          children: <Widget>[
            new Container(
              height: getWidth(345.0, winWidth),
              decoration: new BoxDecoration(
                color: primaryColor,
                image: new DecorationImage(
                  image: new AssetImage('lib/images/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(top: getWidth(50.0, winWidth))),
                  new Container(
                    height: getWidth(120.0, winWidth),
                    width: getWidth(120.0, winWidth),
                    padding: const EdgeInsets.all(2.0),
                    decoration: new BoxDecoration(
                      color: emptyColor,
                      shape: BoxShape.circle,
                    ),
                    child: new CircleAvatar(
                        radius: getWidth(58.0, winWidth),
                        backgroundColor: primaryColor,
                        backgroundImage: _avatar != null ?
                          new NetworkImage('$urlHost/nd/image/$_avatar')
                          :
                          new AssetImage('lib/images/fakehony.jpg')
                    ),
                  ),

                  new Padding(padding: EdgeInsets.only(top: getWidth(20.0, winWidth))),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(_role, style: myStyle,),
                      new Divider(indent: getWidth(20.0, winWidth), color: emptyColor,),
                      new Text(_org, style: myStyle,)
                    ],
                  ),
                  new Padding(padding: EdgeInsets.only(top: getWidth(20.0, winWidth))),
                  new Text(_name, style: new TextStyle(
                    fontSize: getWidth(30.0, winWidth),
                    fontWeight: FontWeight.bold,
                    color: emptyColor
                  ),)
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.symmetric(horizontal: getWidth(20.0, winWidth)),
              child: new Column(
                children: <Widget>[
                  new MineMenuItem(Icons.font_download, 'Risk Assessment', (){}),
                  new Divider(color: splitColor,),
                  new MineMenuItem(Icons.thumb_up, 'My Recommendation', (){}),
                  new Divider(color: splitColor,),
                  new MineMenuItem(Icons.favorite, 'My Favorites', (){}),
                  new Divider(color: splitColor,),
                  new MineMenuItem(Icons.people, 'My Personal Information', (){}),
                  new Divider(color: splitColor,),
                  new MineMenuItem(Icons.cloud_download, 'My Download', (){}),
                  new Divider(color: splitColor,),
                  new MineMenuItem(Icons.card_giftcard, 'VIP Exclusive', (){}),
                  new Divider(color: splitColor,),
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}

class MineMenuItem extends StatelessWidget implements PixelCompactMixin{
  final IconData _icon;
  final String _text;
  final VoidCallback _onTap;

  MineMenuItem(this._icon, this._text, this._onTap);

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new ListTile(
      leading: new Icon(_icon, color: primaryColor,),
      contentPadding: EdgeInsets.only(left: 10.0),
      title: new Text(
        _text,
        style: new TextStyle(
          fontSize: getWidth(27.0, winWidth)
        ),
      ),
      trailing: new Icon(Icons.chevron_right, color: primaryColor,),
      onTap: _onTap,
    );
  }
}
