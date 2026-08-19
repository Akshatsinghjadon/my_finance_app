import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/feature_costs.dart';
import '../engines/micro_tools.dart';
import '../models/finance_models.dart';
import '../state/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_chip.dart';
import '../widgets/earn_coins_sheet.dart';
import '../widgets/screen_scaffold.dart';

class ToolDetailScreen extends StatefulWidget {
  const ToolDetailScreen({super.key, required this.tool});

  final MicroTool tool;

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  String _result = '';
  DateTime? _impulseUntil;
  Timer? _tick;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final math = ToolMath(store);
    return ScreenScaffold(
      title: widget.tool.title,
      actions: const [CoinChip()],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.tool.blurb),
          const SizedBox(height: 16),
          ..._body(context, store, math),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _result,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    FinanceStore store,
    ToolMath math,
  ) {
    switch (widget.tool.id) {
      case 'safe_spend':
        return [
          Text('Daily safe-to-spend: ${inr(store.safeToSpendDaily)}'),
          Text(
            'Income ${inr(store.monthlyIncome)} − baseline ${inr(store.baseline.monthlyTotal)} − month spend ${inr(store.monthSpend)}.',
          ),
        ];
      case 'hostel_survival':
        return [
          _field(_a, 'Cash on hand (₹)', '8000'),
          FilledButton(
            onPressed: () {
              final cash = double.tryParse(_a.text) ?? 0;
              setState(() {
                _result =
                    '${math.hostelDaysRemaining(cash).toStringAsFixed(1)} days of hostel+mess coverage.';
              });
            },
            child: const Text('Calculate'),
          ),
        ];
      case 'impulse_timer':
        return [
          Text(
            _impulseUntil == null
                ? 'Start a 10-minute pause before buying.'
                : 'Wait ${_impulseUntil!.difference(DateTime.now()).inSeconds.clamp(0, 600)}s',
          ),
          FilledButton(
            onPressed: () {
              _tick?.cancel();
              setState(() {
                _impulseUntil = DateTime.now().add(const Duration(minutes: 10));
              });
              _tick = Timer.periodic(const Duration(seconds: 1), (_) {
                if (!mounted) return;
                if (DateTime.now().isAfter(_impulseUntil!)) {
                  _tick?.cancel();
                  setState(() {
                    _result = 'Timer done. If you still want it, it might be real.';
                    _impulseUntil = null;
                  });
                } else {
                  setState(() {});
                }
              });
            },
            child: const Text('Start 10-minute delay'),
          ),
        ];
      case 'fx_converter':
        return [
          _field(_a, 'Amount', '1000'),
          _field(_b, 'From (INR/USD/EUR/GBP/AED/SGD)', 'INR'),
          _field(_c, 'To', 'USD'),
          FilledButton(
            onPressed: () {
              const ratesToInr = {
                'INR': 1.0,
                'USD': 83.5,
                'EUR': 90.2,
                'GBP': 106.0,
                'AED': 22.7,
                'SGD': 62.4,
              };
              final amt = double.tryParse(_a.text) ?? 0;
              final from = _b.text.trim().toUpperCase();
              final to = _c.text.trim().toUpperCase();
              final f = ratesToInr[from];
              final t = ratesToInr[to];
              if (f == null || t == null) {
                setState(() => _result = 'Unknown currency. Use INR/USD/EUR/GBP/AED/SGD.');
                return;
              }
              final inrAmt = amt * f;
              setState(() => _result = '${(inrAmt / t).toStringAsFixed(2)} $to');
            },
            child: const Text('Convert'),
          ),
        ];
      case 'cashflow':
        final series = math.last14Spend().entries.toList();
        return [
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < series.length; i++)
                        FlSpot(i.toDouble(), series[i].value),
                    ],
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ];
      case 'mess_tracker':
        return [Text('Food + mess remaining this month: ${inr(math.messRemaining())}')];
      case 'emergency_bar':
        final p = store.emergencyGoal <= 0
            ? 0.0
            : (store.emergencySaved / store.emergencyGoal).clamp(0.0, 1.0);
        return [
          LinearProgressIndicator(value: p),
          const SizedBox(height: 8),
          Text('${inr(store.emergencySaved)} of ${inr(store.emergencyGoal)}'),
          _field(_a, 'Saved so far (₹)', store.emergencySaved.toStringAsFixed(0)),
          _field(_b, 'Goal (₹)', store.emergencyGoal.toStringAsFixed(0)),
          FilledButton(
            onPressed: () {
              store.setEmergency(
                saved: double.tryParse(_a.text),
                goal: double.tryParse(_b.text),
              );
            },
            child: const Text('Update goal'),
          ),
        ];
      case 'risk_meter':
        final r = math.riskScore();
        return [
          Text('Risk ${r.toStringAsFixed(0)} / 100+'),
          LinearProgressIndicator(value: (r / 100).clamp(0, 1)),
          Text(
            r > 90
                ? 'High-spender zone. Cut fun spend this week.'
                : r > 70
                    ? 'Warm. Watch weekends and cafés.'
                    : 'Healthy burn vs income.',
          ),
        ];
      case 'gig_smoother':
        return [
          Text('Smoothed weekly gig paycheck: ${inr(math.gigSmoothedWeekly())}'),
        ];
      case 'rent_split':
        return [
          _field(_a, 'Total rent (₹)', store.baseline.hostelRent.toStringAsFixed(0)),
          _field(_b, 'Roommates including you', '3'),
          FilledButton(
            onPressed: () {
              final rent = double.tryParse(_a.text) ?? 0;
              final n = int.tryParse(_b.text) ?? 1;
              setState(() => _result = 'Each pays ${inr(rent / n.clamp(1, 20))}');
            },
            child: const Text('Split'),
          ),
        ];
      case 'sub_leak':
        return [
          _field(_a, 'Monthly subscriptions (₹)', '499'),
          FilledButton(
            onPressed: () {
              final sub = double.tryParse(_a.text) ?? 0;
              final left = store.monthlyIncome - store.baseline.monthlyTotal - sub;
              setState(
                () => _result =
                    'Subs eat ${inr(sub)}. Leftover after baseline: ${inr(left)}.',
              );
            },
            child: const Text('Scan leak'),
          ),
        ];
      case 'fest_cap':
        final remaining = store.events
            .where((e) => e.kind == EventKind.cultural)
            .fold(0.0, (s, e) => s + e.remaining);
        return [Text('Cultural event remaining: ${inr(remaining)}')];
      case 'invoice_buffer':
        return [
          Text(
            'Hold ${inr(store.monthlyIncome * 0.3)} (30% of estimated income) as invoice buffer.',
          ),
        ];
      case 'weekend_burn':
        final weekend = store.expenses
            .where((e) => e.loggedAt.weekday >= 6)
            .fold(0.0, (s, e) => s + e.amount);
        final weekday = store.expenses
            .where((e) => e.loggedAt.weekday < 6)
            .fold(0.0, (s, e) => s + e.amount);
        return [
          Text('Weekend total ${inr(weekend)} vs weekday ${inr(weekday)}.'),
        ];
      case 'emi_check':
        return [
          _field(_a, 'Proposed EMI (₹ / month)', '2500'),
          FilledButton(
            onPressed: () {
              final emi = double.tryParse(_a.text) ?? 0;
              final cap = store.monthlyIncome * 0.3;
              setState(() {
                _result = emi > cap
                    ? 'Too heavy. Cap is ${inr(cap)} (30% of income).'
                    : 'Fits. Headroom ${inr(cap - emi)}.';
              });
            },
            child: const Text('Check'),
          ),
        ];
      case 'pocket_stretch':
        final pace = store.monthSpend /
            DateTime.now().day.clamp(1, 31);
        final left = store.monthlyIncome - store.baseline.monthlyTotal - store.monthSpend;
        final days = pace <= 0 ? 0.0 : left / pace;
        return [Text('At current pace, leftover lasts ${days.toStringAsFixed(1)} days.')];
      case 'coffee_killer':
        return [
          _field(_a, 'Café visits per week', '5'),
          _field(_b, 'Price per cup (₹)', '180'),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(_a.text) ?? 0;
              final p = double.tryParse(_b.text) ?? 0;
              setState(
                () => _result =
                    'Monthly café burn ${inr(v * p * 4.33)}. Canteen brew at ₹20 is ${inr(v * 20 * 4.33)}.',
              );
            },
            child: const Text('Compare'),
          ),
        ];
      case 'semester_fees':
        return [
          _field(_a, 'Next fee bill (₹)', '45000'),
          _field(_b, 'Months until due', '4'),
          FilledButton(
            onPressed: () {
              final fee = double.tryParse(_a.text) ?? 0;
              final m = double.tryParse(_b.text) ?? 1;
              setState(() => _result = 'Park ${inr(fee / m.clamp(1, 24))} / month.');
            },
            child: const Text('Plan'),
          ),
        ];
      case 'hustle_roi':
        return [
          _field(_a, 'Hours this month', '20'),
          _field(_b, 'Gig income this month (₹)', '8000'),
          FilledButton(
            onPressed: () {
              final h = double.tryParse(_a.text) ?? 1;
              final pay = double.tryParse(_b.text) ?? 0;
              setState(() => _result = 'Effective rate ${inr(pay / h.clamp(0.5, 400))}/hr.');
            },
            child: const Text('ROI'),
          ),
        ];
      case 'snowball':
        final open = store.debts.where((d) => !d.settled).toList()
          ..sort((a, b) => a.amount.compareTo(b.amount));
        return [
          if (open.isEmpty) const Text('No open debts.'),
          ...open.map((d) => Text('${d.contactName}: ${inr(d.amount)}')),
        ];
      case 'streak':
        return [Text('${math.noSpendStreak()} day no-spend streak.')];
      case 'inflation':
        return [
          _field(_a, 'Last year mess fee (₹)', store.baseline.messFees.toStringAsFixed(0)),
          FilledButton(
            onPressed: () {
              final old = double.tryParse(_a.text) ?? 0;
              setState(() => _result = 'At 6% inflation that is ${inr(old * 1.06)} today.');
            },
            child: const Text('Adjust'),
          ),
        ];
      case 'trip_split':
        return [
          _field(_a, 'Train (₹)', '1200'),
          _field(_b, 'Stay (₹)', '3000'),
          _field(_c, 'Friends (count)', '4'),
          FilledButton(
            onPressed: () {
              final train = double.tryParse(_a.text) ?? 0;
              final stay = double.tryParse(_b.text) ?? 0;
              final n = int.tryParse(_c.text) ?? 1;
              setState(() => _result = 'Each: ${inr((train + stay) / n.clamp(1, 20))}');
            },
            child: const Text('Split trip'),
          ),
        ];
      case 'night_out':
        return [
          Text(
            'Tonight’s guardrail: ${inr((store.safeToSpendDaily * 1.5).clamp(0, 2500))}',
          ),
        ];
      case 'laundry_split':
        return [
          _field(_a, 'Wifi + electricity + dhobi (₹)', store.baseline.utilities.toStringAsFixed(0)),
          _field(_b, 'People', '3'),
          FilledButton(
            onPressed: () {
              final t = double.tryParse(_a.text) ?? 0;
              final n = int.tryParse(_b.text) ?? 1;
              setState(() => _result = 'Fair share ${inr(t / n.clamp(1, 12))}');
            },
            child: const Text('Split utilities'),
          ),
        ];
      case 'exam_food':
        return [
          Text(
            'Exam-week food buffer (7 × 1.4× daily food): ${inr((store.baseline.food / 30) * 1.4 * 7)}',
          ),
        ];
      case 'runway':
        return [
          _field(_a, 'Cash in business (₹)', '50000'),
          FilledButton(
            onPressed: () {
              final cash = double.tryParse(_a.text) ?? 0;
              final weekly = (store.baseline.monthlyTotal + store.monthSpend) / 4.33;
              setState(() {
                _result = weekly <= 0
                    ? 'No burn yet.'
                    : '${(cash / weekly).toStringAsFixed(1)} weeks of runway.';
              });
            },
            child: const Text('Runway'),
          ),
        ];
      case 'tax_lite':
        return [
          Text('Set aside 20% of monthly income: ${inr(store.monthlyIncome * 0.2)}'),
        ];
      case 'rainy3':
        return [
          Text('3-month rainy fund target: ${inr(store.baseline.monthlyTotal * 3)}'),
        ];
      case 'auto_cut':
        return [
          _field(_a, 'Two subs you can pause (₹ / month)', '349'),
          FilledButton(
            onPressed: () {
              final s = double.tryParse(_a.text) ?? 0;
              setState(() => _result = 'Yearly unlocked: ${inr(s * 12)}');
            },
            child: const Text('Cut list'),
          ),
        ];
      case 'mess_skip':
        return [
          _field(_a, 'Mess skips this month', '6'),
          _field(_b, 'Outside meal cost (₹)', '180'),
          FilledButton(
            onPressed: () {
              final skips = double.tryParse(_a.text) ?? 0;
              final out = double.tryParse(_b.text) ?? 0;
              final messDay = store.baseline.messFees / 30;
              setState(() {
                _result = skips * out > skips * messDay
                    ? 'Skipping mess cost extra ${inr(skips * (out - messDay))}.'
                    : 'Skipping saved ${inr(skips * (messDay - out))}.';
              });
            },
            child: const Text('Compare'),
          ),
        ];
      case 'recalc_budget':
        return [
          FilledButton(
            onPressed: () async {
              final ok = await consumeFeature(context, CoinFeature.recalculateBudget);
              if (!ok || !mounted) return;
              setState(() {
                _result =
                    'Rebuilt caps — daily ${inr(store.safeToSpendDaily)}, weekly ${inr(store.safeToSpendDaily * 7)}, monthly leftover ${inr(store.monthlyIncome - store.baseline.monthlyTotal)}.';
              });
            },
            child: const Text('Recalculate (1 coin)'),
          ),
        ];
      case 'hostel_vol':
        return [
          FilledButton(
            onPressed: () async {
              final ok =
                  await consumeFeature(context, CoinFeature.hostelVolatilityAudit);
              if (!ok || !mounted) return;
              setState(() {
                _result =
                    'Hostel spend coefficient of variation: ${math.hostelVolatility().toStringAsFixed(1)}%. '
                    '${math.hostelVolatility() > 40 ? 'Volatile — mess skips and auto-pays are swinging you.' : 'Stable hostel burn.'}';
              });
            },
            child: const Text('Run audit (5 coins)'),
          ),
        ];
      case 'ai_event':
        return [
          FilledButton(
            onPressed: () async {
              final ok = await consumeFeature(context, CoinFeature.aiEventPredictor);
              if (!ok || !mounted) return;
              final caps = math.predictedEventCaps();
              setState(() {
                _result = caps.entries
                    .map((e) => '${e.key}: ${inr(e.value)}')
                    .join('\n');
              });
            },
            child: const Text('Predict (5 coins)'),
          ),
        ];
      default:
        return [const Text('Tool ready.')];
    }
  }

  Widget _field(TextEditingController c, String label, String hint) {
    if (c.text.isEmpty) c.text = hint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
