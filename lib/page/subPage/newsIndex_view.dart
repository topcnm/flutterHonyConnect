import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../constant/colors.dart';
import '../../constant/http.dart';
import '../../ui/carousel.dart';

import '../../model/appState.dart';
import '../../model/user.dart';
import '../../model/newsItem.dart';
import '../newsDetail_view.dart';
import '../webLink_view.dart';

import '../../helper/HttpUtils.dart';

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

class _NewsIndexPageStateWidget extends State<NewsIndexPageWidget> {
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

    handleRefreshAll();
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
      isLoading = true;
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
    Map<String, String> queryParams = {
      "contentPlatform": "CNTNTPLT_NEWS"
    };

    String carouselApi = "/cm/news/findFocus";

    HonyHttp.get(carouselApi, params: queryParams, user: widget.user).then((res) {
      Map<String, dynamic> responseObj = jsonDecode(res);
      if (responseObj['success'] == false) {
        throw({ "msg": "获取焦点图失败" });
      }
      setState(() {
        images = responseObj['result'];
      });
    }).catchError((Object error) {
      print('/cm/news/findFocus');
    });
  }

  void renderPageAsPageNo(int _pageNo) {
    Map<String, int> queryParams = {
      "pageNo": _pageNo,
      "pageSize": pageSize
    };

    String newsListApi = '/cm/news/findByCurrentUser';

    HonyHttp.get(newsListApi, params: queryParams, user: widget.user).then((res) {
      Map responseObj = jsonDecode(res);
      if (responseObj['success'] == false) {
        throw({ "msg": "获取翻页数据失败" });
      }
      this.setState(() {
        isLoading = false;
        news = news + responseObj['result']['content'];
        totalPageMount = responseObj['result']['totalPages'];
        pageNo = _pageNo;
      });
    }).catchError((Object error)  {
      print('/cm/news/findByCurrentUser');
      print(error);

    }).whenComplete(() {
      this.setState(() {
        isLoading = false;
      });
    });
  }

  Widget rowBuilder(i) {
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
        height: ScreenUtil().setWidth(300),
        child: new HonyCarousel(
          dotSize: ScreenUtil().setWidth(8),
          dotSpacing: ScreenUtil().setWidth(25),
          boxFit: BoxFit.fill,
          animationDuration: new Duration(milliseconds: 600),
          animationCurve: Curves.easeOut,
          onTapImage: (PictureItem item) {
            print(item.id);
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (BuildContext context) => new NewsDetail(cntntId: item.id)
              )
            );
          },
          images: _images,
        )
      );
    }

    var item = news[i - 1];
    NewsItem _item = new NewsItem(
        cntntFlg: item['cntntFlg'],
        webLink: item['webLink'] != null ? item['webLink']: "https://www.baidu.com",
        cntntId: item['cntntId'],
        topic: item['topic'],
        focusImgUrl: item['focusImgUrl'],
        rlsTime: item['rlsTime'] != null ? item['rlsTime'].split("T")[0] : ""
    );
    return new NewsComponent(
      newsInfo: _item,
      onTap: () {
        if (_item.cntntFlg) {
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (BuildContext context) => new WebLinkPage(_item.webLink)
              )
          );
          return null;
        }

        Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) => new NewsDetail(cntntId: _item.cntntId)
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
      body: news.length == 0 && isLoading ? new Center(
          child: new CircularProgressIndicator(),
        )
        :
        new RefreshIndicator(
          child:new ListView.builder(
            controller: controller,
            itemCount: news.length + 1,
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

class _NewsComponentState extends State<NewsComponent> {


  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: widget.onTap,
      child: new Container(
        height: ScreenUtil().setWidth(202),
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(20),
          horizontal: ScreenUtil().setWidth(30)
        ),
        decoration: new BoxDecoration(
          color: emptyColor
        ),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                  height: ScreenUtil().setWidth(150),
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
                          fontSize: ScreenUtil().setWidth(30),
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
              height: ScreenUtil().setWidth(150),
              width: ScreenUtil().setWidth(236),
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
