import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  String? status;
  Data? data;

  LoginResponse({this.status, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class Data {
  int? id;
  String? name;
  String? email;
  String? phone;
  @JsonKey(name: 'access_token')
  String? accessToken;

  Data({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.accessToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}
