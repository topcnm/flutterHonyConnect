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

class _HomePageWidgetState extends State<HomePageWidget> with SingleTickerProviderStateMixin {
  TabController _tc;
  int _activeIndex = 0;
  VoidCallback onTabChanged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tc = new TabController(
        initialIndex: _activeIndex,
        length: 2,
        vsync: this
    );
    onTabChanged = (){
      setState(() {
        _activeIndex = _tc.index;
      });
    };
    _tc.addListener(onTabChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tc.removeListener(onTabChanged);
    _tc.dispose();
    super.dispose();
  }

  String getTitle(int i) {
    switch(i) {
      case 0: return LocaleUtils.getLocale(context).newsIndexTitle;
      case 1: return LocaleUtils.getLocale(context).investIndexTitle;
    }
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
            // new MinePage(),
          ]
        ),
        bottomNavigationBar: new Material(
          color: bottomNavColor,
            child: new TabBar(
              controller: _tc,
              indicator: new UnderlineTabIndicator(
                borderSide: new BorderSide(width: 0.0),
              ),
              tabs: <Widget>[
                new CustomTabItem(_activeIndex == 0, IconData(0xe86e, fontFamily: 'aliFont'), LocaleUtils.getLocale(context).newsIndexTitle),
                new CustomTabItem(_activeIndex == 1, IconData(0xe67d, fontFamily: 'aliFont'), LocaleUtils.getLocale(context).investIndexTitle),
//                new CustomTabItem(_activeIndex == 2, IconData(0xe62c, fontFamily: 'aliFont'), "Asset"),
                // new CustomTabItem(_activeIndex == 2, IconData(0xe6b6, fontFamily: 'aliFont'), LocaleUtils.getLocale(context).mineTitle),
              ]
            )
        ),
      ),
    );
  }
}

class CustomTabItem extends StatelessWidget {
  final IconData _iconData;
  final String _textData;
  final bool _active;

  CustomTabItem(
      this._active,
      this._iconData,
      this._textData,
      {
        Key key
      }
      ): super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      height: ScreenUtil().setWidth(100),
      color: _active ? primaryColor : bottomNavColor,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(
            _iconData,
            size: ScreenUtil().setWidth(40),
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
              height: 0.9
            ),
          )
        ],
      ),
    );
  }
}


class APage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('A page'),
      ),
      body: new Text('A page'),
    );
  }
}

class BPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('B page'),
      ),
      body: new Text('B page'),
    );
  }
}

class CPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('C page'),
      ),
      body: new Text('C page'),
    );
  }
}

class DPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('D page'),
      ),
      body: new Text('D page'),
    );
  }
}
