
class BlocUtils {
  static String getMessageError(dynamic exception) {
    try {
      if(exception is String) {
        return exception;
      }
      return exception?.message ?? exception.errMessage;
    } catch (e) {
      return exception.toString() ;
    }
  }
}
