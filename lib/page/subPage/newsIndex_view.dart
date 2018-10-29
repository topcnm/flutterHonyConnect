import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../constant/colors.dart';
import '../../constant/sizes.dart';
import '../../constant/http.dart';
import '../../helper/pixelCompact.dart';
import '../../ui/carousel.dart';

import '../../model/appState.dart';
import '../../model/user.dart';
import '../../model/newsItem.dart';
import '../newsDetail_view.dart';

class NewsIndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector(
      converter: (Store<AppState> store) => store.state.loginUser,
      builder: (context, LoginUser user) {
        return new NewsIndexPageWidget(user);
      },
    );
  }
}


class NewsIndexPageWidget extends StatefulWidget {
  final LoginUser user;
  NewsIndexPageWidget(this.user);

  @override
  _NewsIndexPageStateWidget createState() => _NewsIndexPageStateWidget();
}

class _NewsIndexPageStateWidget extends State<NewsIndexPageWidget> implements PixelCompactMixin{
  ScrollController controller;

  List images = [];
  List news = [];
  int totalPageMount = 1;
  int pageNo = 1;
  int pageSize = 10;
  bool isLoading = false;

  // bug switch none-neighbor tab,  "setState() called after dispose()"
  // in this case, initState fired
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new ScrollController()..addListener(scrollListener);

    // get initial carousel
    renderCarousel();

    // get initial list
    renderPageAsPageNo(1);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.removeListener(scrollListener);
    controller.dispose();
    super.dispose();
  }

  Future<Null> handleRefreshAll() async {
    setState(() {
      pageNo = 1;
      images = [];
      news = [];
      totalPageMount = 1;
    });

    renderCarousel();
    renderPageAsPageNo(1);

    return null;
  }

  void scrollListener() {
    if (controller.position.extentAfter < 50 && (pageNo < totalPageMount) && !isLoading) {
      print('-----------------------i am trggered, pageNo is $pageNo');
      renderPageAsPageNo(pageNo + 1);
    }
  }

  void renderCarousel() {
    getNewCarousel().then((res) {
      Map<String, dynamic> responseObj = jsonDecode(res.body);
      if (responseObj['success'] == false) {
        throw('请求错误');
      }
      // why we have to check the mount status
      // cause views in tab is always rendered
      setState(() {
        images = responseObj['result'];
      });
    });
  }

  Future getNewCarousel() async {
    String accessToken = widget.user.accessToken;
    String refreshToken = widget.user.refreshToken;

    http.Response response = await http.get(
      Uri.encodeFull('$urlHost/cm/news/findFocus?contentPlatform=CNTNTPLT_NEWS'),
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      }
    );

    return response;
  }

  void renderPageAsPageNo(int _pageNo) {
    setState(() {
      isLoading = true;
    });

    getNexPage(_pageNo).then((res) {
      Map resJson = jsonDecode(res.body);
      this.setState(() {
        totalPageMount = resJson['result']['totalPages'];
        pageNo = _pageNo;
        news = news + resJson['result']['content'];
        isLoading = false;
        print(news.length);
      });
    }).whenComplete((){
      setState(() {
        isLoading = false;
      });
    });
  }

  Future getNexPage(int pageNo) async {
    String accessToken = widget.user.accessToken;
    String refreshToken = widget.user.refreshToken;

    http.Response response = await http.get(
      Uri.encodeFull('$urlHost/cm/news/findByCurrentUser?contentPlatform=CNTNTPLT_NEWS&pageNo=$pageNo&pageSize=$pageSize'),
        headers: {
          "Accept": "application/json, text/plain, */*",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        }
    );


    return response;
  }
  
  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  Widget rowBuilder(i) {
    double winWidth = MediaQuery.of(context).size.width;
    if (i == 0) {
      List _images = images.map((item) {
        return new PictureItem(
            url: '$urlHost${item['focusImgUrl']}',
            id: item['cntntId'],
            title: item['topic']
        );
      }).toList();

      return new Container(
        width: double.infinity,
        height: getWidth(300.0, winWidth),
        child: new HonyCarousel(
          dotSize: getWidth(8.0, winWidth),
          dotSpacing: getWidth(25.0, winWidth),
          boxFit: BoxFit.fill,
          animationDuration: new Duration(milliseconds: 600),
          animationCurve: Curves.easeOut,
          onTapImage: (PictureItem item) {
            print(item.id);
          },
          images: _images,
        )
      );
    }

    var item = news[i - 1];
    NewsItem _item = new NewsItem(
        cntntId: item['cntntId'],
        topic: item['topic'],
        focusImgUrl: item['focusImgUrl'],
        rlsTime: item['rlsTime']
    );
    return new NewsComponent(
      newsInfo: _item,
      onTap: () {
        print('----------------${item['cntntId']}');
        Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) => new NewsDetail(cntntId: item['cntntId'])
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('News'),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(IconData(0xe61e, fontFamily: 'aliFont'), color: emptyColor,),
              onPressed: null
          )
        ],
      ),
      body: new RefreshIndicator(
        child:new ListView.builder(
          controller: controller,
          itemCount: news.length,
          itemBuilder: (context, index) {
            return rowBuilder(index);
          }
        ),
        onRefresh: handleRefreshAll
      )
    );
  }
}

class NewsComponent extends StatefulWidget {
  final NewsItem newsInfo;
  final Function onTap;

  NewsComponent({
    @required this.newsInfo,
    this.onTap
  });

  @override
  _NewsComponentState createState() => _NewsComponentState();
}

class _NewsComponentState extends State<NewsComponent> with PixelCompactMixin{

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new InkWell(
      onTap: widget.onTap,
      child: new Container(
        height: getWidth(202.0, winWidth),
        padding: EdgeInsets.symmetric(
            vertical: getWidth(20.0, winWidth),
          horizontal: getWidth(30.0, winWidth)
        ),
        decoration: new BoxDecoration(
          color: emptyColor
        ),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  padding: EdgeInsets.only(right: getWidth(20.0, winWidth)),
                  height: getWidth(150.0, winWidth),
                  child:new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        widget.newsInfo.topic,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: new TextStyle(
                          fontSize: getWidth(30.0, winWidth),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      new Text(
                        widget.newsInfo.rlsTime,
                        style: new TextStyle(
                          color: assistFontColor
                        ),
                      )
                    ],
                  ),
                )
            ),
            new Container(
              height: getWidth(150.0, winWidth),
              width: getWidth(236.0, winWidth),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('lib/images/picholder.png'),
                  fit: BoxFit.cover
                ),
              ),
              child: new Image.network(
                '$urlHost${widget.newsInfo.focusImgUrl}',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
