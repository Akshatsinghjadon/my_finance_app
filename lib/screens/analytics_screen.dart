import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/feature_costs.dart';
import '../services/csv_export_service.dart';
import '../state/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_chip.dart';
import '../widgets/earn_coins_sheet.dart';
import '../widgets/screen_scaffold.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    return ScreenScaffold(
      title: 'Basic analytics',
      actions: const [CoinChip()],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () async {
              final ok = await consumeFeature(context, CoinFeature.basicAnalytics);
              if (!ok || !context.mounted) return;
              final leftover =
                  store.monthlyIncome - store.baseline.monthlyTotal - store.monthSpend;
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cash snapshot'),
                  content: Text(
                    'Income ${inr(store.monthlyIncome)}\n'
                    'Baseline ${inr(store.baseline.monthlyTotal)}\n'
                    'Logged spend ${inr(store.monthSpend)}\n'
                    'Leftover ${inr(leftover)}\n'
                    'Daily cap ${inr(store.safeToSpendDaily)}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Run analytics (1 coin)'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await consumeFeature(context, CoinFeature.csvExport);
              if (!ok || !context.mounted) return;
              await CsvExportService().exportLedger(store);
            },
            icon: const Icon(Icons.download),
            label: const Text('CSV export (1 coin)'),
          ),
          const SizedBox(height: 16),
          Text('Category mix (this month)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._byCategory(store).entries.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key),
                  trailing: Text(inr(e.value)),
                ),
              ),
        ],
      ),
    );
  }

  Map<String, double> _byCategory(FinanceStore store) {
    final map = <String, double>{};
    final now = DateTime.now();
    for (final e in store.expenses) {
      if (e.loggedAt.year != now.year || e.loggedAt.month != now.month) continue;
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
