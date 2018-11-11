import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './honyLocalization.dart';

///【第三部】定义字库代理，由于语言库对象无法主动映射到代码中，需要代理
/// 1，继承自LocalizationsDelegate
/// 2，【重写】设置支持类型，基于Locale对象的code
/// 3，【重写】设置载入方法，future范围一个HonyLocalization对象
/// 4，【重写】设置'是否需要重载'方法，默认false
/// 5，实现静态方法delegate，参照默认提供的 GlobalMaterialLocalizations 对象
class HonyLocalizationDelegate extends LocalizationsDelegate<HonyLocalization> {
  HonyLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  ///根据locale,创建一个对象用于当前locale下的文本显示
  @override
  Future<HonyLocalization> load(Locale locale) {
    return new SynchronousFuture<HonyLocalization>(new HonyLocalization(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<HonyLocalization> old) {
    return false;
  }

  static HonyLocalizationDelegate delegate = new HonyLocalizationDelegate();
}
