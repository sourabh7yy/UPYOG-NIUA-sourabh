import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

class IntToStringConverter implements JsonConverter<String?, Object?> {
  const IntToStringConverter();

  @override
  String? fromJson(Object? json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is int) return json.toString();
    return json.toString();
  }

  @override
  Object? toJson(String? object) => object;
}

@JsonSerializable()
class Token {
  @JsonKey(name: 'access_token')
  String? accessToken;
  @JsonKey(name: 'token_type')
  String? tokenType;
  @JsonKey(name: 'refresh_token')
  String? refreshToken;
  @JsonKey(name: 'expires_in')
  int? expiresIn;
  @JsonKey(name: 'scope')
  String? scope;
  @JsonKey(name: 'ResponseInfo')
  ResponseInfo? responseInfo;
  @JsonKey(name: 'UserRequest')
  UserRequest? userRequest;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable()
class ResponseInfo {
  @IntToStringConverter()
  @JsonKey(name: 'api_id')
  String? apiId;
  @IntToStringConverter()
  @JsonKey(name: 'ver')
  String? ver;
  @IntToStringConverter()
  @JsonKey(name: 'ts')
  String? ts;
  @IntToStringConverter()
  @JsonKey(name: 'res_msg_id')
  String? resMsgId;
  @IntToStringConverter()
  @JsonKey(name: 'msg_id')
  String? msgId;
  @IntToStringConverter()
  @JsonKey(name: 'status')
  String? status;

  ResponseInfo();

  factory ResponseInfo.fromJson(Map<String, dynamic> json) =>
      _$ResponseInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseInfoToJson(this);
}

@JsonSerializable()
class UserRequest {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'uuid')
  String? uuid;
  @JsonKey(name: 'userName')
  String? userName;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'mobileNumber')
  String? mobileNumber;
  @JsonKey(name: 'emailId')
  String? emailId;
  @JsonKey(name: 'locale')
  String? locale;
  @JsonKey(name: 'type')
  String? type;
  @JsonKey(name: 'roles')
  List<Role>? roles;
  @JsonKey(name: 'active')
  bool? active;
  @JsonKey(name: 'tenantId')
  String? tenantId;
  @JsonKey(name: 'permanentCity')
  String? permanentCity;
  @JsonKey(name: 'photo')
  String? photo;
  @JsonKey(name: 'dob')
  String? dob;
  @JsonKey(name: 'gender')
  String? gender;

  UserRequest();

  factory UserRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserRequestToJson(this);
}

@JsonSerializable()
class Role {
  @JsonKey(name: 'id', includeFromJson: false)
  int? id;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'code')
  String? code;
  @JsonKey(name: 'tenantId')
  String? tenantId;

  Role();

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
