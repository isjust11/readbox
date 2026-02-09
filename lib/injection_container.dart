import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/network/network.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
/*
Factory — Creates a new instance in every call
Singleton — Creates only one instance and reuses it every call

Register
Instance will be created as soon as registered, call of [get]
      getIt.registerSingleton(Network.instance());
      getIt.registerFactory(() => Network.instance());

lazyRegister
An instance will only be created when It’s called for the first time
     getIt.registerLazySingleton(() => Network.instance());

registerAsync
register class with async operator and create it
    getIt.registerSingletonAsync(() async {
      return await Network.instance();
    });
User
    Network network = getIt.get();
   // or
  Network network = getIt.get<Network>();

*/
Future<void> init({GetIt? getIt}) async {
  getIt ??= GetIt.instance;
  // network
  registerNetwork(getIt);
  // data source
  registerDataSource(getIt);
  // repositories
  registerRepositories(getIt);
  // bloc cubit
  registerCubit(getIt);
}

void registerCubit(GetIt getIt) {
  getIt.registerLazySingleton(
    () => UserInfoCubit(repository: getIt.get<UserRepository>()),
  );
  getIt.registerFactory(
    () => AuthCubit(repository: getIt.get<AuthRepository>()),
  );
  getIt.registerFactory(
    () => LibraryCubit(
      repository: getIt.get<BookRepository>(),
      adminRemoteDataSource: getIt.get<AdminRemoteDataSource>(),
    ),
  );
  getIt.registerFactory(
    () => BookDetailCubit(repository: getIt.get<BookRepository>()),
  );
  getIt.registerFactory(
    () => AdminCubit(getIt.get<AdminRemoteDataSource>()),
  );
  getIt.registerFactory(
    () => MediaCubit(repository: getIt.get<MediaRepository>()),
  );
  getIt.registerFactory(
    () => PageCubit(repository: getIt.get<PageRepository>()),
  );
  getIt.registerFactory(
    () => FeedbackCubit(repository: getIt.get<FeedbackRepository>()),
  );
  getIt.registerFactory(
    () => NotificationCubit(notificationRepository: getIt.get<NotificationRepository>()),
  );
  getIt.registerFactory(
    () => UserInteractionCubit(repository: getIt.get<UserInteractionRepository>()),
  );
  getIt.registerFactory(
    () => CategoryCubit(repository: getIt.get<CategoryRepository>()),
  );
  getIt.registerFactory(
    () => ConverterCubit(getIt.get<ConverterRemoteDataSource>()),
  );
}

void registerRepositories(GetIt getIt) {
  getIt.registerLazySingleton(
    () => AuthRepository(remoteDataSource: getIt.get(), localDataSource: getIt.get()),
  );
  getIt.registerLazySingleton(
    () => UserRepository(
      userLocalDataSource: getIt.get(),
      userRemoteDataSource: getIt.get(),
    ),
  );
  getIt.registerLazySingleton(
    () => BookRepository(remoteDataSource: getIt.get<BookRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => MediaRepository(remoteDataSource: getIt.get<MediaRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => PageRepository(pageRemoteDataSource: getIt.get<PageRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => FeedbackRepository(remoteDataSource: getIt.get<FeedbackRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => NotificationRepository(remoteDataSource: getIt.get<NotificationRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => UserInteractionRepository(remoteDataSource: getIt.get<UserInteractionRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => CategoryRepository(remoteDataSource: getIt.get<CategoryRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => SubscriptionRepository(remoteDataSource: getIt.get<SubscriptionRemoteDataSource>()),
  );
  getIt.registerLazySingleton(
    () => PaymentRepository(remoteDataSource: getIt.get<PaymentRemoteDataSource>()),
  );
}


void registerDataSource(GetIt getIt) {
  getIt.registerLazySingleton(() => AuthRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => UserLocalDataSource());
  getIt.registerLazySingleton(() => UserRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => BookRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => AdminRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => MediaRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => PageRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => FeedbackRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => NotificationRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => UserInteractionRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => CategoryRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => ConverterRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => SubscriptionRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => PaymentRemoteDataSource(network: getIt.get()));
}

void registerNetwork(GetIt getIt) {
  getIt.registerLazySingleton(() => Network.instance());
}
