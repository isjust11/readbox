import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/language_cubit.dart';
import 'package:readbox/blocs/book_refresh/book_refresh_cubit.dart';

import 'injection_container.dart' as getIt;
import 'ui/app.dart';
import 'utils/shared_preference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getIt.init();
  String language = await SharedPreferenceUtil.getCurrentLanguage();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(
      create: (_) => LanguageCubit(language),
    ),
    BlocProvider(
      create: (_) => BookRefreshCubit(),
    ),
  ], child: MyApp()));
}
