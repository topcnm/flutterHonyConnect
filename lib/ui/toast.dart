import 'package:fluttertoast/fluttertoast.dart';

void showErrorToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      bgcolor: "#fdfa90",
      textcolor: '#d60000'
  );
}
