import 'base_entity.dart';

class UserEntity extends BaseEntity {
  String? token;
  String? userName;
  int? age;
  String? address;
  String? message;
  String? name;
  String? email;
  @override
  UserEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    userName = json['userName'];
    age = json['age'];
    address = json['address'];
    message = json['message'];
    name = json['name'];
    email = json['email'];
    token = json['token'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['age'] = age;
    data['address'] = address;
    data['message'] = message;
    data['token'] = token;
    data['name'] = name;
    data['email'] = email;
    return data;
  }
}
