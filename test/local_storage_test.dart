import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/models/expense_model.dart';
import 'package:lookstrip/core/models/user_model.dart';
import 'package:lookstrip/core/services/expense_service.dart';
import 'package:lookstrip/core/services/profile_storage.dart';

void main() {
  late Directory hiveDir;

  setUp(() {
    hiveDir = Directory.systemTemp.createTempSync('lookstrip_hive_test_');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (hiveDir.existsSync()) {
      hiveDir.deleteSync(recursive: true);
    }
    ExpenseService.setUserScope(null);
  });

  test('ExpenseService keeps local expenses scoped per user', () async {
    await ExpenseService.init();
    final service = ExpenseService();

    ExpenseService.setUserScope('user-a');
    await service.addExpense(
      Expense(
        id: 'expense-a',
        tripId: 'trip-1',
        userId: 'user-a',
        category: 'food',
        amount: 25,
        date: DateTime(2026, 1, 1),
      ),
    );

    expect(await service.getExpenses('trip-1'), hasLength(1));

    ExpenseService.setUserScope('user-b');
    expect(await service.getExpenses('trip-1'), isEmpty);

    ExpenseService.setUserScope('user-a');
    final userAExpenses = await service.getExpenses('trip-1');
    expect(userAExpenses, hasLength(1));
    expect(userAExpenses.single.id, 'expense-a');
  });

  test('ProfileStorage loads the current user profile by scoped key', () async {
    await ProfileStorage.init();
    final userA = UserModel(
      id: 'user-a',
      phone: '+10000000000',
      name: 'A',
      createdAt: DateTime(2026, 1, 1),
    );
    final userB = UserModel(
      id: 'user-b',
      phone: '+20000000000',
      name: 'B',
      createdAt: DateTime(2026, 1, 2),
    );

    await ProfileStorage.saveUser(userA);
    await ProfileStorage.saveUser(userB);

    expect(ProfileStorage.loadUser()?.id, 'user-b');

    await ProfileStorage.clearProfile();
    expect(ProfileStorage.loadUser(), isNull);
  });
}
