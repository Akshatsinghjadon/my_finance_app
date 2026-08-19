import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/coin_wallet.dart';
import '../state/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_chip.dart';
import '../widgets/screen_scaffold.dart';
import '../widgets/theme_toggle.dart';
import 'analytics_screen.dart';
import 'offerwall_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final coins = context.watch<CoinWallet>().balance;
    return ScreenScaffold(
      title: 'CampusLedger',
      actions: [
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: CoinChip(),
        ),
        IconButton(
          tooltip: 'Earn coins',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const OfferwallScreen()),
          ),
          icon: const Icon(Icons.card_giftcard),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Built for hostel nights, gig weeks, and founder runways.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Monthly income',
                  value: inr(store.monthlyIncome),
                  icon: Icons.south_west,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'This month out',
                  value: inr(store.monthSpend),
                  icon: Icons.north_east,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Safe to spend / day',
                  value: inr(store.safeToSpendDaily),
                  icon: Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Coin wallet',
                  value: '$coins',
                  icon: Icons.monetization_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.insights)),
              title: const Text('Basic analytics'),
              subtitle: const Text('1 coin · cashflow mix & leftover'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AnalyticsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Baseline hostel load',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _Bar('Food', store.baseline.food, store.baseline.monthlyTotal),
                  _Bar(
                    'Hostel rent',
                    store.baseline.hostelRent,
                    store.baseline.monthlyTotal,
                  ),
                  _Bar(
                    'Mess fees',
                    store.baseline.messFees,
                    store.baseline.monthlyTotal,
                  ),
                  const SizedBox(height: 8),
                  Text('Monthly must-pays ${inr(store.baseline.monthlyTotal)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open debts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...store.debts.where((d) => !d.settled).take(3).map(
                (d) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d.contactName),
                  subtitle: Text(
                    '${d.direction.name} · due ${d.dueDate.toLocal().toString().split(' ').first}',
                  ),
                  trailing: Text(inr(d.amount)),
                ),
              ),
          if (store.debts.where((d) => !d.settled).isEmpty)
            const Text('No open IOUs. Nice.'),
          const SizedBox(height: 8),
          const Card(child: ThemeToggleTile()),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.value, this.total);
  final String label;
  final double value;
  final double total;

  @override
  Widget build(BuildContext context) {
    final t = total <= 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(inr(value)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: t.clamp(0, 1)),
        ],
      ),
    );
  }
}
