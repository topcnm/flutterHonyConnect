import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';

import '../constant/colors.dart';
import '../constant/sizes.dart';
import '../constant/http.dart';
import '../helper/pixelCompact.dart';
import '../ui/combineIconInput.dart';
import '../ui/extendButton.dart';
import '../ui/pendingOverlay.dart';
import '../ui/toast.dart';

class NewsDetail extends StatefulWidget {
  final String cntntId;

  NewsDetail({
    @required this.cntntId,
  });

  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> implements PixelCompactMixin{
  String htmlStr = '';
  String cntntType ='';
  String cntntClassify = '';
  String topic = '';
  bool favorite = false;
  bool isFavouring = false;
  bool like = false;
  bool isLiking = false;
  bool shareFlg = false;
  List fileList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    renderPageContent();
  }

  void renderPageContent() {
    getPageContent().then((res) {
      Map resJson = jsonDecode(res);
      print(resJson is Map);
      if (resJson['success']) {
        setState(() {
          topic = resJson['result']['topic'];
          htmlStr = resJson['result']['content'];
        });
      }
    });
  }

  Future getPageContent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');

    http.Response response = await http.get(
      Uri.encodeFull('$urlHost/cm/news/findById?cntntId=${widget.cntntId}'),
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      }
    );

    return response.body;
  }

  void renderPageComment() {

  }

  Future getPageComment() async {

  }

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    String markdown = html2md.convert(htmlStr);
    return new Stack(
      fit: StackFit.expand,
      children: [
        new Scaffold(
          appBar: new AppBar(
            title: new Text('资讯详情'),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(IconData(0xe6ba, fontFamily: 'aliFont'), color: emptyColor,),
                  onPressed: null
              )
            ],
          ),
          body: new ListView(
            children: <Widget>[
              new Container(
                color: greyBgColor,
                padding: EdgeInsets.symmetric(
                    vertical: getWidth(10.0, winWidth),
                    horizontal: getWidth(30.0, winWidth)
                ),
                child: new Text('Investment Express', style: new TextStyle(
                  fontSize: getWidth(16.0, winWidth)
                ),),
              ),
              new Container(
                padding: EdgeInsets.symmetric(
                    vertical: getWidth(20.0, winWidth),
                  horizontal: getWidth(30.0, winWidth)
                ),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Text(
                        topic,
                        style: new TextStyle(
                          fontSize: getWidth(32.0, winWidth),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(bottom: getWidth(10.0, winWidth)),
                    ),

                    new MarkdownBody(
                      data: markdown,
                    ),
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.symmetric(
                    vertical: getWidth(20.0, winWidth),
                    horizontal: getWidth(30.0, winWidth)
                ),
                decoration: new BoxDecoration(
                    border: new Border(bottom: new BorderSide(color: splitColor))
                ),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new CircleAvatar(
                      radius: getWidth(26.0, winWidth),
                      backgroundImage: new AssetImage('lib/images/fakehony.jpg'),
                    ),
                    new Padding(padding: EdgeInsets.only(left: getWidth(20.0, winWidth))),
                    new Expanded(
                        child: new Column(
                            children: <Widget>[
                              new Padding(padding: EdgeInsets.only(top: getWidth(10.0, winWidth))),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(
                                        'Martinan ner finded',
                                        style: new TextStyle(
                                            fontSize: getWidth(18.0, winWidth)
                                        ),
                                      ),
                                      new Text(
                                        '4 hour before',
                                        style: new TextStyle(
                                            fontSize: getWidth(14.0, winWidth),
                                            color: assistFontColor
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              new Padding(padding: EdgeInsets.only(top: getWidth(10.0, winWidth))),
                              new Text(
                                'As lone as uhdi bibfasdnbij dnwdasiofhaasdjk hih asda hhahih asdhi dasd',
                                style: new TextStyle(
                                    fontSize: getWidth(22.0, winWidth)
                                ),
                              )
                            ]
                        )
                    )
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: new Container(
            child: new Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new NewsDetailBottomMenuItem(
                  isActive: true,
                  text: "Like",
                  icon: IconData(0xe644, fontFamily: 'aliFont'),
                  onTap: (){},
                ),
                new NewsDetailBottomMenuItem(
                  isActive: false,
                  text: "Comments",
                  icon: IconData(0xe626, fontFamily: 'aliFont'),
                  onTap: (){},
                ),
                new NewsDetailBottomMenuItem(
                  isActive: true,
                  text: "Favourites",
                  icon: IconData(0xe7ae, fontFamily: 'aliFont'),
                  onTap: (){},
                ),
              ],
            ),
          )
        ),
        new CommentDialog(),
      ]
    );
  }
}

class NewsDetailBottomMenuItem extends StatefulWidget {
  final bool isActive;
  final Function onTap;
  final IconData icon;
  final String text;

  NewsDetailBottomMenuItem({
    this.isActive = false,
    this.text = 'EM',
    @required this.icon,
    @required this.onTap
  });

  @override
  _NewsDetailBottomMenuItemState createState() => _NewsDetailBottomMenuItemState();
}

