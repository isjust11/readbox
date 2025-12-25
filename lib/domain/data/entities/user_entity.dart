import 'base_entity.dart';

class UserEntity extends BaseEntity {
  String? id;
  String? username;
  String? email;
  String? fullName;
  String? picture;
  String? platformId;
  String? phoneNumber;
  String? address;
  String? birthDate;
  String? facebookLink;
  String? instagramLink;
  String? twitterLink;
  String? linkedinLink;
  String? lastLogin;

  @override
  UserEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    fullName = json['fullName'];
    picture = json['picture'];
    platformId = json['platformId'];
    phoneNumber = json['phoneNumber'];
    address = json['address'];
    birthDate = json['birthDate'];
    facebookLink = json['facebookLink'];
    instagramLink = json['instagramLink'];
    twitterLink = json['twitterLink'];
    linkedinLink = json['linkedinLink'];
    lastLogin = json['lastLogin'];
    address = json['address'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['fullName'] = fullName;
    data['picture'] = picture;
    data['platformId'] = platformId;
    data['phoneNumber'] = phoneNumber;
    data['address'] = address;
    data['birthDate'] = birthDate;
    data['facebookLink'] = facebookLink;
    data['instagramLink'] = instagramLink;
    data['twitterLink'] = twitterLink;
    data['linkedinLink'] = linkedinLink;
    data['lastLogin'] = lastLogin;
    return data;
  }
}
