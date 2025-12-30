import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/domain/network/network.dart';

class ExpenseRemoteDataSource {
  final Network network;

  ExpenseRemoteDataSource({required this.network});

  Future<List<ExpenseModel>> getExpensesList({
    String? category,
    String? searchQuery,
  }) async {
    Map<String, dynamic> params = {};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['keyword'] = searchQuery;
    }

    String endpoint = (searchQuery != null && searchQuery.isNotEmpty) || category != null
        ? 'expenses/search'
        : ApiConstant.getExpensesList;

    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}$endpoint',
      params: params,
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data is List) {
        return (apiResponse.data as List)
            .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<ExpenseModel> getExpenseById(String id) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}expenses/$id',
    );

    if (apiResponse.isSuccess) {
      return ExpenseModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.createExpense}',
      body: expense.toJson(),
    );

    if (apiResponse.isSuccess) {
      return ExpenseModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.updateExpense}/${expense.id}/update',
      body: expense.toJson(),
    );

    if (apiResponse.isSuccess) {
      return ExpenseModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<bool> deleteExpense(String id) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.deleteExpense}/$id/delete',
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }
  
  Future<Map<String, dynamic>> getStatistics({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, dynamic> params = {};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (startDate != null) params['startDate'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) params['endDate'] = endDate.toIso8601String().split('T')[0];

    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}expenses/statistics',
      params: params,
    );

    if (apiResponse.isSuccess) {
      return apiResponse.data as Map<String, dynamic>;
    }
    return Future.error(apiResponse.errMessage);
  }
}

