import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/models/expense_model.dart';
import 'package:lookstrip/core/services/supabase_service.dart';

/// Manages expenses locally first, with optional Supabase sync.
class ExpenseService {
  static const _boxName = 'expenses';
  static String _scope = 'guest';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static void setUserScope(String? userId) {
    _scope = (userId == null || userId.isEmpty) ? 'guest' : userId;
  }

  static Future<void> clearAllExpenses() async {
    await _box.clear();
  }

  static Box<String> get _box => Hive.box<String>(_boxName);
  static String get _prefix => '$_scope:';

  String? get _userId => SupabaseService.maybeClient?.auth.currentUser?.id;

  Future<void> addExpense(Expense expense) async {
    await _saveLocal(expense);

    final client = SupabaseService.maybeClient;
    if (client == null || _userId == null) return;
    try {
      await client.from('expenses').upsert(expense.toJson());
    } catch (_) {
      // Keep local copy. The UI remains usable offline.
    }
  }

  Future<List<Expense>> getExpenses(String tripId) async {
    final local = _loadLocal(tripId);
    final client = SupabaseService.maybeClient;
    if (client == null) return local;

    try {
      final data = await client
          .from('expenses')
          .select()
          .eq('trip_id', tripId)
          .order('date', ascending: false);

      final remote = (data as List)
          .map((row) => Expense.fromJson(row as Map<String, dynamic>))
          .toList();

      for (final expense in remote) {
        await _saveLocal(expense);
      }

      return _merge(remote, local);
    } catch (_) {
      return local;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    await _deleteLocal(expenseId);

    final client = SupabaseService.maybeClient;
    if (client == null) return;
    try {
      await client.from('expenses').delete().eq('id', expenseId);
    } catch (_) {}
  }

  Future<Map<String, double>> getTotalByCategory(String tripId) async {
    final expenses = await getExpenses(tripId);
    final totals = <String, double>{};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Future<double> getTotal(String tripId) async {
    final expenses = await getExpenses(tripId);
    return expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> _saveLocal(Expense expense) {
    return _box.put('$_prefix${expense.id}', jsonEncode(expense.toJson()));
  }

  List<Expense> _loadLocal(String tripId) {
    final expenses = <Expense>[];
    for (final key in _box.keys) {
      if (!key.toString().startsWith(_prefix)) continue;
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        final expense = Expense.fromJson(jsonDecode(raw));
        if (expense.tripId == tripId) expenses.add(expense);
      } catch (_) {}
    }
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Future<void> _deleteLocal(String expenseId) {
    return _box.delete('$_prefix$expenseId');
  }

  List<Expense> _merge(List<Expense> remote, List<Expense> local) {
    final merged = <String, Expense>{};
    for (final expense in local) {
      merged[expense.id] = expense;
    }
    for (final expense in remote) {
      merged[expense.id] = expense;
    }
    return merged.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}
