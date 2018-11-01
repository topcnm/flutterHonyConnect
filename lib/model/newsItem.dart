import 'package:meta/meta.dart';

class NewsItem {
  final String cntntId;
  final String topic;
  final String focusImgUrl;
  final String rlsTime;
  final String cntntType;
  final bool cntntFlg;
  final String webLink;

  NewsItem({
    @required this.cntntId,
    @required this.topic,
    @required this.focusImgUrl,
    @required this.rlsTime,
    this.cntntType,
    this.cntntFlg = false,
    this.webLink = '',
  });
}