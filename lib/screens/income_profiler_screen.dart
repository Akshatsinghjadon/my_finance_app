import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_models.dart';
import '../state/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_chip.dart';
import '../widgets/screen_scaffold.dart';

class IncomeProfilerScreen extends StatelessWidget {
  const IncomeProfilerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    return ScreenScaffold(
      title: 'Income & baseline',
      actions: const [CoinChip()],
      fab: FloatingActionButton.extended(
        onPressed: () => _addIncome(context),
        icon: const Icon(Icons.add),
        label: const Text('Add income'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          Text(
            'Irregular pay: daily, weekly, gig, or monthly. Baseline covers food, hostel rent, and mess fees.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Estimated monthly ${inr(store.monthlyIncome)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...store.incomes.map(
            (i) => Card(
              child: ListTile(
                title: Text(i.label),
                subtitle: Text(
                  '${i.cadence.name} · ${inr(i.amount)} → ${inr(i.monthlyEstimate)}/mo',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => store.removeIncome(i.id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Baseline needs', style: Theme.of(context).textTheme.titleMedium),
          _NumField(
            label: 'Food',
            value: store.baseline.food,
            onChanged: (v) => store.saveBaseline(
              BaselineNeeds(
                food: v,
                hostelRent: store.baseline.hostelRent,
                messFees: store.baseline.messFees,
                utilities: store.baseline.utilities,
                transport: store.baseline.transport,
              ),
            ),
          ),
          _NumField(
            label: 'Hostel rent',
            value: store.baseline.hostelRent,
            onChanged: (v) => store.saveBaseline(
              BaselineNeeds(
                food: store.baseline.food,
                hostelRent: v,
                messFees: store.baseline.messFees,
                utilities: store.baseline.utilities,
                transport: store.baseline.transport,
              ),
            ),
          ),
          _NumField(
            label: 'Mess fees',
            value: store.baseline.messFees,
            onChanged: (v) => store.saveBaseline(
              BaselineNeeds(
                food: store.baseline.food,
                hostelRent: store.baseline.hostelRent,
                messFees: v,
                utilities: store.baseline.utilities,
                transport: store.baseline.transport,
              ),
            ),
          ),
          _NumField(
            label: 'Utilities',
            value: store.baseline.utilities,
            onChanged: (v) => store.saveBaseline(
              BaselineNeeds(
                food: store.baseline.food,
                hostelRent: store.baseline.hostelRent,
                messFees: store.baseline.messFees,
                utilities: v,
                transport: store.baseline.transport,
              ),
            ),
          ),
          _NumField(
            label: 'Transport',
            value: store.baseline.transport,
            onChanged: (v) => store.saveBaseline(
              BaselineNeeds(
                food: store.baseline.food,
                hostelRent: store.baseline.hostelRent,
                messFees: store.baseline.messFees,
                utilities: store.baseline.utilities,
                transport: v,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addIncome(BuildContext context) async {
    final label = TextEditingController();
    final amount = TextEditingController();
    var cadence = IncomeCadence.gig;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Income stream'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: label,
                decoration: const InputDecoration(labelText: 'Source'),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              DropdownButtonFormField<IncomeCadence>(
                initialValue: cadence,
                items: IncomeCadence.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setLocal(() => cadence = v ?? cadence),
                decoration: const InputDecoration(labelText: 'Cadence'),
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final rupees = double.tryParse(amount.text.trim()) ?? 0;
    if (rupees <= 0) return;
    final store = context.read<FinanceStore>();
    await store.addIncome(
      IncomeStream(
        id: store.newId(),
        label: label.text.trim().isEmpty ? 'Income' : label.text.trim(),
        amount: rupees,
        cadence: cadence,
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value.toStringAsFixed(0),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: '$label (₹ / month)',
          border: const OutlineInputBorder(),
        ),
        onFieldSubmitted: (v) {
          final n = double.tryParse(v);
          if (n != null) onChanged(n);
        },
      ),
    );
  }
}
