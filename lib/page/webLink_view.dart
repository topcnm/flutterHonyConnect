import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebLinkPage extends StatefulWidget {
  final String url;
  WebLinkPage(this.url);

  @override
  WebLinkPageState createState() => new WebLinkPageState();
}


class WebLinkPageState extends State<WebLinkPage> {
  bool isLoading = true;
  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flutterWebViewPlugin.onStateChanged.listen((state) {
      if (state.type == WebViewState.finishLoad) {
        // 加载完成
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url: widget.url,
      appBar: new AppBar(
        title: new Text("外部资讯详情"),
        centerTitle: !isLoading,
      ),
      withZoom: false,
      withLocalStorage: true,
      withJavascript: true,
    );
  }
}
