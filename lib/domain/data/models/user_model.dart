import 'package:readbox/domain/data/entities/entities.dart';

class UserModel extends UserEntity {

  UserModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);
  UserModel.simpleFromJson(Map<String, dynamic> json) : super.simpleFromJson(json);
  get getSortName {
    int length = username?.length ?? 0;
    if (length <= 1) {
      return username ?? "";
    } else {
      return "${username![0]}${username![length - 1]}";
    }
  }
}
