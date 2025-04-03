class AuthUserData {
  final String? uid;
  final String? email;
  final String? username;
  AuthUserData({this.uid, this.email, this.username});
}

class UserRegistrationInfo {
  final String email;
  final String userName;
  final String password;
  UserRegistrationInfo({
    required this.email,
    required this.userName,
    required this.password,
  });
}

class UserLoginInfo {
  final String email;
  final String password;
  UserLoginInfo({required this.email, required this.password});
}
