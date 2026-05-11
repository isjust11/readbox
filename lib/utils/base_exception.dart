class BaseException implements Exception {
  final String message;
  final String? code;
  BaseException({required this.message, this.code});

  String get getCode => code ?? '';

  @override
  String toString() => message;
}
