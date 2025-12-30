import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/usecases/add_expense_usecase.dart';
import 'package:readbox/domain/usecases/get_expense_list_usecase.dart';
import 'package:readbox/domain/usecases/update_expense_usecase.dart';
import 'package:readbox/domain/usecases/delete_expense_usecase.dart';
import 'package:readbox/domain/usecases/search_expenses_usecase.dart';

class ExpenseCubit extends Cubit<BaseState> {
  final GetExpenseListUseCase getExpenseListUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final SearchExpensesUseCase searchExpensesUseCase;

  ExpenseCubit({
    required this.getExpenseListUseCase,
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.searchExpensesUseCase,
  }) : super(InitState());

  List<ExpenseModel> _expensesList = [];
  List<ExpenseModel> get expensesList => _expensesList;

  double get totalAmount {
    return _expensesList.fold(0.0, (sum, expense) => sum + (expense.amount ?? 0.0));
  }

  void getExpenses({String? category}) async {
    try {
      emit(LoadingState());
      _expensesList = await getExpenseListUseCase(category: category);
      emit(LoadedState(_expensesList));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void searchExpenses(String query) async {
    try {
      if (query.isEmpty) {
        getExpenses();
        return;
      }
      emit(LoadingState());
      _expensesList = await searchExpensesUseCase(query);
      emit(LoadedState(_expensesList));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void addExpense(ExpenseModel expense) async {
    try {
      emit(LoadingState());
      await addExpenseUseCase(expense);
      // Refresh list after adding
      getExpenses();
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void updateExpense(ExpenseModel expense) async {
    try {
      emit(LoadingState());
      await updateExpenseUseCase(expense);
      // Refresh list after updating
      getExpenses();
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void deleteExpense(String expenseId) async {
    try {
      emit(LoadingState());
      await deleteExpenseUseCase(expenseId);
      // Remove from local list
      final id = int.tryParse(expenseId);
      if (id != null) {
        _expensesList.removeWhere((expense) => expense.id == id);
      }
      emit(LoadedState(_expensesList));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void refreshExpenses() {
    getExpenses();
  }
}

