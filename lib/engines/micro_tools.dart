import '../models/finance_models.dart';
import '../state/finance_store.dart';

class MicroTool {
  const MicroTool({
    required this.id,
    required this.title,
    required this.blurb,
    required this.iconName,
    this.superFeature = false,
    this.basicFeature = false,
  });

  final String id;
  final String title;
  final String blurb;
  final String iconName;
  final bool superFeature;
  final bool basicFeature;
}

const microTools = <MicroTool>[
  MicroTool(
    id: 'safe_spend',
    title: 'Safe-to-Spend Daily Limit',
    blurb: 'What’s left after rent, mess, and already-logged spend.',
    iconName: 'today',
  ),
  MicroTool(
    id: 'hostel_survival',
    title: 'Hostel Survival Fund',
    blurb: 'How many days your cash lasts at hostel burn rate.',
    iconName: 'hotel',
  ),
  MicroTool(
    id: 'impulse_timer',
    title: 'Impulse Purchase Delay Timer',
    blurb: 'Cool off 10 minutes before you tap pay.',
    iconName: 'timer',
  ),
  MicroTool(
    id: 'fx_converter',
    title: 'Multi-Currency Converter',
    blurb: 'INR, USD, EUR, GBP, AED, SGD — hostel trip ready.',
    iconName: 'currency_exchange',
  ),
  MicroTool(
    id: 'cashflow',
    title: 'Cashflow Trendlines',
    blurb: 'Last 14 days of logged expenses as a sparkline.',
    iconName: 'show_chart',
  ),
  MicroTool(
    id: 'mess_tracker',
    title: 'Food & Mess Allowance',
    blurb: 'Track remaining mess/food budget this month.',
    iconName: 'restaurant',
  ),
  MicroTool(
    id: 'emergency_bar',
    title: 'Emergency Savings Goal Bar',
    blurb: 'Progress toward your rainy-day stash.',
    iconName: 'savings',
  ),
  MicroTool(
    id: 'risk_meter',
    title: 'High-Spender Risk Meter',
    blurb: 'Burn vs income — are you overheating?',
    iconName: 'speed',
  ),
  MicroTool(
    id: 'gig_smoother',
    title: 'Gig Income Smoother',
    blurb: 'Turn lumpy gigs into a weekly paycheck number.',
    iconName: 'work',
  ),
  MicroTool(
    id: 'rent_split',
    title: 'Room Rent Splitter',
    blurb: 'Split hostel/PG rent across roommates.',
    iconName: 'groups',
  ),
  MicroTool(
    id: 'sub_leak',
    title: 'Subscription Leak Detector',
    blurb: 'OTT + cloud + gym fees vs leftover cash.',
    iconName: 'subscriptions',
  ),
  MicroTool(
    id: 'fest_cap',
    title: 'Festival Spend Cap',
    blurb: 'Combined Diwali/Holi/Rakhi remaining caps.',
    iconName: 'celebration',
  ),
  MicroTool(
    id: 'invoice_buffer',
    title: 'Freelance Invoice Buffer',
    blurb: 'Hold 30% of gigs for late clients & GST-lite.',
    iconName: 'receipt_long',
  ),
  MicroTool(
    id: 'weekend_burn',
    title: 'Weekend Burn Rate',
    blurb: 'Sat–Sun spend compared to weekday average.',
    iconName: 'local_fire_department',
  ),
  MicroTool(
    id: 'emi_check',
    title: 'EMI Affordability Check',
    blurb: 'Keep EMIs under 30% of monthly income.',
    iconName: 'account_balance',
  ),
  MicroTool(
    id: 'pocket_stretch',
    title: 'Pocket Money Stretch',
    blurb: 'Days remaining if you spend at current pace.',
    iconName: 'account_balance_wallet',
  ),
  MicroTool(
    id: 'coffee_killer',
    title: 'Café Budget Killer',
    blurb: 'Daily chai/coffee vs a monthly canteen brew.',
    iconName: 'coffee',
  ),
  MicroTool(
    id: 'semester_fees',
    title: 'Semester Fee Planner',
    blurb: 'Sinking fund for the next fee cycle.',
    iconName: 'school',
  ),
  MicroTool(
    id: 'hustle_roi',
    title: 'Side Hustle ROI',
    blurb: 'Hours in vs rupees out on gigs.',
    iconName: 'trending_up',
  ),
  MicroTool(
    id: 'snowball',
    title: 'Debt Snowball Preview',
    blurb: 'Knock smallest open debts first.',
    iconName: 'stacked_line_chart',
  ),
  MicroTool(
    id: 'streak',
    title: 'No-Spend Streak',
    blurb: 'Consecutive days without a logged expense.',
    iconName: 'emoji_events',
  ),
  MicroTool(
    id: 'inflation',
    title: 'Inflation Reality Check',
    blurb: 'What last year’s mess fee is worth now.',
    iconName: 'query_stats',
  ),
  MicroTool(
    id: 'trip_split',
    title: 'Trip Cost Splitter',
    blurb: 'Train + stay + food across friends.',
    iconName: 'train',
  ),
  MicroTool(
    id: 'night_out',
    title: 'Night-Out Budget Guard',
    blurb: 'Cap for tonight without wrecking the week.',
    iconName: 'nightlife',
  ),
  MicroTool(
    id: 'laundry_split',
    title: 'Laundry & Utilities Split',
    blurb: 'Fair share of dhobi + wifi + electricity.',
    iconName: 'local_laundry_service',
  ),
  MicroTool(
    id: 'exam_food',
    title: 'Exam Week Food Buffer',
    blurb: 'Extra mess/food for late-night study days.',
    iconName: 'menu_book',
  ),
  MicroTool(
    id: 'runway',
    title: 'Startup Runway Weeks',
    blurb: 'Founder cash ÷ weekly burn.',
    iconName: 'rocket_launch',
  ),
  MicroTool(
    id: 'tax_lite',
    title: 'Freelancer Tax-Lite Set-Aside',
    blurb: 'Park 20% of monthly gigs.',
    iconName: 'gavel',
  ),
  MicroTool(
    id: 'rainy3',
    title: '3-Month Rainy Day Fund',
    blurb: 'Baseline × 3 as the safety target.',
    iconName: 'umbrella',
  ),
  MicroTool(
    id: 'auto_cut',
    title: 'Auto-Pay Cut List',
    blurb: 'How much you free by pausing 2 subscriptions.',
    iconName: 'content_cut',
  ),
  MicroTool(
    id: 'mess_skip',
    title: 'Mess-Skip Savings',
    blurb: 'Days you skip mess vs outside food.',
    iconName: 'no_meals',
  ),
  MicroTool(
    id: 'recalc_budget',
    title: 'Recalculate Budget Limits',
    blurb: 'Rebuild daily/weekly caps from latest income.',
    iconName: 'calculate',
    basicFeature: true,
  ),
  MicroTool(
    id: 'hostel_vol',
    title: 'Hostel Volatility Audit',
    blurb: 'Variance in hostel-related spend (5 coins).',
    iconName: 'analytics',
    superFeature: true,
  ),
  MicroTool(
    id: 'ai_event',
    title: 'AI Event Budget Predictor',
    blurb: 'Suggested caps for upcoming festivals (5 coins).',
    iconName: 'auto_awesome',
    superFeature: true,
  ),
];

