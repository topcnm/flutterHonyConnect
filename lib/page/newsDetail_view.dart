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
//import '../ui/toast.dart';

class NewsDetail extends StatefulWidget {
  final String cntntId;

  NewsDetail({
    @required this.cntntId,
  });

  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> implements PixelCompactMixin{
  String cntntId = '';
  String htmlStr = '';
  String cntntType ='';
  String cntntClassify = '';
  String topic = '';
  bool favorite = false;
  bool isFavour = false;
  bool likeCount = false;
  bool isLike = false;
  bool shareFlg = false;
  List fileList = [];

  bool isCommenting = false;
  Map currentComment = {};
  List comments = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    renderPageContent();
    renderPageComment();
  }

  void renderPageContent() {
    getPageContent().then((res) {
      Map resJson = jsonDecode(res);
      if (resJson['success'] && resJson['result'] != null) {
        setState(() {
          cntntId = resJson['result']['cntntId'];
          topic = resJson['result']['topic'];
          htmlStr = resJson['result']['content'];
          isLike = resJson['result']['like'];
          isFavour = resJson['result']['favorite'];
        });
      }
    }).catchError((){
      print('*******8 error');
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
    _getPageComment().then((res) {
      Map resJson = jsonDecode(res);
      print(resJson);
      if (resJson['success'] && resJson['result'] != null) {
        setState((){
          comments = resJson['result']['content'];
          print(comments);
        });
      }
    });
  }

  Future _getPageComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');

    http.Response response = await http.get(
        Uri.encodeFull('$urlHost/cm/comment/findByCntnId?cntntId=${widget.cntntId}&pageNo=1&pageSize=999'),
        headers: {
          "Accept": "application/json, text/plain, */*",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        }
    );

    return response.body;
  }

  void handleCommentCommit(String reply) {
    _handleCommentCommit(reply).then((res){
      Map resJson = jsonDecode(res);
      print(resJson);
      if (resJson['success']) {
        setState(() {
          comments = [resJson['result']] + comments;
        });
        hideComment();
      }
    });
  }

  Future _handleCommentCommit(String reply) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');

    Map postObj = {
      "cntntId": cntntId,
      "reply": reply
    };

    http.Response response = await http.post(
      Uri.encodeFull('$urlHost/cm/comment/create'),
      body: jsonEncode(postObj),
      headers: {
        "Accept": "application/json, application/x-www-form-urlencoded",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        "content-type": 'application/json',
      }
    );

    return response.body;
  }

  void handleContentLike() {
    _handleContentLike().then((res) {
      Map resJson = jsonDecode(res);
      print(resJson);
      if (resJson['success']) {
        setState((){
          isLike = !isLike;
        });
      }
    });
  }

  Future _handleContentLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');

    Map postObj = {
      "cntntId": cntntId
    };

    http.Response response = await http.post(
      Uri.encodeFull('$urlHost/cm/comment/${ isLike ? 'unLikeContent' : 'likeContent'}'),
      body: jsonEncode(postObj),
      headers: {
        "Accept": "application/json, application/x-www-form-urlencoded",
        "Authorization": 'bearer $accessToken',
        "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        "content-type": 'application/json',
      }
    );

