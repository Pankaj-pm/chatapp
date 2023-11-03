import 'dart:convert';

class MyUser {
  String? email;
  String? userName;
  String? profile;
  int? loginCount;

  MyUser({
    this.email,
    this.userName,
    this.profile,
    this.loginCount,
  });

  factory MyUser.fromRawJson(String str) => MyUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyUser.fromJson(Map<String, dynamic> json) => MyUser(
    email: json["email"],
    userName: json["userName"],
    profile: json["profile"],
    loginCount: json["loginCount"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "userName": userName,
    "profile": profile,
    "loginCount": loginCount,
  };
}
