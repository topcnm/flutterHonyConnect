import './user.dart';

class AppState {
  static var empty = AppState(
      loginUser: new LoginUser()
  );

  LoginUser loginUser;

  AppState({
    this.loginUser,
  });
}