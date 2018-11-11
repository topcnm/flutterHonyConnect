import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../constant/colors.dart';
import '../constant/sizes.dart';
import '../constant/http.dart';
import '../helper/pixelCompact.dart';

import '../model/appState.dart';
import '../model/user.dart';

import '../helper/HttpUtils.dart';
import '../helper/localeUtils.dart';

//import '../ui/toast.dart';
class NewsDetail extends StatelessWidget {
  final String cntntId;

  NewsDetail({
    this.cntntId
  });

  @override
  Widget build(BuildContext context) {
    return new StoreConnector(
      converter: (Store<AppState> store) => store.state.loginUser,
      builder: (context, LoginUser user) {
        return new NewsDetailWidget(cntntId, user);
      },
    );
  }
}


class NewsDetailWidget extends StatefulWidget {
  final String cntntId;
  final LoginUser user;

  NewsDetailWidget(this.cntntId, this.user);

  @override
_NewsDetailWidgetState createState() => _NewsDetailWidgetState();
}

class _NewsDetailWidgetState extends State<NewsDetailWidget> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  VoidCallback _showPersBottomSheetCallBack;

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

  Map currentComment = {};
  List comments = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showPersBottomSheetCallBack = _showBottomSheet;
    renderPageContent();
    renderPageComment();
  }


  void renderPageContent() {
    HonyHttp.get(
      "/cm/news/findById",
      params: { "cntntId": widget.cntntId },
      user: widget.user
    ).then((res) {
      Map resJson = jsonDecode(res);
      if (resJson['success'] && resJson['result'] != null) {
        setState(() {
          cntntId = resJson['result']['cntntId'];
          topic = resJson['result']['topic'];
          htmlStr = resJson['result']['content'] == null ? "" : resJson['result']['content'];
          isLike = resJson['result']['like'];
          isFavour = resJson['result']['favorite'];
        });
      }
    }).catchError((){
      print('*******8 error');
    });
  }

  void renderPageComment() {
    HonyHttp.get(
      "/cm/comment/findByCntnId",
      params: { "cntntId": widget.cntntId, "pageNo": 1, "pageSize": 999 },
      user: widget.user
    ).then((res) {
      Map resJson = jsonDecode(res);
      if (resJson['success'] && resJson['result'] != null) {
        setState((){
          comments = resJson['result']['content'];
        });
      }
    });
  }

  void handleCommentCommit(String reply) {
    HonyHttp.postJson(
      "/cm/comment/create",
      params: { "cntntId": cntntId, "reply": reply },
      user: widget.user
    ).then((res){
      Map resJson = jsonDecode(res);
      if (resJson['success']) {
        setState(() {
          comments = [resJson['result']] + comments;
        });
        Navigator.pop(context); // 关闭dailog
      }
    });
  }

  void handleContentLike() {
    HonyHttp.postJson(
      "/cm/comment/${ isLike ? 'unLikeContent' : 'likeContent'}",
      params: { "cntntId": cntntId },
      user: widget.user
    ).then((res) {
      Map resJson = jsonDecode(res);
      if (resJson['success']) {
        setState((){
          isLike = !isLike;
        });
      }
    });
  }

  void handleContentFav() {
    HonyHttp.postJson(
      "/ucm/user/${ isFavour ? 'unFavorite' : 'createFavorite'}",
      params: {
        "refId": cntntId,
        "type": 'CONTENT'
      },
      user: widget.user
    ).then((res) {
      Map resJson = jsonDecode(res);
      if (resJson['success']) {
        setState((){
          isFavour = !isFavour;
        });
      }
    });
  }

  void _showBottomSheet() {
    setState(() {
      _showPersBottomSheetCallBack = null;
      currentComment = {};
    });

    _scaffoldKey.currentState.showBottomSheet((context) {
      return new CommentDialog(
        onTapCancel: () {
          Navigator.pop(context);
        },
        onTapConfirm: handleCommentCommit,
      );
    }).closed.whenComplete(() {
      if (mounted) {
        setState(() {
          _showPersBottomSheetCallBack = _showBottomSheet;
        });
      }
    });
  }

  void showComment(Map commentItem) {
    setState(() {
      currentComment = commentItem;
    });

    showModalBottomSheet(context: context, builder: (BuildContext ctx) {
      return new CommentDialog(
        onTapCancel: () {
          Navigator.pop(context);
        },
        onTapConfirm: handleCommentCommit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(LocaleUtils.getLocale(context).newsDetailTitle),
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
                vertical: ScreenUtil().setWidth(10),
                horizontal: ScreenUtil().setWidth(30)
            ),
            child: new Text('Investment Express', style: new TextStyle(
              fontSize: ScreenUtil().setWidth(16)
            ),),
          ),
          new Container(
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(20),
              horizontal: ScreenUtil().setWidth(30)
            ),
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new Text(
                    topic,
                    style: new TextStyle(
                      fontSize: ScreenUtil().setWidth(32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
                ),
                new Container(
                  child: new Html(
                    data: htmlStr,
                    customRender: (node, children) {
                      if (node is dom.Element && node.localName == "img" && node.attributes['src'] != null) {
                        String oldStr = node.attributes['src'];
                        if (oldStr.startsWith("/")) {
                          node.attributes['src'] = urlHost + oldStr;
                        }
                      }
                    }
                  ),
                )
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
      bottomNavigationBar: _showPersBottomSheetCallBack == null ? new Container(height: 0.0,) : new Container(
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
              onTap: _showPersBottomSheetCallBack,
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

class _NewsDetailBottomMenuItemState extends State<NewsDetailBottomMenuItem> {

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      flex: 1,
      child: new Container(
        height: ScreenUtil().setWidth(100),
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
                  size: ScreenUtil().setWidth(36),
                  color: widget.isActive ? emptyColor: primaryColor,
                ),
                new Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(8)
                    )
                ),
                new Text(
                  widget.text,
                  style: new TextStyle(
                    fontSize: ScreenUtil().setWidth(20),
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

class _CommentItemState extends State<CommentItem> {

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(20),
          horizontal: ScreenUtil().setWidth(30)
      ),
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: splitColor))
      ),
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(
                bottom: ScreenUtil().setWidth(20)
            ),
            child: new CircleAvatar(
              radius: ScreenUtil().setWidth(26),
              backgroundImage: new NetworkImage('$urlHost/nd/image/${widget.comment.userheadImg}'),
            ),
          ),
          new Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(20)
              )
          ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            widget.comment.userName,
                            style: new TextStyle(
                              fontSize: ScreenUtil().setWidth(18),
                            ),
                          ),

                          new Text(
                            '4 hour before',
                            style: new TextStyle(
                                fontSize: ScreenUtil().setWidth(14),
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
                            iconSize: ScreenUtil().setWidth(16),
                            onPressed: null
                          ),
                          new Text(
                            '${widget.comment.likeCount}',
                            style: new TextStyle(
                              color: primaryColor
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  new Text(
                    widget.comment.reply,
                    style: new TextStyle(
                        fontSize: ScreenUtil().setWidth(22)
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

class _CommentDialogState extends State<CommentDialog> with SingleTickerProviderStateMixin {
  TextEditingController textEditingController = new TextEditingController();
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
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: new Container(
          height: ScreenUtil().setWidth(580),

          child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Container(
                height: ScreenUtil().setWidth(89),
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(20),
                  horizontal: ScreenUtil().setWidth(30)
                ),
                width: double.infinity,
                child: new Row(
                  children: <Widget>[
                    new CommentDialogButton(text: 'Cancel', onTap: widget.onTapCancel),
                    new Expanded(
                        child: new Container(
                          alignment: Alignment.center,
                          child: new Text('Comment',
                            style: new TextStyle(fontSize: ScreenUtil().setWidth(30)),
                          ),
                        )
                    ),
                    new CommentDialogButton(text: 'Send', onTap: handleConfirm),
                  ],
                ),
                decoration: new BoxDecoration(
                  border: new Border(
                    bottom: new BorderSide(color: splitColor),
                    top: new BorderSide(color: splitColor),
                  )
                ),
              ),
              new Container(
                height: ScreenUtil().setWidth(490),
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setWidth(20),
                  horizontal: ScreenUtil().setWidth(30)
                ),
                child: new TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 999,
                  decoration: new InputDecoration(
                    hintText: 'Please type in',
                    border: InputBorder.none,
                  ),
                  onChanged: (String str) {
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
