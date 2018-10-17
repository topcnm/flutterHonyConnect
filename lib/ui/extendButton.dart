import 'package:flutter/material.dart';
import '../helper/pixelCompact.dart';
import '../constant/sizes.dart';
import '../constant/colors.dart';

class ExtendButton extends StatelessWidget implements PixelCompactMixin{
  final enabled;
  final String _text;
  final Function _onTap;

  ExtendButton(this._text, this.enabled, this._onTap);

  @override
  double getWidth(double num, double winWidth) {
    return winWidth * num / standardWidth;
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    return new SizedBox(
      width: double.infinity,
      child: new RaisedButton(
        padding: EdgeInsets.symmetric(vertical: getWidth(30.0, winWidth)),
        color: primaryColor,
        highlightColor: pressColor,
        disabledColor: disabledColor,
        child: new Text(
          _text,
          style: new TextStyle(
            color: Colors.white,
            fontSize: getWidth(30.0, winWidth),
          ),
        ),
        onPressed: enabled ? _onTap : null,
      ),
    );
  }
}