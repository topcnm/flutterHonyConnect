import 'package:flutter/material.dart';
import '../helper/pixelCompact.dart';
import '../constant/sizes.dart';
import '../constant/colors.dart';

class CombineIconInput extends StatefulWidget {
  final IconData _icon;
  final TextInputType inputType;
  final String placeHolder;
  final Function _onChange;
  final bool hasEye;

  CombineIconInput(
      @required this._icon,
      @required this._onChange,
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

class _CombineIconInputState extends State<CombineIconInput> implements PixelCompactMixin{
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

  @override
  double getWidth(double num, double winWidth) {
    return winWidth * num / standardWidth;
  }

  void toggleEye() {
    setState(() {
      eyeOpen = !eyeOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    double winWidth = MediaQuery.of(context).size.width;
    Widget eyeWidget = widget.hasEye ? new IconButton(
      icon: !eyeOpen ? 
        new Icon(IconData(0xe600, fontFamily: 'aliFont')) 
        : 
        new Icon(IconData(0xe69c, fontFamily: 'aliFont')),
      iconSize: getWidth(40.0, winWidth),
      color: primaryColor,
      onPressed: toggleEye,
    ): new Container();

    return new Container(
      padding: EdgeInsets.symmetric(vertical: getWidth(20.0, winWidth)),
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: primaryColor, width: getWidth(2.0, winWidth)))
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Icon(
            widget._icon,
            color: primaryColor,
            size: getWidth(40.0, winWidth),
          ),
          new Padding(
              padding: EdgeInsets.only(
                  right: getWidth(20.0, winWidth)
              )
          ),
          new Expanded(
            child: new TextField(
              style: new TextStyle(
                fontSize: getWidth(30.0, winWidth),
                color: mainFontColor,
              ),
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: widget.placeHolder,
                hintStyle: new TextStyle(
                    fontSize: getWidth(30.0, winWidth),
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