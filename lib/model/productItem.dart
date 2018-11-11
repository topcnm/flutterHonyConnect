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

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return new ProductItem(
        cntntId: json['cntntId'],
        productId: json['productId'],
        topic: json['topic'],
        rlsTime: json['rlsTime'] == null ? "" : json['rlsTime'],
        keyWord: json['keyWord'],
        productType: ProductItem.productTypeFromString(json['productType']),
    );
  }

  static ProductType productTypeFromString(String _productType) {
    ProductType validProductType;

    switch (_productType) {
      case "PRODTP_RE": validProductType = ProductType.PRODTP_RE; break;
      case "PRODTP_PE": validProductType = ProductType.PRODTP_PE; break;
      case "PRODTP_HF": validProductType = ProductType.PRODTP_HF; break;
      default:
        validProductType = ProductType.PRODTP_PI;
    }

    return validProductType;
  }
}