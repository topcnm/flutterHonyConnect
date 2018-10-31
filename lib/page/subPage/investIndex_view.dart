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

    }
  }

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ProductComponent extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
