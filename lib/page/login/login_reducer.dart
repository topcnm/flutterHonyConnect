import 'package:redux/redux.dart';
import './login_action.dart';
import '../../model/user.dart';

final userStateReducer = combineReducers<LoginUser>([
  TypedReducer<LoginUser, UserStartLoginAction>(_startLogin),
  TypedReducer<LoginUser, UserFinishLoginAction>(_finishLogin),
  TypedReducer<LoginUser, UserAuthSuccessAction>(_successAuth),
  TypedReducer<LoginUser, UserLoginSuccessAction>(_successLogin),
  TypedReducer<LoginUser, UserLoginFailAction>(_failLogin),
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