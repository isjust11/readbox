import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/network/network.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/usecases/add_book_usecase.dart';
import 'package:readbox/domain/usecases/get_book_list_usecase.dart';
import 'package:readbox/domain/usecases/delete_book_usecase.dart';
import 'package:readbox/domain/usecases/search_books_usecase.dart';
import 'package:readbox/domain/usecases/save_reading_progress_usecase.dart';
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
  // use cases
  registerUseCases(getIt);
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
      getBookListUseCase: getIt.get<GetBookListUseCase>(),
      addBookUseCase: getIt.get<AddBookUseCase>(),
      deleteBookUseCase: getIt.get<DeleteBookUseCase>(),
      searchBooksUseCase: getIt.get<SearchBooksUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => BookDetailCubit(repository: getIt.get<BookRepository>()),
  );
  getIt.registerFactory(
    () => AdminCubit(getIt.get<AdminRemoteDataSource>()),
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
}

void registerUseCases(GetIt getIt) {
  getIt.registerLazySingleton(() => GetBookListUseCase(getIt.get<BookRepository>()));
  getIt.registerLazySingleton(() => AddBookUseCase(getIt.get<BookRepository>()));
  getIt.registerLazySingleton(() => DeleteBookUseCase(getIt.get<BookRepository>()));
  getIt.registerLazySingleton(() => SearchBooksUseCase(getIt.get<BookRepository>()));
  getIt.registerLazySingleton(() => SaveReadingProgressUseCase(getIt.get<BookRepository>()));
}

void registerDataSource(GetIt getIt) {
  getIt.registerLazySingleton(() => AuthRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => UserLocalDataSource());
  getIt.registerLazySingleton(() => UserRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => BookRemoteDataSource(network: getIt.get()));
  getIt.registerLazySingleton(() => AdminRemoteDataSource(network: getIt.get()));
}

void registerNetwork(GetIt getIt) {
  getIt.registerLazySingleton(() => Network.instance());
}
