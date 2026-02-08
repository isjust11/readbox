import 'package:intl/intl.dart';
import 'package:readbox/domain/data/entities/entities.dart';


class UserEntity extends BaseEntity {
  String? id;
  String? username;
  bool? isAdmin;
  bool? isBlock;
  String? fullName;
  String? phoneNumber;
  String? address;
  String? birthDate;
  String? facebookLink;
  String? instagramLink;
  String? twitterLink;
  String? linkedinLink;
  String? picture;

  /// Get converted picture URL for Flutter
  List<RoleEntity> roles = [];
  List<dynamic> permissions = [];
  String? email;
  String? platformId;
  String? verificationToken;
  String? pinCode;
  String? pinExpiresAt;
  String? lastLogin;
  String? createdAt;
  String? updatedAt;

  bool? isFacebookUser;
  bool? isGoogleUser;
  bool? isAppleUser;

  

  UserEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json['id'].toString();
    username = json['username'];
    isAdmin = json['isAdmin'];
    isBlock = json['isBlock'];
    fullName = json['fullName'];
    picture = json['picture'];
    roles = json['roles'] != null ? (json['roles'] as List)
          .map((role) => RoleEntity.fromJson(role as Map<String, dynamic>))
          .toList()
        : [];
    permissions = json['permissions'] ?? [];
    email = json['email'];
    platformId = json['platformId'];
    verificationToken = json['verificationToken'];
    pinCode = json['pinCode'];
    pinExpiresAt = json['pinExpiresAt'];
    lastLogin = json['lastLogin'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    phoneNumber = json['phoneNumber'];
    address = json['address'];
    birthDate = convertBirthDate(json['birthDate']);
    facebookLink = json['facebookLink'];
    instagramLink = json['instagramLink'];
    twitterLink = json['twitterLink'];
    linkedinLink = json['linkedinLink'];
    isGoogleUser = json['isGoogleUser'];
    isFacebookUser = json['isFacebookUser'];
    isAppleUser = json['isAppleUser'];
  }

  UserEntity.simpleFromJson(Map<String, dynamic> json) : super.fromJson(json) {
    username = json['username'];
    isAdmin = false;
    isBlock = false;
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    address = json['address'];
    birthDate = json['birthDate'];
    facebookLink = json['facebookLink'];
    instagramLink = json['instagramLink'];
    twitterLink = json['twitterLink'];
    linkedinLink = json['linkedinLink'];
    picture = json['picture'];
    email = json['email'];

    isGoogleUser = json['isGoogleUser'];
    isFacebookUser = json['isFacebookUser'];
    isAppleUser = json['isAppleUser'];
  }
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['username'] = username;
    data['isAdmin'] = isAdmin;
    data['isBlock'] = isBlock;
    data['fullName'] = fullName;
    data['picture'] = picture;
    data['roles'] = roles.map((role) => role.toJson()).toList();
    data['permissions'] = permissions;
    data['email'] = email;
    data['platformId'] = platformId;
    data['verificationToken'] = verificationToken;
    data['pinCode'] = pinCode;
    data['pinExpiresAt'] = pinExpiresAt;
    data['lastLogin'] = lastLogin;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['phoneNumber'] = phoneNumber;
    data['address'] = address;
    data['birthDate'] = birthDate;
    data['facebookLink'] = facebookLink;
    data['instagramLink'] = instagramLink;
    data['twitterLink'] = twitterLink;
    data['linkedinLink'] = linkedinLink;
    data['isAppleUser'] = isAppleUser;
    data['isFacebookUser'] = isFacebookUser;
    data['isGoogleUser'] = isGoogleUser;

    return data;
  }

  bool get isSocialPlatform {
    return (isAppleUser == true ||
        isGoogleUser == true ||
        isFacebookUser == true);
  }

  String convertBirthDate(String? birthDate) {
    try {
      if (birthDate == null) {
        return '';
      }
      final date = DateTime.parse(birthDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }
}
