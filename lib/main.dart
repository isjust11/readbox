import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/language_cubit.dart';
import 'package:readbox/blocs/book_refresh/book_refresh_cubit.dart';
import 'package:readbox/blocs/theme_cubit.dart';
import 'package:readbox/blocs/user_interaction_cubit.dart';
import 'package:readbox/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:readbox/services/fcm_service.dart';
import 'domain/repositories/user_interaction_repository.dart';
import 'injection_container.dart' as di;
import 'ui/app.dart';
import 'utils/shared_preference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
   // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  String language = await SharedPreferenceUtil.getCurrentLanguage();
  String theme = await SharedPreferenceUtil.getTheme();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(
      create: (_) => LanguageCubit(language),
    ),
    BlocProvider(
      create: (_) => BookRefreshCubit(),
    ),
    BlocProvider(
      create: (_) => ThemeCubit(theme),
    ),
    BlocProvider(
      create: (_) => UserInteractionCubit(repository: di.getIt<UserInteractionRepository>()),
    ),
  ], child: MyApp()));
}
