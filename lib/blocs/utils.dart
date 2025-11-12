import 'package:readbox/gen/i18n/generated_locales/l10n.dart';

class BlocUtils {
  static String getMessageError(dynamic exception) {
    return exception?.toString() ?? AppLocalizations.current.error_common;
  }
}
