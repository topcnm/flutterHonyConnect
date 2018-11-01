import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import './model/appState.dart';
import './reducer/appReducer.dart';

Store store = Store<AppState>(
    appReducer,
    initialState: AppState.empty,
    middleware: [thunkMiddleware]
);