import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/feature_costs.dart';
import '../models/finance_models.dart';
import '../state/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_chip.dart';
import '../widgets/earn_coins_sheet.dart';
import '../widgets/screen_scaffold.dart';
import '../engines/micro_tools.dart';

class EventBudgetScreen extends StatelessWidget {
  const EventBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    return ScreenScaffold(
      title: 'Event budgets',
      actions: [
        const CoinChip(),
        IconButton(
          tooltip: 'AI predictor (5 coins)',
          onPressed: () => _predict(context),
          icon: const Icon(Icons.auto_awesome),
        ),
      ],
      fab: FloatingActionButton.extended(
        onPressed: () => _addEvent(context),
        icon: const Icon(Icons.add),
        label: const Text('Bucket'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          Text(
            'Cultural buckets (Diwali, Holi, Raksha Bandhan) and personal ones (birthdays, parties).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ...store.events.map((e) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Chip(
                          label: Text(e.kind.name),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: e.progress.clamp(0, 1)),
                    const SizedBox(height: 8),
                    Text(
                      'Spent ${inr(e.spent)} of ${inr(e.cap)} · left ${inr(e.remaining)}',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _spend(context, e),
                        child: const Text('Log spend'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _predict(BuildContext context) async {
    final unlocked = await consumeFeature(context, CoinFeature.aiEventPredictor);
    if (!unlocked || !context.mounted) return;
    final caps = ToolMath(context.read<FinanceStore>()).predictedEventCaps();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI event budget predictor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: caps.entries
              .map((e) => Text('${e.key}: ${inr(e.value)}'))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _spend(BuildContext context, EventBudget event) async {
    final amount = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Spend on ${event.name}'),
        content: TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₹)'),
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
    );
    final n = double.tryParse(amount.text.trim());
    if (ok == true && n != null && n > 0 && context.mounted) {
      await context.read<FinanceStore>().logEventSpend(event.id, n);
    }
  }

  Future<void> _addEvent(BuildContext context) async {
    final name = TextEditingController();
    final cap = TextEditingController();
    var kind = EventKind.personal;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('New event bucket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. Holi, Birthday)',
                ),
              ),
              TextField(
                controller: cap,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cap (₹)'),
              ),
              DropdownButtonFormField<EventKind>(
                initialValue: kind,
                items: EventKind.values
                    .map((k) => DropdownMenuItem(value: k, child: Text(k.name)))
                    .toList(),
                onChanged: (v) => setLocal(() => kind = v ?? kind),
                decoration: const InputDecoration(labelText: 'Type'),
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
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    final n = double.tryParse(cap.text.trim());
    if (ok == true && n != null && n > 0 && context.mounted) {
      final store = context.read<FinanceStore>();
      await store.addEvent(
        EventBudget(
          id: store.newId(),
          name: name.text.trim().isEmpty ? 'Event' : name.text.trim(),
          kind: kind,
          cap: n,
        ),
      );
    }
  }
}
