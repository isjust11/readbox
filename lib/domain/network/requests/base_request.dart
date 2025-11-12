import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class BaseParamRequest {
  static Map<String, dynamic> request(map) {
    if (map == null) {
      map = Map<String, dynamic>();
    }
    var partner = "";
    if (Platform.isIOS) {
      partner = "ios";
    } else if (Platform.isAndroid) {
      partner = "android";
    }
    map["partner"] = partner;
    map["signature"] = "";
    debugPrint("==Network ParamRequest =====${json.encode(map)}");
    return map;
  }
}
