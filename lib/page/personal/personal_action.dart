import 'dart:convert';
import '../../model/appState.dart';
import '../../constant/http.dart';

import 'package:http/http.dart' as http;

import 'package:redux/redux.dart';


final Function updateUserPhoto = ({ String photoUrl, Function callback }) {
  return (Store<AppState> store) async {
    String accessToken = store.state.loginUser.accessToken;
    String refreshToken = store.state.loginUser.refreshToken;
    String userId = store.state.loginUser.userId;
    http.Response updateRes = await _updateUserPhoto(accessToken, refreshToken, photoUrl, userId);
    Map<String, dynamic> updateResData = jsonDecode(updateRes.body);
    if (updateResData['success'] != true) {
      return callback(false);
    }
    store.dispatch(UserChangePhotoUrlAction(photoUrl));
    callback(true);
  };
};

class UserChangePhotoUrlAction {
  final String newPhotoUrl;

  UserChangePhotoUrlAction(this.newPhotoUrl);
}

final Function _updateUserPhoto = (String accessToken, String refreshToken, String photoUrl, userId) async {
  http.Response uploadPhotoResponse = await http.post(
    Uri.encodeFull('$urlHost/ucm/user/updateUserPhoto'),
    body: jsonEncode({
      "photoName": photoUrl,
      "userId": userId
    }),
    headers: {
      "Accept": "application/json, application/x-www-form-urlencoded",
      "Authorization": 'bearer $accessToken',
      "Cookie": 'refreshToken=$refreshToken accessToken=$accessToken',
      "content-type": 'application/json',
    },
  );
  return uploadPhotoResponse;
};
