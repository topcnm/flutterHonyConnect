import '../model/appState.dart';
import '../page/login/login_reducer.dart';
import '../page/language/language-redux.dart';

AppState appReducer(AppState state, action) {
  /// 这里是state 与 reducer 隐射逻辑
  /// 可以在下面增加更多映射
  return AppState(
    loginUser: userStateReducer(state.loginUser, action),

    /// 【第七步】在总reducer中，注册好关于语言库的子reducer
    locale: LocaleReducer(state.locale, action),
  );
}