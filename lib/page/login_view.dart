import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/sizes.dart';
import '../constant/http.dart';
import '../helper/pixelCompact.dart';
import '../ui/combineIconInput.dart';
import '../ui/extendButton.dart';
import '../ui/pendingOverlay.dart';
import '../ui/toast.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with PixelCompactMixin{
  String username = '';
  String password = '';
  final grantType = 'password';

  String text = 'Login';
  bool isLoading = false;

  void handleUsernameChange(String str) {
    setState(() {
      username = str;
    });
  }

  void handlePasswordChange(String str) {
    setState(() {
      password = str;
    });
  }

  void handleLogin() {
    hideKeyboard();

    String accessToken;
    String refreshToken;

    setState(() {
      isLoading = true;
    });

    getToken().then((res){
      Map<String, dynamic> responseData = jsonDecode(res.body);
      if (responseData['error'] != null) {
        throw(responseData["error_description"]);
      }
      accessToken = responseData['access_token'];
      refreshToken = responseData['refresh_token'];
      return getUsername(accessToken, refreshToken);
    }).then((res1){
      Map<String, dynamic> userResData = jsonDecode(res1.body);

      if (userResData['success'] == false) {
        throw(userResData['message']);
      }
      print(userResData);
      recordUser(accessToken, refreshToken, jsonEncode(userResData['result'])).then((res){
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }).catchError((value){
      print("The error is $value");
      showConnectToast(value);
    }).whenComplete((){
      print("Anyway, we should close connection");
      setState(() {
        isLoading = false;
      });
    });
  }

  void hideKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Future recordUser(String accessToken, String refreshToken, String userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', accessToken);
    prefs.setString('refreshToken', refreshToken);
    prefs.setString('userInfo', jsonEncode(userInfo));
  }

  Future getToken() async {
    http.Response tokenResponse = await http.post(
        Uri.encodeFull('$urlHost/ucm/oauth/token'),
        body: {
          "username": username,
          "password": password,
          "grant_type": grantType,
          "scope": "",
        },
        headers: {
          "Accept": "application/json, application/x-www-form-urlencoded",
          "Authorization": "Basic aG9ueWNvbm5lY3Q6MTIzNDU2",
        }
    );
    return tokenResponse;
  }

  Future getUsername(String accessToken, String refreshToken) async {
    http.Response userResponse = await http.get(
        Uri.encodeFull('$urlHost/ucm/user/currentUser'),
        headers: {
          "Accept": "application/json, text/plain, */*",
          "Authorization": 'bearer $accessToken',
          "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
        }
    );
    return userResponse;
  }

  @override
  double getWidth(double num, double winWidth) {
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new Scaffold(
        body: new GestureDetector(
            onTap: hideKeyboard,
            child: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Image(
                    image: new AssetImage('lib/images/login.jpg'),
                    fit: BoxFit.fill,
                  ),
                  new ListView(
                      children: <Widget>[
                        new Container(
                          padding: EdgeInsets.fromLTRB(
                              getWidth(135.0, winWidth),
                              getWidth(190.0, winWidth),
                              getWidth(135.0, winWidth),
                              getWidth(190.0, winWidth)
                          ),
                          child: new Image(
                            image: new AssetImage('lib/images/logo.png'),
                          ),
                        ),

                        new Container(
                          padding: EdgeInsets.symmetric(horizontal: getWidth(95.0, winWidth)),
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new CombineIconInput(
                                  Icons.email,
                                  handleUsernameChange,
                                  hasEye: false,
                                  placeHolder: 'Please Input your content',
                                  inputType: TextInputType.text
                              ),
                              new CombineIconInput(
                                  Icons.lock,
                                  handlePasswordChange,
                                  hasEye: true,
                                  placeHolder: 'Please Input your password',
                                  inputType: TextInputType.text
                              ),
                              new Padding(padding: EdgeInsets.only(
                                  top: getWidth(65.0, winWidth))
                              ),
                              new ExtendButton(
                                  "Login",
                                  !isLoading,
                                  handleLogin
                              ),
                            ],
                          ),
                        )

                      ]
                  ),
                  isLoading ? new PendingOverlay('Loading', (){}): new Container()
                ]
            )
        )
    );
  }
}

