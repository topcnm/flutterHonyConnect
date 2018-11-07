import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class PendingOverlay extends StatefulWidget {
  final String _text;
  final Function _onTap;

  PendingOverlay(this._text, this._onTap);

  @override
  State<StatefulWidget> createState() => new PendingOverlayState();
}

class PendingOverlayState extends State<PendingOverlay> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this,
        duration: new Duration(seconds: 2)
    );
    _animation = new CurvedAnimation(
        parent: _controller,
        curve: Curves.linear
    );
    _animation.addListener((){
      this.setState((){});
    });
    _controller.repeat();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.transparent,
      child: new InkWell(
        splashColor: Colors.transparent,
        onTap: widget._onTap,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                color: Colors.black54,
                borderRadius: new BorderRadius.all(
                    new Radius.circular(ScreenUtil().setWidth(16))
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(50),
              ),
              width: ScreenUtil().setWidth(250),
              height: ScreenUtil().setWidth(255),
              child: new Column(
                children: <Widget>[
                  new Text(
                      widget._text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                      new TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setWidth(28)
                      )
                  ),
                  new Padding(padding: EdgeInsets.only(top: ScreenUtil().setWidth(30))),
                  new Container(
                    child: new Transform.rotate(
                      angle: - _animation.value * 2 * pi,
                      child: new Icon(
                        Icons.loop,
                        color: Colors.grey,
                        size: ScreenUtil().setWidth(90),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


