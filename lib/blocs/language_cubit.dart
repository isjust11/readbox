import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/utils/shared_preference.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit(String language) : super(language);

  void changeLanguage(String language) async {
    await AppLocalizations.load(Locale(language));
    await SharedPreferenceUtil.setCurrentLanguage(language);
    emit(language);
  }
}
