import 'package:flutter/material.dart';

import '../constant/colors.dart';
import '../constant/sizes.dart';
import '../helper/pixelCompact.dart';

import './subPage/mine_view.dart';
import './subPage/newsIndex_view.dart';
import './subPage/investIndex_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, PixelCompactMixin {
  TabController _tc;
  int _activeIndex = 0;
  VoidCallback onTabChanged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tc = new TabController(
        initialIndex: _activeIndex,
        length: 3,
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
  
  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Scaffold(
        body: new IndexedStack(
          index: _activeIndex,
          children: [
            new NewsIndexPage(),
            new InvestIndexPage(),
            new MinePage(),
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
                new CustomTabItem(_activeIndex == 0, IconData(0xe86e, fontFamily: 'aliFont'), "News"),
                new CustomTabItem(_activeIndex == 1, IconData(0xe67d, fontFamily: 'aliFont'), "Invest"),
//                new CustomTabItem(_activeIndex == 2, IconData(0xe62c, fontFamily: 'aliFont'), "Asset"),
                new CustomTabItem(_activeIndex == 2, IconData(0xe6b6, fontFamily: 'aliFont'), "Mine"),
              ]
            )
        ),
      ),
    );
  }
}

class CustomTabItem extends StatelessWidget implements PixelCompactMixin{
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
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new Container(
      width: double.infinity,
      height: getWidth(100.0, winWidth),
      color: _active ? primaryColor : bottomNavColor,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(
            _iconData,
            size: getWidth(40.0, winWidth),
          ),
          new Padding(padding: EdgeInsets.only(top: getWidth(10.0, winWidth))),
          new Text(
            _textData,
            overflow: TextOverflow.ellipsis, maxLines: 1,
            style: new TextStyle(
              fontSize: getWidth(26.0, winWidth),
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
