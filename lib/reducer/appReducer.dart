import '../model/appState.dart';
import '../page/login/login_reducer.dart';


AppState appReducer(AppState state, action) {
  return AppState(
    loginUser: userStateReducer(state.loginUser, action)
  );
}