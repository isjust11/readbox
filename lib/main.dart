import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/language_cubit.dart';
import 'package:readbox/blocs/book_refresh/book_refresh_cubit.dart';
import 'package:readbox/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:readbox/services/fcm_service.dart';
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
  runApp(MultiBlocProvider(providers: [
    BlocProvider(
      create: (_) => LanguageCubit(language),
    ),
    BlocProvider(
      create: (_) => BookRefreshCubit(),
    ),
  ], child: MyApp()));
}
