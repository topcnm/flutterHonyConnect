import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../model/appState.dart';
import '../../model/user.dart';

import './logout_action.dart';

import '../../ui/toast.dart';
import '../../ui/extendButton.dart';

import '../../constant/sizes.dart';
import '../../constant/colors.dart';
import '../../helper/pixelCompact.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, Map>(
      converter: (Store<AppState> store) {
        return {
          "onClickLogout": (someCallback) => store.dispatch(
              userLogoutActionCreator(callback: someCallback)
          ),
          "onClickSwitchLanguage": (Language newLanguage, Function anyCallBack) => store.dispatch(
              userSwitchLanguageActionCreator(newLanguage: newLanguage, callback: anyCallBack)
          ),
          "userState": store.state.loginUser
        };
      },
      builder: (context, Map storeObj) {
        return new SettingPageWidget(storeObj);
      }
    );
  }
}

class SettingPageWidget extends StatefulWidget {
  final Map storeObj;

  SettingPageWidget(this.storeObj);
  @override
  _SettingPageWidgetState createState() => _SettingPageWidgetState();
}

class _SettingPageWidgetState extends State<SettingPageWidget> with PixelCompactMixin{

  void handleLogout() {
    widget.storeObj['onClickLogout']((bool isSuccess) {
      if (!isSuccess) {
        return showConnectToast("登出失败，不知道什么原因");
      }

      Navigator.of(context).pushNamed('/login');
    });
  }

  void showLanguageModal(context) {
    showModalBottomSheet<void>(context: context, builder: (BuildContext ctx) {
      double winWidth = MediaQuery.of(context).size.width;
      return new Container(
        height: getWidth(220.0, winWidth),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            renderLanguageItem(widget.storeObj["userState"].locale == Language.en, 'English', Language.en),
            new Divider(color: splitColor,),
            renderLanguageItem(widget.storeObj["userState"].locale == Language.zh, 'Chinese', Language.zh),
          ],
        ),
      );
    });
  }

  Widget renderLanguageItem(bool isActive, String title, Language lg) {
//    double winWidth = MediaQuery.of(context).size.width;
    return new ListTile(
      leading: new Icon(Icons.select_all, color: isActive ? primaryColor : Colors.black54,),
      title: new Text(title),
      onTap: () {
        widget.storeObj['onClickSwitchLanguage'](lg, (bool isSuccess) {
          if(!isSuccess) {
            return showConnectToast("切换语言失败，请稍后再试");
          }

          Navigator.of(context).pop();
        });
      },
    );
  }

  @override
  double getWidth(double num, double winWidth) {
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Setting'),
        centerTitle: true,
      ),
      body: new Container(
        padding: new EdgeInsets.symmetric(
            vertical: getWidth(20.0, winWidth),
          horizontal: getWidth(30.0, winWidth)
        ),
        child: new ListView(
          children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.store),
              title: new Text('Version'),
              trailing: new Text('2.0'),
            ),
            new Divider(color: splitColor,),
            new ListTile(
              leading: new Icon(Icons.language),
              title: new Text('Language Setting'),
              trailing: new Icon(Icons.chevron_right, color: primaryColor,),
              onTap: () {
                showLanguageModal(context);
              },
            ),
            new Divider(color: splitColor,),
            new Padding(padding: EdgeInsets.only(top: getWidth(40.0, winWidth))),
            new ExtendButton(
                "Logout",
                true,
                handleLogout
            ),
          ],
        ),
      ),
    );
  }
}
