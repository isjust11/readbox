class FcmTokenModel {
  final String? id;
  final String? platform;
  final String? token;
  String? deviceId;
  FcmTokenModel({this.id, this.platform, this.token, this.deviceId});

  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      id: json['id'],
      token: json['token']?.toString(),
      platform: json['platform']?.toString(),
      deviceId: json['deviceId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['token'] = token;
    data['platform'] = platform;
    data['deviceId'] = deviceId;
    return data;
  }
}
