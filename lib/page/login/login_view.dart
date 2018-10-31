import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../constant/sizes.dart';
import '../../helper/pixelCompact.dart';
import '../../ui/combineIconInput.dart';
import '../../ui/extendButton.dart';
import '../../ui/pendingOverlay.dart';
import '../../ui/toast.dart';

import '../../model/appState.dart';
import './login_action.dart';

import '../home_view.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new StoreConnector(
      /// KEY 此处必须注明 Store<AppState> ，不然出现No StoreProvider<dynamic> found
      converter: (Store<AppState> store) {
        return {
          "onClickLogin": (String username, String password, Function callback) {
            return store.dispatch(
              userLoginActionCreator(
                username: username,
                password: password,
                callback: callback
              )
            );
          },
          "userState": store.state.loginUser
        };
      },
      builder: (context, Map<String, dynamic> stateObj) {
        return new LoginPageWidget(stateObj);
      },
    );
  }
}


class LoginPageWidget extends StatefulWidget {
  final Map stateObj;
  LoginPageWidget(this.stateObj);

  @override
  _LoginPageWidgetState createState() => new _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> with PixelCompactMixin{
  String username = '';
  String password = '';
  final grantType = 'password';

  String text = 'Login';

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
    widget.stateObj['onClickLogin'](username, password, (bool isSuccess){
      if (!isSuccess) {
        return showConnectToast(widget.stateObj['userState'].errorMsg);
      }

//      Navigator.of(context).pushNamed('/main');
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (BuildContext context) => new HomePage()),
              (Route route) => route == null);
    });
  }

  void hideKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
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
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidth(95.0, winWidth)),
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
                          !widget.stateObj["userState"].isLoading,
                          handleLogin
                      ),
                    ],
                  ),
                )
              ]
            ),
            widget.stateObj["userState"].isLoading ? new PendingOverlay('Loading', () {}) : new Container()
          ]
        )
      )
    );
  }
}