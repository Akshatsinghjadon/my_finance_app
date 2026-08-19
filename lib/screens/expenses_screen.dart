import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_models.dart';
import '../state/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_chip.dart';
import '../widgets/screen_scaffold.dart';

const expenseCategories = [
  'Food',
  'Mess',
  'Hostel',
  'Rent',
  'Transport',
  'Utilities',
  'Fun',
  'Gig costs',
  'Other',
];

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    return ScreenScaffold(
      title: 'Expenses',
      actions: const [CoinChip()],
      fab: FloatingActionButton.extended(
        onPressed: () => _logExpense(context),
        icon: const Icon(Icons.add),
        label: const Text('Log expense'),
      ),
      body: store.expenses.isEmpty
          ? const Center(child: Text('No expenses yet. Log your first chai.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: store.expenses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = store.expenses[i];
                return Card(
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text(
                      '${e.category} · ${e.loggedAt.toLocal().toString().split('.').first}',
                    ),
                    trailing: Text(
                      inr(e.amount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _logExpense(BuildContext context) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    var category = expenseCategories.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Log expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'What did you buy?'),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: expenseCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setLocal(() => category = v ?? category),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final rupees = double.tryParse(amount.text.trim()) ?? 0;
    if (rupees <= 0) return;
    final store = context.read<FinanceStore>();
    await store.addExpense(
      ExpenseEntry(
        id: store.newId(),
        title: title.text.trim().isEmpty ? category : title.text.trim(),
        amount: rupees,
        category: category,
        loggedAt: DateTime.now(),
      ),
    );
  }
}
