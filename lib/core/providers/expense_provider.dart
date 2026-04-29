import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/core/models/expense_model.dart';
import 'package:lookstrip/core/services/expense_service.dart';

/// Expense state for a specific trip
class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final Map<String, double> categoryTotals;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.categoryTotals = const {},
  });

  double get total => expenses.fold(0.0, (sum, e) => sum + e.amount);

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    Map<String, double>? categoryTotals,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      categoryTotals: categoryTotals ?? this.categoryTotals,
    );
  }
}

/// Expense notifier for a specific trip
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final String tripId;
  final ExpenseService _service = ExpenseService();

  ExpenseNotifier(this.tripId) : super(const ExpenseState()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true);
    try {
      final expenses = await _service.getExpenses(tripId);
      final totals = <String, double>{};
      for (final e in expenses) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
      state = state.copyWith(
        expenses: expenses,
        categoryTotals: totals,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    await _service.addExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String expenseId) async {
    await _service.deleteExpense(expenseId);
    await loadExpenses();
  }
}

/// Riverpod family provider — one per trip
final expenseProvider =
    StateNotifierProvider.family<ExpenseNotifier, ExpenseState, String>(
      (ref, tripId) => ExpenseNotifier(tripId),
    );
