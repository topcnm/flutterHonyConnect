import 'dart:async';

import '../locale/honyLocalization.dart';
import '../locale/localStringBase.dart';

class LocaleUtils {
  /// 【第五步】新建一个类，抽象出访问语言库的方法，防止在页面代码中出现；
  static LocalStringBase getLocale(context) {
    return HonyLocalization.of(context).currentLocalied;
  }
}