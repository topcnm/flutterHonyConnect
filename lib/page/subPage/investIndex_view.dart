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
import '../../ui/toast.dart';

import '../../model/appState.dart';
import '../../model/user.dart';
import '../../model/productItem.dart';

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

class _InvestIndexPageWidgetState extends State<InvestIndexPageWidget> implements PixelCompactMixin{
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

    getCarouselImages();

    getProductsAsPageNo(1);
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

  void getCarouselImages() async {
    http.Response imgResponse = await fetchCarouselImages();
    Map<String, dynamic> imgData = jsonDecode(imgResponse.body);
    if (imgData['success'] == null || imgData['success'] == false) {
      showConnectToast("请求错误");
      return null;
    }

    setState(() {
      images = imgData['result'];
    });
  }

  void getProductsAsPageNo(int _pageNo) async {
    setState(() {
      isLoading = true;
    });

    http.Response nextPageResponse = await fetchNextPage(_pageNo);
    Map<String, dynamic> npData = jsonDecode(nextPageResponse.body);

    setState(() {
      isLoading = false;
    });

    if (npData['success'] == null || npData['success'] == false) {
      showConnectToast("拉取列表请求错误");
      return null;
    }

    setState(() {
      totalPageMount = npData['result']['totalPages'];
      pageNo = _pageNo;
      products = products + npData['result']['content'];
      isLoading = false;
    });
  }

  Future<http.Response> fetchCarouselImages() async {
    String accessToken = widget.user.accessToken;
    String refreshToken = widget.user.refreshToken;

    http.Response imageRes = await http.get(
      Uri.encodeFull('$urlHost/cm/product/getFocus'),
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      }
    );

    return imageRes;
  }

  Future<http.Response> fetchNextPage(int _pageNo) async {
    String accessToken = widget.user.accessToken;
    String refreshToken = widget.user.refreshToken;

    http.Response productRes = await http.get(
        Uri.encodeFull('$urlHost/cm/product/findByCurrentUser?pageNo=$_pageNo&pageSize=$pageSize'),
        headers: {
          "Accept": "application/json, text/plain, */*",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        }
    );

    return productRes;
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
    double winWidth = MediaQuery.of(context).size.width;
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
    // 渲染成自定义tab
    if (i == 1) {
      return new InvestTabComponent();
    }

    var item = products[i - 2];

    var _productType;

    if (item['productType'] == "PRODTP_RE") {
      _productType = ProductType.PRODTP_RE;
    } else if (item['productType'] == "PRODTP_PE") {
      _productType = ProductType.PRODTP_PE;
    } else if (item['productType'] == "PRODTP_HF") {
      _productType = ProductType.PRODTP_HF;
    } else {
      _productType = ProductType.PRODTP_PI;
    }

    ProductItem _product = new ProductItem(
      cntntId: item['cntntId'],
      productId: item['productId'],
      topic: item['topic'],
      productType: _productType,
      rlsTime: item['rlsTime'] == null ? "" : item['rlsTime'],
      keyWord: item['keyWord'],
    );

    return new ProductComponent(_product);
  }

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Investment"),
        centerTitle: true,
      ),
      body: products.length == 0 ? new Center(
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
    double winWidth = MediaQuery.of(context).size.width;
    return new Container(
      color: greyBgColor,
      height: getWidth(150.0, winWidth),
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

class InvestTabBar extends StatelessWidget implements PixelCompactMixin{
  final Function onTap;
  final String text;
  final IconData icon;

  InvestTabBar(this.text, this.icon, this.onTap);

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new Expanded(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CircleAvatar(
              radius: getWidth(45.0, winWidth),
              backgroundColor: primaryColor,
              child: new IconButton(
                  icon: new Icon(icon, color: Colors.white,),
                  onPressed: onTap
              ),
            ),
            new Padding(
              padding: EdgeInsets.only(top: getWidth(10.0, winWidth)),
              child: new Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(
                  fontSize: getWidth(20.0, winWidth)
                ),
              ),
            ),
          ],
        )
    );
  }
}



class ProductComponent extends StatelessWidget implements PixelCompactMixin{
  final ProductItem product;

  ProductComponent(this.product);

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    TextStyle _assFontStyle = new TextStyle(
      fontSize: getWidth(16.0, winWidth),
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
        horizontal: getWidth(30.0, winWidth),
        vertical: getWidth(20.0, winWidth)
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: getWidth(80.0, winWidth),
            width: getWidth(80.0, winWidth),
            color: Color(0xFFed9e00),
            child: new Icon(_iconData, color: emptyColor, size: getWidth(40.0, winWidth),),
          ),
          new Padding(padding: EdgeInsets.only(left: getWidth(40.0, winWidth))),
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
                      fontSize: getWidth(22.0, winWidth),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 0.85,
                    ),
                  ),
                  width: double.infinity,
                  height: getWidth(56.0, winWidth),
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
