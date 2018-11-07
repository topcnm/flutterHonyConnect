import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/colors.dart';

class ExtendButton extends StatelessWidget {
  final enabled;
  final String _text;
  final Function _onTap;

  ExtendButton(this._text, this.enabled, this._onTap);

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: double.infinity,
      child: new RaisedButton(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
        color: primaryColor,
        highlightColor: pressColor,
        disabledColor: disabledColor,
        child: new Text(
          _text,
          style: new TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil().setWidth(30),
          ),
        ),
        onPressed: enabled ? _onTap : null,
      ),
    );
  }
}