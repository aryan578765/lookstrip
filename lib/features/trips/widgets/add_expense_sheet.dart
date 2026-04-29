import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:lookstrip/core/theme/app_colors.dart';
import 'package:lookstrip/core/theme/app_shapes.dart';
import 'package:lookstrip/core/models/expense_model.dart';
import 'package:lookstrip/core/providers/expense_provider.dart';
import 'package:lookstrip/core/services/app_preferences.dart';
import 'package:lookstrip/core/services/supabase_service.dart';

/// Bottom sheet to add a new expense
class AddExpenseSheet extends ConsumerStatefulWidget {
  final String tripId;
  const AddExpenseSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  String _category = 'food';
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currency = await AppPreferences.getPreferredCurrency();
    if (!mounted) return;
    setState(() => _currency = currency);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);

    final expense = Expense(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      userId: SupabaseService.maybeClient?.auth.currentUser?.id,
      category: _category,
      amount: amount,
      currency: _currency,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: DateTime.now(),
    );

    await ref.read(expenseProvider(widget.tripId).notifier).addExpense(expense);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppShapes.screenPadding,
        right: AppShapes.screenPadding,
        top: AppShapes.spaceMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppShapes.spaceLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.radius2xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppShapes.spaceMd),

          Text('Add Expense', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppShapes.spaceLg),

          // Category selector
          Text('Category', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppShapes.spaceSm),
          Wrap(
            spacing: AppShapes.spaceSm,
            runSpacing: AppShapes.spaceSm,
            children: Expense.categories.map((cat) {
              final isSelected = _category == cat.$1;
              return GestureDetector(
                onTap: () => setState(() => _category = cat.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppShapes.spaceMd,
                    vertical: AppShapes.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppShapes.radiusFull),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    '${cat.$2} ${cat.$3}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppShapes.spaceLg),

          // Amount input
          Text('Amount', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppShapes.spaceSm),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              prefixText: '$_currency ',
              prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              hintText: '0.00',
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: AppShapes.spaceMd),

          // Note input
          Text(
            'Note (optional)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppShapes.spaceSm),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'e.g. Lunch at local restaurant',
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppShapes.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: AppShapes.spaceLg),

          // Save button
          SizedBox(
            width: double.infinity,
            height: AppShapes.buttonHeight,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Add Expense 💸'),
            ),
          ),
        ],
      ),
    );
  }
}
