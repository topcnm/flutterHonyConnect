import 'dart:ui';
import 'package:flutter/material.dart';
import './localStringBase.dart';
import './localStringZh.dart';
import './localStringEn.dart';

///【第二步】基本语言库：完成多国语言的核心功能
/// 1，接收外部传入的 Locale对象
/// 2，定义可支持的语言类型
/// 3，定义根据语言code 映射字库的方法【待验证其必要性】
/// 4，实现of方法【待验证其必要性】
class HonyLocalization {
  final Locale locale;

  HonyLocalization(this.locale);

  static Map<String, LocalStringBase> _localizedValues = {
    'en': new LocalStringEn(),
    'zh': new LocalStringZh()
  };

  LocalStringBase get currentLocalied {
    return _localizedValues[locale.languageCode];
  }

  // 通过Localizations 加载当前的 HonyLocalization，获取对应的LocalStringBase
  static HonyLocalization of(BuildContext context) {
    return Localizations.of(context, HonyLocalization);
  }
}


