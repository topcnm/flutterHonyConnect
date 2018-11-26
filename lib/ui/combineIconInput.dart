import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/colors.dart';

class CombineIconInput extends StatefulWidget {
  final IconData _icon;
  final TextInputType inputType;
  final String placeHolder;
  final Function _onChange;
  final bool hasEye;

  CombineIconInput(
      this._icon,
      this._onChange,
      {
        Key key,
        this.hasEye = false,
        this.placeHolder = 'Place Sample',
        this.inputType = TextInputType.text
      }
    );

  @override
  State<StatefulWidget> createState() => new _CombineIconInputState();
}

class _CombineIconInputState extends State<CombineIconInput> {
  bool eyeOpen = false;
  String inputContent = '';

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

  void toggleEye() {
    setState(() {
      eyeOpen = !eyeOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget eyeWidget = widget.hasEye ? new IconButton(
      icon: !eyeOpen ? 
        new Icon(IconData(0xe600, fontFamily: 'aliFont')) 
        : 
        new Icon(IconData(0xe69c, fontFamily: 'aliFont')),
      iconSize: ScreenUtil().setWidth(40),
      color: primaryColor,
      onPressed: toggleEye,
    ): new Container();

    return new Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: primaryColor, width: ScreenUtil().setWidth(2)))
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Icon(
            widget._icon,
            color: primaryColor,
            size: ScreenUtil().setWidth(40),
          ),
          new Padding(
              padding: EdgeInsets.only(
                  right: ScreenUtil().setWidth(20)
              )
          ),
          new Expanded(
            child: new TextField(
              style: new TextStyle(
                fontSize: ScreenUtil().setWidth(26),
                color: mainFontColor,
                height: 0.85,
              ),
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: widget.placeHolder,
                hintStyle: new TextStyle(
                    fontSize: ScreenUtil().setWidth(30),
                    color: assistFontColor
                ),
              ),
              keyboardType: widget.inputType,
              obscureText: widget.hasEye && !eyeOpen,
              onChanged: (String str){
                setState(() {
                  inputContent = str;
                  widget._onChange(str);
                });
              },
            ),
          ),
          eyeWidget
        ],
      ),
    );
  }
}