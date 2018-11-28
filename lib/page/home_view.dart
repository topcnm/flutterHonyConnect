import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../model/appState.dart';
import '../model/user.dart';

import '../constant/colors.dart';
import '../constant/http.dart';

import './subPage/newsIndex_view.dart';
import './subPage/investIndex_view.dart';
import '../helper/localeUtils.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreBuilder<AppState>(
      builder: (context, store) => new HomePageWidget(store.state.loginUser),
    );
  }
}


class HomePageWidget extends StatefulWidget {
  final LoginUser user;

  HomePageWidget(this.user);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  int _activeIndex = 0;
  // VoidCallback onTabChanged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  String getTitle(int i) {
    switch(i) {
      case 0: return LocaleUtils.getLocale(context).newsIndexTitle;
      case 1: return LocaleUtils.getLocale(context).investIndexTitle;
    }
  }

  void handleTabChange(int i) {
    setState(() {
      _activeIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = getTitle(_activeIndex);

    return new GestureDetector(
      child: new Scaffold(
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(ScreenUtil().setHeight(88)),
          child: new AppBar(
            title: new Text(pageTitle, style: new TextStyle(fontSize: ScreenUtil().setSp(30))),
            centerTitle: true,
          ),
        ) ,
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new AssetImage('lib/images/bg.jpg'),
                    fit: BoxFit.cover,
                  )
                ),
                accountName: new Text(widget.user.username),
                accountEmail: new Text(widget.user.mail),
                currentAccountPicture: new CircleAvatar(
                  backgroundImage: widget.user.photoUrl != null ?
                          new NetworkImage('$urlHost/nd/image/${widget.user.photoUrl}')
                          :
                          new AssetImage('lib/images/fakehony.jpg')
                ),
              ),
              new ListTile(
                leading: new Icon(Icons.settings),
                title: new Text('My Setting'),
                trailing: new Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed('/setting'),
              ),
              new Divider(),
              new ListTile(
                leading: new Icon(Icons.person),
                title: new Text('My Personal'),
                trailing: new Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed("/personal"),
              )
            ],
          ),
        ),
        body: new IndexedStack(
          index: _activeIndex,
          children: [
            new NewsIndexPage(),
            new InvestIndexPage(),
          ]
        ),
        bottomNavigationBar: new Container(
          child: new Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new CustomTabItem(
                _activeIndex == 0, 
                IconData(0xe86e, fontFamily: 'aliFont'), 
                LocaleUtils.getLocale(context).newsIndexTitle,
                () { handleTabChange(0);}
              ),
              new CustomTabItem(
                _activeIndex == 1, 
                IconData(0xe67d, fontFamily: 'aliFont'), 
                LocaleUtils.getLocale(context).investIndexTitle,
                () { handleTabChange(1);}
              )
            ],
          ),
        )
      ),
    );
  }
}

class CustomTabItem extends StatelessWidget {
  final IconData _iconData;
  final String _textData;
  final bool _active;
  final Function _onTap;

  CustomTabItem(
      this._active,
      this._iconData,
      this._textData,
      this._onTap,
      {
        Key key
      }
      ): super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      flex: 1,
      child: new Container(
        width: double.infinity,
        height: ScreenUtil().setWidth(100),
        color: _active ? primaryColor : bottomNavColor,
        child: new InkWell(
          onTap: this._onTap,
          child:new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                _iconData,
                size: ScreenUtil().setWidth(40),
                color: Colors.white,
              ),
              new Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(2)
                  )
              ),
              new Text(
                _textData,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: new TextStyle(
                  fontSize: ScreenUtil().setWidth(22),
                  height: 0.9,
                  color: Colors.white
                ),
              )
            ],
          )
        ),
      )
    );
  }
}
