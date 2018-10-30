import 'package:redux/redux.dart';

import '../../model/user.dart';

import './login_action.dart';
import '../setting/logout_action.dart';
import '../personal/personal_action.dart';

/// combineReducers 与react中的不同，在子模块执行，用于隐射action-action操作函数
/// TypedReducer 相当于if (action.type === UserStartLoginAction)
final userStateReducer = combineReducers<LoginUser>([
  /// TypedReducer 将 _startLogin 包装成具有两个传入参数的新函数
  TypedReducer<LoginUser, UserStartLoginAction>(_startLogin),
  TypedReducer<LoginUser, UserFinishLoginAction>(_finishLogin),
  TypedReducer<LoginUser, UserAuthSuccessAction>(_successAuth),
  TypedReducer<LoginUser, UserLoginSuccessAction>(_successLogin),
  TypedReducer<LoginUser, UserLoginFailAction>(_failLogin),
  TypedReducer<LoginUser, UserLogoutAction>(_successLogout),
  TypedReducer<LoginUser, UserChangePhotoUrlAction>(_successChangePhotoUrl),
  TypedReducer<LoginUser, UserSwitchLanguage>(_successSwitchLanguage),
]);

LoginUser _startLogin(LoginUser user, UserStartLoginAction action) {
  LoginUser _newUser = user.copyMe();
  _newUser.isLoading = true;

  return _newUser;
}

LoginUser _finishLogin(LoginUser user, UserFinishLoginAction action) {
  LoginUser _newUser = user.copyMe();
  _newUser.isLoading = false;

  return _newUser;
}

LoginUser _successAuth(LoginUser user, UserAuthSuccessAction action) {
  return new LoginUser(
      accessToken: action.accessToken,
      refreshToken: action.refreshToken
  );
}

LoginUser _successLogin(LoginUser user, UserLoginSuccessAction action) {
  return action.user;
}

LoginUser _failLogin(LoginUser user, UserLoginFailAction action) {
  LoginUser _newUser = user.copyMe();
  _newUser.errorMsg = action.errorMsg;

  return _newUser;
}

LoginUser _successLogout(LoginUser user, UserLogoutAction action) {
  return new LoginUser();
}

LoginUser _successChangePhotoUrl(LoginUser user, UserChangePhotoUrlAction action) {
  LoginUser _newUser = user.copyMe();
  _newUser.photoUrl = action.newPhotoUrl;

  return _newUser;
}

LoginUser _successSwitchLanguage(LoginUser user, UserSwitchLanguage action) {
  LoginUser _newUser = user.copyMe();
  _newUser.locale = action.lg;

  return _newUser;
}