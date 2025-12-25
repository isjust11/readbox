import '../models/user_model.dart';
import 'base_entity.dart';
class AuthenEntity extends BaseEntity {
  String? accessToken;
  String? refreshToken;
  UserModel? user;

  @override
  AuthenEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    user = UserModel.fromJson(json['user']);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['user'] = user?.toJson();
    return data;
  }
}
