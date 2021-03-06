import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../model/appState.dart';

import '../../constant/colors.dart';
import '../../constant/http.dart';
import '../../ui/toast.dart';

///1.怎么选择照片；2.怎么拼装上传接口 ！！！
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import './personal_action.dart';


class PersonalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, Map<String, dynamic>>(
      converter: (Store<AppState> store) {
        return {
          "onSuccessModifyPhoto": (String newPhotoUrl, Function callback){
            return store.dispatch(updateUserPhoto(photoUrl: newPhotoUrl, callback: callback));
          },
          "userState": store.state.loginUser,
        };
      },
      builder: (context, Map<String, dynamic> storeObj) {
        return new PersonalPageWidget(storeObj);
      }
    );
  }
}

class PersonalPageWidget extends StatefulWidget {
  final Map storeObj;
  PersonalPageWidget(this.storeObj);

  @override
  _PersonalPageWidgetState createState() => _PersonalPageWidgetState();
}

class _PersonalPageWidgetState extends State<PersonalPageWidget> {
  bool isUploading = false;
  File _imageFile;

  Future<Null> uploadImage() async {
    String accessToken = widget.storeObj['userState'].accessToken;
    String refreshToken = widget.storeObj['userState'].refreshToken;

    Map<String, String> headers = {
      "Authorization": 'bearer $accessToken',
      "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      "Content-Type": 'multipart/form-data',
    };

    /// 读取文件长度必须是异步，所有的文件操作都是异步，如果不写成await，则会报错
    final int length = await _imageFile.length();

    http.ByteStream imageStream = new http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
    http.MultipartFile imageStreamFile = new http.MultipartFile(
        'image',
        imageStream,
        length,
        filename: "avatar", /// fucking filename is @required !!!!
        contentType: new MediaType('image', 'png')
    );

    http.MultipartRequest multiReq = new MultipartRequest("POST", Uri.parse('$urlHost/nd/image/upload'));
    multiReq.headers.addAll(headers);
    multiReq.files.add(imageStreamFile);

    var response = await multiReq.send();

    setState(() {
      isUploading = true;
    });

    Navigator.of(context).pop();

    response.stream.transform(utf8.decoder).listen((resStr) {
      Map<String, dynamic> resData = jsonDecode(resStr);

      if (resData['success'] != true) {
        showErrorToast("某种原因，上传失败，请重新发送");
        return null;
      }
      widget.storeObj['onSuccessModifyPhoto'](resData['result'], (bool isSuccess) {
        print('is success is $isSuccess');
        if (!isSuccess) {
          showErrorToast("上传成功，但是无法替换");
          return null;
        }
        print("上传成功");
      });
    });
  }

  void showImagePicker(context) {
    /// showModalBottomSheet 底部网上升起的组件
    showModalBottomSheet<void>(context: context, builder: (BuildContext ctx) {
      return new Container(
        height: ScreenUtil().setWidth(180),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            renderImagePickerSource('相册选择'),
          ],
        ),
      );
    });
  }

  Widget renderImagePickerSource(String title) {
    return new InkWell(
      onTap: syncImage,
      child: new Container(
        height: ScreenUtil().setWidth(60),
        child: new Center(
          child: new Text(
            title,
            style: new TextStyle(
                fontSize: ScreenUtil().setWidth(27)
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> syncImage() async {
    var _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = _image;
      uploadImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle myStyle = new TextStyle(
      color: emptyColor,
      fontSize: ScreenUtil().setWidth(24),
    );

    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(ScreenUtil().setHeight(88)),
            child: new AppBar(
              title: new Text('My Personal Information', style: new TextStyle(fontSize: ScreenUtil().setSp(30))),
              centerTitle: true,
            ),
          ) ,
          body: new ListView(
            children: <Widget>[
              new Container(
                height: ScreenUtil().setWidth(345),
                decoration: new BoxDecoration(
                  color: primaryColor,
                  image: new DecorationImage(
                    image: new AssetImage('lib/images/bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(50)
                        )
                    ),
                    new Container(
                        height: ScreenUtil().setWidth(120),
                        width: ScreenUtil().setWidth(120),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
                        decoration: new BoxDecoration(
                          color: emptyColor,
                          shape: BoxShape.circle,
                        ),
                        child: new InkWell(
                          onTap: () {
                            showImagePicker(context);
                          },
                          child: new CircleAvatar(
                              radius: ScreenUtil().setWidth(58),
                              backgroundColor: primaryColor,
                              backgroundImage: widget.storeObj['userState'].photoUrl != null ?
                              new NetworkImage('$urlHost/nd/image/${widget.storeObj['userState'].photoUrl}')
                                  :
                              new AssetImage('lib/images/fakehony.jpg')
                          ),
                        )
                    ),

                    new Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(20)
                        )
                    ),
                    new Text(
                      widget.storeObj['userState'].position,
                      style: myStyle,
                    ),
                    new Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(20)
                        )
                    ),
                    new Text(widget.storeObj['userState'].name, style: new TextStyle(
                        fontSize: ScreenUtil().setWidth(30),
                        fontWeight: FontWeight.bold,
                        color: emptyColor
                    ),)
                  ],
                ),
              ),
              new Container(
                child: new Column(
                  children: <Widget>[
                    new Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(20)
                        )
                    ),
                    new PersonalRow(
                        keyText: "Mobile",
                        valueText: widget.storeObj['userState'].mobile
                    ),
                    new PersonalRow(
                        keyText: "Email",
                        valueText: widget.storeObj['userState'].mail
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ]
    );
  }
}

class PersonalRow extends StatelessWidget {
  final String keyText;
  final String valueText;

  PersonalRow({
    @required this.keyText,
    @required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle uStyle = new TextStyle(
      color: Colors.black,
      fontSize: ScreenUtil().setWidth(27),
    );

    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Container(
            color: primaryColor,
            height: ScreenUtil().setWidth(20),
            width: ScreenUtil().setWidth(20),
          ),
          new Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(20)
            ),
            child: new Text(
              keyText,
              style: uStyle,
            ),
          ),
          new Expanded(
              child: new Container(
                  alignment: Alignment.centerRight,
                  child: new Text(
                    valueText,
                    style: uStyle,
                  )
              )
          )
        ],
      ),
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(20),
          horizontal: ScreenUtil().setWidth(30)
      ),
    );
  }
}
