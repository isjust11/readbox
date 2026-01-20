import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class CategoryCubit extends Cubit<BaseState> {
  final CategoryRepository repository;
  List<CategoryModel> bookTypeCategories = [];
  List<CategoryModel> bookCategories = [];
  CategoryCubit({required this.repository}) : super(InitState());

  Future<List<CategoryModel>> getCategoriesByCode({
    String? categoryTypeCode,
    String? sortBy,
    String? sortType,
  }) async {
    try {
      emit(LoadingState());
      return await repository
          .getCategoriesByCategoryTypeCode(
            categoryTypeCode ?? "",
            sortBy,
            sortType,
          );
    } catch (e) {
      return [];
    }
  }
}
