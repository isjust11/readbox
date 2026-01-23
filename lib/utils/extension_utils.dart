// extension for int to base64 decode
import 'dart:convert';

import 'package:readbox/utils/common.dart';

extension IntExtension on int {
  int toBase64Decode() {
    return int.parse(Common.base64Decode(this.toString()));
  }
}

// extension for string to base64 decode
extension StringExtension on String {
  int toBase64Decode() {
    return int.parse(Common.base64Decode(this));
  }
}