// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  Authorization? authorization;
  String? type;

  LoginModel({this.authorization, this.type});

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    authorization: json["authorization"] == null
        ? null
        : Authorization.fromJson(json["authorization"]),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "authorization": authorization?.toJson(),
    "type": type,
  };
}

class Authorization {
  String? type;
  String? accessToken;
  String? refreshToken;

  Authorization({this.type, this.accessToken, this.refreshToken});

  factory Authorization.fromJson(Map<String, dynamic> json) => Authorization(
    type: json["type"],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "access_token": accessToken,
    "refresh_token": refreshToken,
  };
}