    return response.body;
  }

  void handleContentFav() {
    _handleContentFav().then((res) {
      Map resJson = jsonDecode(res);
      if (resJson['success']) {
        setState((){
          isFavour = !isFavour;
        });
      }
    });
  }

  Future _handleContentFav() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');

    Map postObj = {
      "refId": cntntId,
      "type": 'CONTENT'
    };

    http.Response response = await http.post(
        Uri.encodeFull('$urlHost/ucm/user/${ isFavour ? 'unFavorite' : 'createFavorite'}'),
        body: jsonEncode(postObj),
        headers: {
          "Accept": "application/json, application/x-www-form-urlencoded",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
          "content-type": 'application/json',
        }
    );

    return response.body;
  }

  void showComment(Map commentItem) {
    setState(() {
      isCommenting = true;
      currentComment = commentItem;
    });
  }

  void hideComment() {
    setState(() {
      isCommenting = false;
    });
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
            centerTitle: true,
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
              new ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true, // ！！滚动区域内嵌到滚动区域，需要此属性！
                itemCount: comments.length,
                itemBuilder: (context, int index) {
                  Map comment = comments[index];
                  CommentModel cm = new CommentModel(
                    cmntId: comment['cmntId'],
                    cntntId: comment['cntntId'],
                    like: comment['like'],
                    likeCount: comment['likeCount'],
                    reply: comment['reply'],
                    replyTime: comment['replyTime'],
                    userheadImg: comment['userheadImg'],
                    userName: comment['userName']
                  );
                  return new CommentItem(comment: cm,);
                }
              )
            ],
          ),
          bottomNavigationBar: new Container(
            child: new Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new NewsDetailBottomMenuItem(
                  isActive: isLike,
                  text: "Like",
                  icon: IconData(0xe644, fontFamily: 'aliFont'),
                  onTap: handleContentLike,
                ),
                new NewsDetailBottomMenuItem(
                  isActive: false,
                  text: "Comments",
                  icon: IconData(0xe626, fontFamily: 'aliFont'),
                  onTap: (){
                    showComment({});
                  },
                ),
                new NewsDetailBottomMenuItem(
                  isActive: isFavour,
                  text: "Favourites",
                  icon: IconData(0xe7ae, fontFamily: 'aliFont'),
                  onTap: handleContentFav,
                ),
              ],
            ),
          )
        ),
        isCommenting ?
          new CommentDialog(
            onTapCancel: hideComment,
            onTapConfirm: handleCommentCommit,
          )
          :
          new Container(),
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
        decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: splitColor)),
        ),
        child:new InkWell(
          onTap: widget.onTap,
          child: new Container(
            color: widget.isActive ? primaryColor : greyBgColor,
            child: new Column(
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
            backgroundImage: new NetworkImage('$urlHost/nd/image/${widget.comment.userheadImg}'),
          ),
          new Padding(padding: EdgeInsets.only(left: getWidth(20.0, winWidth))),
          new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.only(top: getWidth(10.0, winWidth))),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              widget.comment.userName,
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
                        new Row(
                          children: <Widget>[
                            new IconButton(
                              icon: new Icon(
                                new IconData(0xe644, fontFamily: 'aliFont'), 
                                color: primaryColor,
                              ),
                              iconSize: getWidth(26.0, winWidth),
                              onPressed: null
                            ),
                            new Text('${widget.comment.likeCount}')
                          ],
                        )
                      ],
                    ),
                    new Padding(padding: EdgeInsets.only(top: getWidth(10.0, winWidth))),
                    new Text(
                      widget.comment.reply,
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
  final VoidCallback onTapCancel;
  final Function onTapConfirm;

  CommentDialog({
    @required this.onTapCancel,
    @required this.onTapConfirm,
  });

  @override
  _CommentDialogState createState() => new _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> with SingleTickerProviderStateMixin implements PixelCompactMixin{
  TextEditingController textEditingController = new TextEditingController();
  AnimationController controller;
  Animation<double> animation;

  String result = '';

  void handleConfirm() {
    widget.onTapConfirm(result);
    setState(() {
      textEditingController.text = '';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AnimationController controller = new AnimationController(
        vsync: this,
      duration: new Duration(milliseconds: 100)
    );
    animation = new CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation.addListener((){setState(() {

    });});
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    textEditingController.dispose();
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
                        new CommentDialogButton(text: 'Cancel', onTap: widget.onTapCancel),
                        new Expanded(
                            child: new Container(
                              alignment: Alignment.center,
                              child: new Text('Comment',
                                style: new TextStyle(fontSize: getWidth(30.0, winWidth)),
                              ),
                            )
                        ),
                        new CommentDialogButton(text: 'Send', onTap: handleConfirm),
                      ],
                    ),
                    decoration: new BoxDecoration(
                      border: new Border(bottom: new BorderSide(color: splitColor))
                    ),
                  ),
                  new Container(
                    height: animation.value * getWidth(490.0, winWidth),
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
                      onChanged: (String str) {
                        print(str);
                        setState(() {
                          result = str;
                        });
                      },
                      controller: textEditingController,
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
