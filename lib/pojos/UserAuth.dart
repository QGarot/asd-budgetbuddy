class UserAuth {
  final String? uid;
  final String? email;
  UserAuth({this.uid, this.email});
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
