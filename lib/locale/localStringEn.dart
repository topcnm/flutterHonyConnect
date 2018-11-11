import './localStringBase.dart';

/// 【第一步】继承抽象类，并给内部的属性赋值
/// 【说明】此步骤非必要，也可以直接将多国语言定义成字段一致的多个类；
class LocalStringEn extends LocalStringBase {
  @override
  String loginButtonText = "Login";
  @override
  String newsIndexTitle = "News";
  @override
  String newsDetailTitle = "News Details";
  @override
  String investIndexTitle = "Investments";
  @override
  String mineTitle = "Mine";

  @override
  String settingTitle = "Setting";
  @override
  String settingVersion = "Version";
  @override
  String settingLanguage = "Setting Language";
  @override
  String settingLogout = "Logout";
  @override
  String settingChinese = "Chinese";
  @override
  String settingEnglish = "English";
}