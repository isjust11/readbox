import 'base_entity.dart';

class UserEntity extends BaseEntity {
  String? userName;
  int? age;
  String? address;

  @override
  UserEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    userName = json['userName'];
    age = json['age'];
    address = json['address'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['age'] = this.age;
    data['address'] = this.address;
    return data;
  }
}
