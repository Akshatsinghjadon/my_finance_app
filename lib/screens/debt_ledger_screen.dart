import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/feature_costs.dart';
import '../models/finance_models.dart';
import '../state/coin_wallet.dart';
import '../state/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_chip.dart';
import '../widgets/earn_coins_sheet.dart';
import '../widgets/screen_scaffold.dart';

class DebtLedgerScreen extends StatelessWidget {
  const DebtLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final unlocked =
        context.watch<CoinWallet>().isUnlocked(CoinFeature.debtNotifications);
    return ScreenScaffold(
      title: 'Lend / borrow',
      actions: const [CoinChip()],
      fab: FloatingActionButton.extended(
        onPressed: () => _addDebt(context),
        icon: const Icon(Icons.add),
        label: const Text('IOU'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(
                unlocked
                    ? 'Due-date push alerts are on'
                    : 'Unlock due-date push alerts',
              ),
              subtitle: const Text(
                '5 coins · “Today is the date to request/pay back ₹X …”',
              ),
              onTap: unlocked
                  ? null
                  : () => consumeFeature(context, CoinFeature.debtNotifications),
            ),
          ),
          const SizedBox(height: 8),
          if (store.debts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No lent or borrowed entries yet.'),
            ),
          ...store.debts.map((d) {
            return Card(
              child: ListTile(
                leading: Icon(
                  d.direction == DebtDirection.lent
                      ? Icons.call_made
                      : Icons.call_received,
                ),
                title: Text(d.contactName),
                subtitle: Text(
                  '${d.direction == DebtDirection.lent ? 'They owe you' : 'You owe'} · '
                  'due ${d.dueDate.toLocal().toString().split(' ').first}'
                  '${d.settled ? ' · settled' : ''}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(inr(d.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (!d.settled)
                      TextButton(
                        onPressed: () => store.settleDebt(d.id),
                        child: const Text('Settle'),
                      ),
                  ],
                ),
                isThreeLine: !d.settled,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _addDebt(BuildContext context) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    var direction = DebtDirection.lent;
    var due = DateTime.now().add(const Duration(days: 7));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Log an IOU'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Contact name'),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              DropdownButtonFormField<DebtDirection>(
                initialValue: direction,
                items: const [
                  DropdownMenuItem(
                    value: DebtDirection.lent,
                    child: Text('I lent (they owe me)'),
                  ),
                  DropdownMenuItem(
                    value: DebtDirection.borrowed,
                    child: Text('I borrowed (I owe them)'),
                  ),
                ],
                onChanged: (v) => setLocal(() => direction = v ?? direction),
                decoration: const InputDecoration(labelText: 'Direction'),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    initialDate: due,
                  );
                  if (picked != null) setLocal(() => due = picked);
                },
                child: Text('Due ${due.toLocal().toString().split(' ').first}'),
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
    final n = double.tryParse(amount.text.trim());
    if (ok != true || n == null || n <= 0 || !context.mounted) return;
    final store = context.read<FinanceStore>();
    final wallet = context.read<CoinWallet>();
    var schedule = wallet.isUnlocked(CoinFeature.debtNotifications);
    if (!schedule) {
      schedule = await consumeFeature(context, CoinFeature.debtNotifications);
    }
    if (!context.mounted) return;
    await store.addDebt(
      DebtRecord(
        id: store.newId(),
        contactName: name.text.trim().isEmpty ? 'Friend' : name.text.trim(),
        amount: n,
        direction: direction,
        dueDate: due,
      ),
      scheduleAlert: schedule,
    );
  }
}
