import 'package:meta/meta.dart';

enum ProductType {
  PRODTP_PE,
  PRODTP_PI,
  PRODTP_HF,
  PRODTP_RE,
}

class ProductItem {
  final String cntntId;
  final String productId;
  final ProductType productType;
  final String topic;
  final String rlsTime;
  final String keyWord;

  ProductItem({
    @required this.cntntId,
    @required this.productId,
    this.productType = ProductType.PRODTP_PE,
    this.topic = '',
    this.rlsTime,
    this.keyWord = ''
  });
}