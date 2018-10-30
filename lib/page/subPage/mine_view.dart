import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../constant/colors.dart';
import '../../constant/sizes.dart';
import '../../constant/http.dart';
import '../../helper/pixelCompact.dart';

import '../../model/appState.dart';
import '../../model/user.dart';

///AutomaticKeepAliveClientMixin not work still bug
/// _debugUltimatePreviousSiblingOf(after, equals: _firstChild) is not true. #11895

class MinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector(
      converter: (Store<AppState> store) => store.state.loginUser,
      builder: (context, LoginUser user) {
        return new MinePageWidget(user);
      },
    );
  }
}

class MinePageWidget extends StatefulWidget {
  final LoginUser user;
  MinePageWidget(this.user);

  @override
  _MinePageWidgetState createState() => _MinePageWidgetState();
}

class _MinePageWidgetState extends State<MinePageWidget> with PixelCompactMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.user);
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
        leading: new IconButton(
          icon: new Icon(Icons.settings),
          color: emptyColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/setting');
          }
        ),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.message, color: emptyColor,),
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
                        backgroundImage: widget.user.photoUrl != null ?
                          new NetworkImage('$urlHost/nd/image/${widget.user.photoUrl}')
                          :
                          new AssetImage('lib/images/fakehony.jpg')
                    ),
                  ),

                  new Padding(padding: EdgeInsets.only(top: getWidth(20.0, winWidth))),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(widget.user.position, style: myStyle,),
                      new Divider(indent: getWidth(20.0, winWidth), color: emptyColor,),
                      new Text(widget.user.mobile, style: myStyle,)
                    ],
                  ),
                  new Padding(padding: EdgeInsets.only(top: getWidth(20.0, winWidth))),
                  new Text(widget.user.name, style: new TextStyle(
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
                  new MineMenuItem(Icons.people, 'My Personal Information', (){
                    Navigator.of(context).pushNamed("/personal");
                  }),
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
