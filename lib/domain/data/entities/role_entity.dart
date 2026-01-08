
import 'base_entity.dart';

class RoleEntity extends BaseEntity {
  String? name = '';
  String? code = '';
  String? description;


  @override
  RoleEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    name = json['name'];
    code = json['code'];
    description = json['description'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['description'] = description;
    return data;
  }
}
