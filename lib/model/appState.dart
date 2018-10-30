import './user.dart';

class AppState {
  static var empty = AppState(
      loginUser: new LoginUser()
  );

  /// 这是一个总的state, 但是未关联reducer
  /// loginUser作为一个子state
  /// 可以在后面继续增加多个子state, 以管理其他模块
  LoginUser loginUser;

  AppState({
    this.loginUser,
  });
}