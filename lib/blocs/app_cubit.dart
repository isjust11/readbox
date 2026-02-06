import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/utils/shared_preference.dart';

class AppCubit extends Cubit<String> {
  UserModel? user;
  AppCubit(super.language);

  void setUser(UserModel user) {
    this.user = user;
  }

  UserModel? getUser() {
   return user;
  }

  void changeLanguage(String language) async {
    await AppLocalizations.load(Locale(language));
    await SharedPreferenceUtil.setCurrentLanguage(language);
    emit(language);
  }
}
