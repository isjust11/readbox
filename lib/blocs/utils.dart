
class BlocUtils {
  static String getMessageError(dynamic exception) {
    try {
      return exception.message;
    } catch (e) {
      return exception.toString() ;
    }
  }
}
