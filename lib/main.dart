import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/datasources/remote/admin_remote_data_source.dart';
import 'package:readbox/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:readbox/domain/repositories/repositories.dart';
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
    BlocProvider(
      create: (_) => NotificationCubit(notificationRepository: di.getIt<NotificationRepository>()),
    ),
    BlocProvider(
      create: (_) => CategoryCubit(repository: di.getIt<CategoryRepository>()),
    ),
    BlocProvider(
      create: (_) => LibraryCubit(
        repository: di.getIt<BookRepository>(),
        adminRemoteDataSource: di.getIt<AdminRemoteDataSource>(),
      ),
    ),
  ], child: MyApp()));
}
