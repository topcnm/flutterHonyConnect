import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../constant/colors.dart';
import '../../constant/http.dart';

import '../../model/appState.dart';
import '../../model/user.dart';
import '../../helper/localeUtils.dart';

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

class _MinePageWidgetState extends State<MinePageWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle myStyle = new TextStyle(
      color: emptyColor,
      fontSize: ScreenUtil().setWidth(24),
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(LocaleUtils.getLocale(context).mineTitle),
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
              height: ScreenUtil().setWidth(345),
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
                  new Padding(padding: EdgeInsets.only(top: ScreenUtil().setWidth(50))),
                  new Container(
                    height: ScreenUtil().setWidth(120),
                    width: ScreenUtil().setWidth(120),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
                    decoration: new BoxDecoration(
                      color: emptyColor,
                      shape: BoxShape.circle,
                    ),
                    child: new CircleAvatar(
                        radius: ScreenUtil().setWidth(58),
                        backgroundColor: primaryColor,
                        backgroundImage: widget.user.photoUrl != null ?
                          new NetworkImage('$urlHost/nd/image/${widget.user.photoUrl}')
                          :
                          new AssetImage('lib/images/fakehony.jpg')
                    ),
                  ),

                  new Padding(padding: EdgeInsets.only(top: ScreenUtil().setWidth(20))),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(widget.user.position, style: myStyle,),
                      new Divider(indent: ScreenUtil().setWidth(20), color: emptyColor,),
                      new Text(widget.user.mobile, style: myStyle,)
                    ],
                  ),
                  new Padding(padding: EdgeInsets.only(top: ScreenUtil().setWidth(20))),
                  new Text(widget.user.name, style: new TextStyle(
                    fontSize: ScreenUtil().setWidth(30),
                    fontWeight: FontWeight.bold,
                    color: emptyColor
                  ),)
                ],
              ),
            ),
            new Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
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

class MineMenuItem extends StatelessWidget {
  final IconData _icon;
  final String _text;
  final VoidCallback _onTap;

  MineMenuItem(this._icon, this._text, this._onTap);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Icon(_icon, color: primaryColor,),
      contentPadding: EdgeInsets.only(left: 10.0),
      title: new Text(
        _text,
        style: new TextStyle(
          fontSize: ScreenUtil().setWidth(27)
        ),
      ),
      trailing: new Icon(Icons.chevron_right, color: primaryColor,),
      onTap: _onTap,
    );
  }
}