class ToolMath {
  ToolMath(this.store);
  final FinanceStore store;

  double get weeklyIncome => store.monthlyIncome / 4.33;

  double hostelDaysRemaining(double cashOnHand) {
    final daily = (store.baseline.hostelRent + store.baseline.messFees) / 30;
    if (daily <= 0) return 0;
    return cashOnHand / daily;
  }

  double messRemaining() {
    final spent = store.expenses
        .where((e) => e.category == 'Food' || e.category == 'Mess')
        .fold(0.0, (s, e) => s + e.amount);
    return (store.baseline.food + store.baseline.messFees) - spent;
  }

  double riskScore() {
    if (store.monthlyIncome <= 0) return 100;
    return ((store.monthSpend + store.baseline.monthlyTotal) /
            store.monthlyIncome *
            100)
        .clamp(0, 150);
  }

  double gigSmoothedWeekly() {
    final gig = store.incomes.where((i) => i.cadence == IncomeCadence.gig);
    final monthly = gig.fold(0.0, (s, i) => s + i.monthlyEstimate);
    return monthly / 4.33;
  }

  Map<DateTime, double> last14Spend() {
    final map = <DateTime, double>{};
    final now = DateTime.now();
    for (var i = 13; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      map[d] = 0;
    }
    for (final e in store.expenses) {
      final key = DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day);
      if (map.containsKey(key)) {
        map[key] = map[key]! + e.amount;
      }
    }
    return map;
  }

  int noSpendStreak() {
    var streak = 0;
    final now = DateTime.now();
    for (var i = 0; i < 60; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final hit = store.expenses.any(
        (e) =>
            e.loggedAt.year == day.year &&
            e.loggedAt.month == day.month &&
            e.loggedAt.day == day.day,
      );
      if (hit) break;
      streak++;
    }
    return streak;
  }

  Map<String, double> predictedEventCaps() {
    final income = store.monthlyIncome;
    return {
      'Diwali': (income * 0.12).clamp(800, 12000),
      'Holi': (income * 0.04).clamp(300, 4000),
      'Raksha Bandhan': (income * 0.03).clamp(200, 3000),
      'Birthday': (income * 0.05).clamp(400, 5000),
      'College fest': (income * 0.06).clamp(500, 6000),
    };
  }

  double hostelVolatility() {
    final hostelish = store.expenses.where(
      (e) =>
          e.category == 'Hostel' ||
          e.category == 'Mess' ||
          e.category == 'Rent' ||
          e.category == 'Utilities',
    );
    if (hostelish.isEmpty) return 0;
    final amounts = hostelish.map((e) => e.amount).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    if (mean == 0) return 0;
    final variance = amounts
            .map((a) => (a - mean) * (a - mean))
            .reduce((a, b) => a + b) /
        amounts.length;
    return (variance.sqrtSafe() / mean) * 100;
  }
}

extension on double {
  double sqrtSafe() {
    if (this <= 0) return 0;
    var x = this;
    for (var i = 0; i < 12; i++) {
      x = 0.5 * (x + this / x);
    }
    return x;
  }
}
