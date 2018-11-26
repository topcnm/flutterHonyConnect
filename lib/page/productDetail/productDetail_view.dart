import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redux/redux.dart';
import '../../model/appState.dart';
import '../../model/user.dart';

// html 显示
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import '../../constant/colors.dart';
import '../../constant/http.dart';
import '../../helper/HttpUtils.dart';

class ProductDetail extends StatelessWidget {
  final String cntntId;

  ProductDetail(this.cntntId);
  @override
  Widget build(BuildContext context) {
    return new StoreBuilder<AppState>(
      builder: (context, store) => new ProductDetailWidget(store.state.loginUser, cntntId),
    );
  }
}

class ProductDetailWidget extends StatefulWidget {
  final LoginUser user;
  final String cntntId;

  ProductDetailWidget(this.user, this.cntntId);
  @override
  _ProductDetailWidgetState createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  static String loadingStr = '正在加载...';
  String focusImgUrl = '';
  String topic = loadingStr;
  String keywords = loadingStr;
  String currency = loadingStr;
  String strategyHtmlStr = loadingStr;
  String advisorName = loadingStr;
  String advisorMail = loadingStr;
  String advisorTel = loadingStr;
  String fundSize = loadingStr;
  String dueTime = loadingStr;
  String deliveryTime = loadingStr;

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      this.getProductDetail();
    }

  void getProductDetail() async {
    String responseStr = await HonyHttp.get("/cm/product/findById",
      params: { "cntntId": widget.cntntId },
      user: widget.user
    );

    Map responseJson = jsonDecode(responseStr);
    if (responseJson['success'] == true) {
      setState(() {
        // print(responseJson['result']);
        topic = responseJson['result']['topic'];
        keywords = responseJson['result']['keyWord'];
        focusImgUrl = responseJson['result']['focusImgUrl'];
        fundSize = responseJson['result']['fundSize'];
        currency = responseJson['result']['currency'];

        advisorName = responseJson['result']['advisorName'];
        advisorMail = responseJson['result']['advisorMail'];
        advisorTel = responseJson['result']['advisorTel'];

        dueTime = responseJson['result']['dueTime'];
        deliveryTime = responseJson['result']['deliveryTime'];
        strategyHtmlStr = responseJson['result']['content'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(88)),
        child: new AppBar(
          title: new Text('Product Details', style: new TextStyle(fontSize: ScreenUtil().setSp(30)),),
          centerTitle: true,
        ),
      ) ,
      body: new ListView(
        children: <Widget>[
          new Image(
            image: focusImgUrl == ''
              ? new AssetImage('lib/images/hony-placeholder.jpg')
              : new NetworkImage('$urlHost${focusImgUrl}'),
            width: double.infinity,
            height: ScreenUtil().setHeight(300),
            fit: BoxFit.fill,
          ),
          new Padding(
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setHeight(10),
              horizontal: ScreenUtil().setWidth(30),
            ),
            child: new Text(keywords, 
              style: new TextStyle(
                color: assistFontColor,
                fontSize: ScreenUtil().setSp(20)
              )
            )
          ),
          new Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
                  child: new Text(topic, 
                    style: new TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    )
                  ),
                ),
                new ProductListTile(title: 'Fund Size', tail: fundSize,),
                new ProductListTile(title: 'Currency', tail: currency,),
                new ProductListTile(title: 'Term', tail: dueTime,),
                new ProductListTile(title: 'Estimate final delivery date', tail: deliveryTime,),
                new ProductListTile(title: 'Exclusive Advisor', tail: advisorName,
                  tileWidget: new Padding(
                    padding: EdgeInsets.fromLTRB(
                      ScreenUtil().setWidth(40), 
                      0.0, 
                      0.0, 
                      ScreenUtil().setHeight(30), 
                    ),
                    child: new Column(
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Expanded(
                            child: new Text('E-mail Address: ', style: new TextStyle(fontSize: ScreenUtil().setSp(22)),)
                          ),
                          new Text(advisorMail, style: new TextStyle(fontSize: ScreenUtil().setSp(22))),
                          new Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),),
                          new Icon(Icons.mail, color: primaryColor,)
                        ],
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          new Expanded(
                            child: new Text('Phone Number: ', style: new TextStyle(fontSize: ScreenUtil().setSp(22)))
                          ),
                          new Text(advisorTel, style: new TextStyle(fontSize: ScreenUtil().setSp(22))),
                          new Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),),
                          new Icon(Icons.phone, color: primaryColor,)
                        ],
                      ),
                    ],
                  )
                  ),
                ),
                new ProductListTile(title: 'Product strategy', tail: '', isFinal: true,
                  tileWidget: new Container(
                    child: new Html(
                      data: strategyHtmlStr,
                      padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
                      backgroundColor: greyBgColor,
                      defaultTextStyle: new TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil().setSp(22)
                      ),
                      customRender: (node, children) {
                        if (node is dom.Element && node.localName == "img" && node.attributes['src'] != null) {
                          String oldStr = node.attributes['src'];
                          if (oldStr.startsWith("/")) {
                            node.attributes['src'] = urlHost + oldStr;
                          }
                        }
                      }
                    )
                  )
                ),
              ]
            )
          ),
          new Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(60)),
          ),
          new FlatButton(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(15)),
            color: greyBgColor,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(Icons.arrow_drop_down, color: primaryColor,),
                new Text('File', 
                  style: new TextStyle(
                    fontSize: ScreenUtil().setSp(28)
                  ),
                )
              ],
            ),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}


class ProductListTile extends StatefulWidget {
  final bool isFinal;
  final String title;
  final String tail;
  final Widget tileWidget;

  ProductListTile({
    @required this.title,
    this.isFinal = false,
    this.tail,
    this.tileWidget
  });

  @override
  ProductListTileState createState() => new ProductListTileState();
}

class ProductListTileState extends State<ProductListTile> {
  bool showDetail = false;

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

  @override
  Widget build(BuildContext context) {
    dynamic subIcon;
    if (widget.tileWidget != null ) {
      if (showDetail) {
        subIcon = new Icon(Icons.arrow_drop_down, color: primaryColor);
      } else {
        subIcon = new Icon(Icons.arrow_left, color: primaryColor);
      }
    } else {
      subIcon = new Container();
    }

    TextStyle labelFontStyle = new TextStyle(
      fontSize: ScreenUtil().setSp(28),
      fontWeight: FontWeight.bold  
    );

    TextStyle contFontStyle = new TextStyle(
      fontSize: ScreenUtil().setSp(28),
    );

    return new InkWell(
      splashColor: Colors.white,
      onTap: () {
        setState(() {
          showDetail = !showDetail;       
        });
      },
      child: new Container(
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(
              color: widget.isFinal
                ? Colors.white
                : splitColor
            )
          )
        ),
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                  child: new Container(
                    height: ScreenUtil().setHeight(16),
                    width: ScreenUtil().setWidth(16),
                    color: primaryColor,
                  )
                ),
                new Expanded(
                  child: new Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setHeight(30)
                    ),
                    child: new Text(widget.title, 
                      style: labelFontStyle,
                    )
                  ),
                ),
                new Container(
                  child: new Row(
                    children: <Widget>[
                      new Text(widget.tail, style: contFontStyle,),
                      subIcon
                    ],
                  ),
                )
              ],
            ),
            widget.tileWidget != null && showDetail
            ? widget.tileWidget
            : new Container()
          ],
        )
      )
    );
  }
}