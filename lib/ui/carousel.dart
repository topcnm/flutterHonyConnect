import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

/*
* 图片对象的基本要素：
*   id: 用于后续跳转
*   url: 用于图片显示
*   title：备注
*
* */
class PictureItem {
  final String url;
  final String id;
  final String title;

  PictureItem({
    @required this.url,
    @required this.id,
    @required this.title
  });
}


class HonyCarousel extends StatefulWidget {
  final List<PictureItem> images;
  final bool isNetworkImage;
  final Curve animationCurve;
  final Duration animationDuration;
  final double dotSize;
  final double dotIncreaseSize;
  final BoxFit boxFit;
  final bool autoplay;
  final Duration autoplayDuration;
  final Function onTapImage;
  final double dotSpacing;

  HonyCarousel({
    this.images,
    this.isNetworkImage = true,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.dotSize = 8.0,
    this.dotIncreaseSize = 2.0,
    this.dotSpacing = 25.0,
    this.boxFit = BoxFit.cover,
    this.autoplay = true,
    this.autoplayDuration = const Duration(seconds: 3),
    this.onTapImage
  });

  @override
  _HonyCarouselState createState() => _HonyCarouselState();
}

class _HonyCarouselState extends State<HonyCarousel> {
  PageController _controller = new PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.autoplay) {
      new Timer.periodic(widget.autoplayDuration, (_) {
        // to avoid page.empty error
        // like react, we do not want to render dom after the parent component unmounted!
        if (!_controller.hasClients) {
          return null;
        }
        if(_controller.page == widget.images.length - 1) {
          _controller.animateToPage(
              0,
              duration: widget.animationDuration,
              curve: widget.animationCurve
          );
        } else {
          _controller.nextPage(
            duration: widget.animationDuration,
            curve: widget.animationCurve
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listImages = widget.images.map((netImage) {
      return new GestureDetector(
        onTap: () {
          widget.onTapImage(netImage);
        },
        child: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              fit: widget.boxFit,
              image: widget.isNetworkImage ?
                new NetworkImage(netImage.url)
                :
                new AssetImage(netImage.url)
            )
          ),
        ),
      );
    }).toList();

    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new Container(
            child: new PageView(
              physics: new AlwaysScrollableScrollPhysics(),
              controller: _controller,
              children: listImages,
            ),
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('lib/images/hony-placeholder.jpg'),
                fit: BoxFit.cover
              ),
            ),
          ),
          new Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: new Container(
              padding: new EdgeInsets.all(10.0),
              child: new Center(
                child: new HonyDotShower(
                  controller: _controller,
                  itemCount: listImages.length,
                  dotSize: widget.dotSize,
                  dotSpacing: widget.dotSpacing,
                  dotIncreaseSize: widget.dotIncreaseSize,
                  onPageSelected: (int pageIndex) {
                    _controller.animateToPage(
                      pageIndex,
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                    );
                  },
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}

class HonyDotShower extends AnimatedWidget {
  HonyDotShower({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.dotSize,
    this.dotIncreaseSize,
    this.dotSpacing
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final double dotSize;
  final double dotIncreaseSize;
  final double dotSpacing;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (dotIncreaseSize - 1.0) * selectedness;
    return new Container(
      width: dotSpacing,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: dotSize * zoom,
            height: dotSize * zoom,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
