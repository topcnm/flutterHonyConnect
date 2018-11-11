import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../constant/colors.dart';
import '../../constant/sizes.dart';
import '../../constant/http.dart';
import '../../helper/pixelCompact.dart';
import '../../ui/carousel.dart';
import '../../ui/toast.dart';

import '../../model/appState.dart';
import '../../model/user.dart';
import '../../model/productItem.dart';

import '../../helper/HttpUtils.dart';

class InvestIndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new StoreConnector(
      builder: (BuildContext context, LoginUser user) {
        return new InvestIndexPageWidget(user);
      },
      converter: (Store<AppState> store) => store.state.loginUser,
    );
  }
}

class InvestIndexPageWidget extends StatefulWidget {
  final LoginUser user;

  InvestIndexPageWidget(this.user);
  @override
  _InvestIndexPageWidgetState createState() => _InvestIndexPageWidgetState();
}

class _InvestIndexPageWidgetState extends State<InvestIndexPageWidget> {
  ScrollController controller;

  List images = [];
  List products = [];
  int totalPageMount = 1;
  int pageNo = 1;
  int pageSize = 10;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new ScrollController();
    controller.addListener(scrollListener);

    handleRefreshAll();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.removeListener(scrollListener);
    controller.dispose();
    super.dispose();
  }

  void scrollListener() {
    /// 接近滚动尽头、页码还小于总页数、不处于加载中
    if (controller.position.extentAfter < 50 && (pageNo < totalPageMount) && !isLoading) {
      getProductsAsPageNo(pageNo + 1);
    }
  }

  void getCarouselImages() {
    HonyHttp.get(
        "/cm/product/getFocus",
        params: { "contentPlatform": "CNTNTPLT_NEWS"},
        user: widget.user,
    ).then((res) {
      Map<String, dynamic> imgData = jsonDecode(res);
      if (imgData['success'] == null || imgData['success'] == false) {
        showErrorToast("请求错误");
        return null;
      }
      setState(() {
        images = imgData['result'];
      });
    }).catchError((Object error) {
      print('/cm/product/findFocus');
    });
  }

  void getProductsAsPageNo(int _pageNo) async {

    HonyHttp.get(
        '/cm/product/findByCurrentUser',
        params: { "pageNo": _pageNo, "pageSize": pageSize },
        user: widget.user,
    ).then((res) {
      Map responseObj = jsonDecode(res);
      if (responseObj['success'] == false) {
        throw({ "msg": "获取翻页数据失败" });
      }
      this.setState(() {
        isLoading = false;
        products = products + responseObj['result']['content'];
        totalPageMount = responseObj['result']['totalPages'];
        pageNo = _pageNo;
      });
    }).catchError((Object error)  {
      print('/cm/product/findByCurrentUser');
      print(error);
//      showErrorToast(error.msg);
    }).whenComplete(() {
      this.setState(() {
        isLoading = false;
      });
    });
  }

  /// 组件要求必须是future
  Future<Null> handleRefreshAll() async {
    setState(() {
      pageNo = 1;
      images = [];
      products = [];
      totalPageMount = 1;
      isLoading = false;
    });

    getCarouselImages();
    getProductsAsPageNo(1);

    return null;
  }

  Widget rowRender(i) {
    // 渲染成carousel
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
          },
          images: _images,
        )
      );
    }
    // 渲染成自定义tab
    if (i == 1) {
      return new InvestTabComponent();
    }

    ProductItem _product = ProductItem.fromJson(products[i - 2]);

    return new ProductComponent(_product);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Investment"),
        centerTitle: true,
      ),
      body: products.length == 0 && isLoading ? new Center(
          child: new CircularProgressIndicator(),
        )
        :
        new RefreshIndicator(
          child: new ListView.builder(
            controller: controller,
            itemCount: products.length + 2,
            itemBuilder: (BuildContext context, int index) {
              return rowRender(index);
            }
          ),
          onRefresh: handleRefreshAll
        ),
    );
  }
}


class InvestTabComponent extends StatelessWidget implements PixelCompactMixin{

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: greyBgColor,
      height: ScreenUtil().setWidth(150),
      child: new Row(
        children: <Widget>[
          new InvestTabBar(
            "PE Fund",
            IconData(0xe623, fontFamily: 'aliFont'),
            () {}
          ),
          new InvestTabBar(
            "Real Estate",
            IconData(0xe64c, fontFamily: 'aliFont'),
            () {}
          ),
          new InvestTabBar(
            "Hedge Fund",
            IconData(0xe614, fontFamily: 'aliFont'),
            () {}
          ),
          new InvestTabBar(
            "Joint Investment",
            IconData(0xe67e, fontFamily: 'aliFont'),
            () {}
          ),
        ],
      ),
    );
  }
}

class InvestTabBar extends StatelessWidget {
  final Function onTap;
  final String text;
  final IconData icon;

  InvestTabBar(this.text, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return new Expanded(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CircleAvatar(
              radius: ScreenUtil().setWidth(45),
              backgroundColor: primaryColor,
              child: new IconButton(
                  icon: new Icon(icon, color: Colors.white,),
                  onPressed: onTap
              ),
            ),
            new Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
              child: new Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: ScreenUtil().setWidth(20)
                ),
              ),
            ),
          ],
        )
    );
  }
}



class ProductComponent extends StatelessWidget {
  final ProductItem product;

  ProductComponent(this.product);

  @override
  Widget build(BuildContext context) {
    TextStyle _assFontStyle = new TextStyle(
      fontSize: ScreenUtil().setWidth(16),
      color: assistFontColor
    );

    IconData _iconData = IconData(0xe623, fontFamily: 'aliFont');

    if (product.productType == ProductType.PRODTP_HF) {
      _iconData = IconData(0xe614, fontFamily: 'aliFont');
    } else if (product.productType == ProductType.PRODTP_RE) {
      _iconData = IconData(0xe64c, fontFamily: 'aliFont');
    } else if (product.productType == ProductType.PRODTP_PI) {
      _iconData = IconData(0xe67e, fontFamily: 'aliFont');
    }

    return new Container(
      decoration: new BoxDecoration(
        border: new Border(bottom: new BorderSide(color: splitColor))
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(20)
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: ScreenUtil().setWidth(80),
            width: ScreenUtil().setWidth(80),
            color: Color(0xFFed9e00),
            child: new Icon(_iconData, color: emptyColor, size: ScreenUtil().setWidth(40),),
          ),
          new Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(40))),
          new Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  child: new Text(product.topic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                      fontSize: ScreenUtil().setWidth(22),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 0.85,
                    ),
                  ),
                  width: double.infinity,
                  height: ScreenUtil().setWidth(56),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(product.keyWord, style: _assFontStyle,),
                    new Text(product.rlsTime.split("T")[0], style: _assFontStyle,),
                  ],
                )
              ],
            )
          )
        ],
      ),
    );
  }
}
