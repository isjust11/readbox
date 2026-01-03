import 'package:readbox/domain/data/entities/base_entity.dart';
import 'package:readbox/domain/data/models/user_model.dart';

class UserRegisterModel extends BaseEntity {
  String? code;
  String? message;
  UserModel? data;

  @override
  UserRegisterModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? UserModel.fromJson(json['data']) : null;
  }
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    data['data'] = this.data?.toJson();
    return data;
  }

}
