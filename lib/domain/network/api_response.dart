class ApiResponse<T> {
  int? code;
  T? data;
  int? status;
  String errMessage;

  ApiResponse.success({this.data, this.code, this.status, this.errMessage = ""});

  ApiResponse.error(this.errMessage, {this.data, this.code});

  bool get isSuccess => code != null && code == 200;

  bool get isStatusSuccess => status == 200;
}
