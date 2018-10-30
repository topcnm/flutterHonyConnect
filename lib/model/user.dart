
enum Language {
  en,
  zh
}

/// 这个对象，可以认为是子state
class LoginUser {
  //
  bool isLoading;
  String errorMsg;

  // token
  String accessToken;
  String refreshToken;
  String tokenType;

  //user info
  String userId;
  String userType;
  String username;
  String account;
  String accountId;

  //relative info
  Language locale;
  String mobile;
  String mail;
  String photoUrl;
  String name;
  String position;

  LoginUser({
    this.isLoading = false,
    this.errorMsg = '',
    // token
    this.accessToken = '',
    this.refreshToken = '',
    this.tokenType = '',

    //user info
    this.userId = '',
    this.userType = '',
    this.username = '',
    this.account = '',
    this.accountId = '',

    //relative info
    this.locale = Language.en,
    this.mobile = '',
    this.mail = '',
    this.photoUrl = '',
    this.name = '',
    this.position = '',
  });

  LoginUser copyMe() {
    return new LoginUser(
      isLoading: this.isLoading,
      errorMsg: this.errorMsg,

      accessToken: this.accessToken,
      refreshToken: this.refreshToken,
      tokenType: this.tokenType,

      userId: this.userId,
      userType: this.userType,
      username: this.username,
      account: this.account,
      accountId: this.accountId,

      locale: this.locale,
      mobile: this.mobile,
      mail: this.mail,
      photoUrl: this.photoUrl,
      name: this.name,
      position: this.position,
    );
  }
}