class _NewsDetailBottomMenuItemState extends State<NewsDetailBottomMenuItem> with PixelCompactMixin{
  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new Expanded(
      flex: 1,
      child: new Container(
        height: getWidth(100.0, winWidth),
        child:new MaterialButton(
          onPressed: widget.onTap,
          color: widget.isActive ? primaryColor : greyBgColor,
          child:new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                widget.icon,
                size: getWidth(36.0, winWidth),
                color: widget.isActive ? emptyColor: primaryColor,
              ),
              new Padding(
                  padding: EdgeInsets.only(
                      top: getWidth(8.0, winWidth)
                  )
              ),
              new Text(
                widget.text,
                style: new TextStyle(
                  fontSize: getWidth(20.0, winWidth),
                  color: widget.isActive ? emptyColor: primaryColor
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}


class CommentModel {
  String cmntId;
  String cntntId;
  String parentCmntId;
  int likeCount;
  bool like;
  String reply;
  String replyTime;
  String userheadImg;
  String userName;

  CommentModel({
    @required this.cmntId,
    @required this.cntntId,
    @required this.like,
    @required this.likeCount,
    @required this.reply,
    @required this.replyTime,
    @required this.userName,
    this.userheadImg = '',
    this.parentCmntId = '',
  });
}

class CommentItem extends StatefulWidget {
  final CommentModel comment;

  CommentItem({
    @required this.comment
  });

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> with PixelCompactMixin{
  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new Container(
      padding: EdgeInsets.symmetric(
          vertical: getWidth(20.0, winWidth),
          horizontal: getWidth(30.0, winWidth)
      ),
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: splitColor))
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new CircleAvatar(
            radius: getWidth(26.0, winWidth),
            backgroundImage: new AssetImage('lib/images/fakehony.jpg'),
          ),
          new Padding(padding: EdgeInsets.only(left: getWidth(20.0, winWidth))),
          new Expanded(
              child: new Column(
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.only(top: getWidth(10.0, winWidth))),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              'Martinan ner finded',
                              style: new TextStyle(
                                  fontSize: getWidth(18.0, winWidth)
                              ),
                            ),
                            new Text(
                              '4 hour before',
                              style: new TextStyle(
                                  fontSize: getWidth(14.0, winWidth),
                                  color: assistFontColor
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    new Padding(padding: EdgeInsets.only(top: getWidth(10.0, winWidth))),
                    new Text(
                      'As lone as uhdi bibfasdnbij dnwdasiofhaasdjk hih asda hhahih asdhi dasd',
                      style: new TextStyle(
                          fontSize: getWidth(22.0, winWidth)
                      ),
                    )
                  ]
              )
          )
        ],
      ),
    );
  }
}

class CommentDialog extends StatefulWidget {
  @override
  _CommentDialogState createState() => new _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> with SingleTickerProviderStateMixin implements PixelCompactMixin{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }
  
  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: new Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.black54,
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Container(
              color: emptyColor,
              child: new Column(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.symmetric(
                      vertical: getWidth(20.0, winWidth),
                      horizontal: getWidth(30.0, winWidth)
                    ),
                    width: double.infinity,
                    child: new Row(
                      children: <Widget>[
                        new CommentDialogButton(text: 'Cancel', onTap: (){}),
                        new Expanded(
                            child: new Container(
                              alignment: Alignment.center,
                              child: new Text('Comment',
                                style: new TextStyle(fontSize: getWidth(30.0, winWidth)),
                              ),
                            )
                        ),
                        new CommentDialogButton(text: 'Send out', onTap: (){}),
                      ],
                    ),
                    decoration: new BoxDecoration(
                      border: new Border(bottom: new BorderSide(color: splitColor))
                    ),
                  ),
                  new Container(
                    height: getWidth(490.0, winWidth),
                    padding: EdgeInsets.symmetric(
                        vertical: getWidth(20.0, winWidth),
                      horizontal: getWidth(30.0, winWidth)
                    ),
                    child: new TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 999,
                      decoration: new InputDecoration(
                        hintText: 'Please type in',
                        border: InputBorder.none,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

class CommentDialogButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  CommentDialogButton({
    @required this.text,
    @required this.onTap
  });
  @override
  _CommentDialogButtonState createState() => _CommentDialogButtonState();
}

class _CommentDialogButtonState extends State<CommentDialogButton> with PixelCompactMixin{
  @override
  double getWidth(double num, double winWidth) {
    // TODO: implement getWidth
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new Container(
      child: new InkWell(
        onTap: widget.onTap,
        child: new Text(
          widget.text,
          style: new TextStyle(
              color: primaryColor
          ),
        ),
      ),
      width: getWidth(105.0, winWidth),
      height: getWidth(36.0, winWidth),
      decoration: new BoxDecoration(
          border: new Border.all(color: primaryColor),
          borderRadius: new BorderRadius.all(
              new Radius.circular(getWidth(4.0, winWidth))
          )
      ),
      alignment: Alignment.center,
    );
  }
}
