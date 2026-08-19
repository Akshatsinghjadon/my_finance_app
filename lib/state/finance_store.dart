import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/feature_costs.dart';
import '../config/monetization.dart';
import '../models/finance_models.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import 'coin_wallet.dart';

class FinanceStore extends ChangeNotifier {
  FinanceStore({
    required this.wallet,
    required this.ads,
    required this.notifications,
  });

  final CoinWallet wallet;
  final AdService ads;
  final NotificationService notifications;
  final _uuid = const Uuid();

  static const _key = 'finance_snapshot_v1';

  final List<IncomeStream> incomes = [];
  final List<ExpenseEntry> expenses = [];
  final List<EventBudget> events = [];
  final List<DebtRecord> debts = [];
  BaselineNeeds baseline = BaselineNeeds();
  int expenseLogCount = 0;
  double emergencyGoal = 10000;
  double emergencySaved = 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _seedDefaults();
      await _persist();
      notifyListeners();
      return;
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    incomes
      ..clear()
      ..addAll(
        (map['incomes'] as List<dynamic>).map(
          (e) => IncomeStream.fromJson(e as Map<String, dynamic>),
        ),
      );
    expenses
      ..clear()
      ..addAll(
        (map['expenses'] as List<dynamic>).map(
          (e) => ExpenseEntry.fromJson(e as Map<String, dynamic>),
        ),
      );
    events
      ..clear()
      ..addAll(
        (map['events'] as List<dynamic>).map(
          (e) => EventBudget.fromJson(e as Map<String, dynamic>),
        ),
      );
    debts
      ..clear()
      ..addAll(
        (map['debts'] as List<dynamic>).map(
          (e) => DebtRecord.fromJson(e as Map<String, dynamic>),
        ),
      );
    baseline = BaselineNeeds.fromJson(
      map['baseline'] as Map<String, dynamic>? ?? {},
    );
    expenseLogCount = map['expenseLogCount'] as int? ?? expenses.length;
    emergencyGoal = (map['emergencyGoal'] as num?)?.toDouble() ?? 10000;
    emergencySaved = (map['emergencySaved'] as num?)?.toDouble() ?? 0;
    notifyListeners();
  }

  void _seedDefaults() {
    incomes.addAll([
      IncomeStream(
        id: _uuid.v4(),
        label: 'Weekend tutoring',
        amount: 2500,
        cadence: IncomeCadence.weekly,
      ),
      IncomeStream(
        id: _uuid.v4(),
        label: 'Freelance design gig',
        amount: 4000,
        cadence: IncomeCadence.gig,
      ),
    ]);
    baseline = BaselineNeeds(
      food: 3500,
      hostelRent: 8000,
      messFees: 2500,
      utilities: 800,
      transport: 600,
    );
    events.addAll([
      EventBudget(
        id: _uuid.v4(),
        name: 'Diwali',
        kind: EventKind.cultural,
        cap: 4000,
      ),
      EventBudget(
        id: _uuid.v4(),
        name: 'Holi',
        kind: EventKind.cultural,
        cap: 1500,
      ),
      EventBudget(
        id: _uuid.v4(),
        name: 'Raksha Bandhan',
        kind: EventKind.cultural,
        cap: 1200,
      ),
      EventBudget(
        id: _uuid.v4(),
        name: 'Birthday',
        kind: EventKind.personal,
        cap: 2000,
      ),
    ]);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'incomes': incomes.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'events': events.map((e) => e.toJson()).toList(),
        'debts': debts.map((e) => e.toJson()).toList(),
        'baseline': baseline.toJson(),
        'expenseLogCount': expenseLogCount,
        'emergencyGoal': emergencyGoal,
        'emergencySaved': emergencySaved,
      }),
    );
  }

  double get monthlyIncome =>
      incomes.fold(0.0, (sum, i) => sum + i.monthlyEstimate);

  double get monthSpend {
    final now = DateTime.now();
    return expenses
        .where((e) => e.loggedAt.year == now.year && e.loggedAt.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get safeToSpendDaily {
    final daysLeft = DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
            .day -
        DateTime.now().day +
        1;
    final leftover = monthlyIncome - baseline.monthlyTotal - monthSpend;
    if (daysLeft <= 0) return 0;
    return leftover / daysLeft;
  }

  Future<void> addIncome(IncomeStream stream) async {
    incomes.add(stream);
    await _persist();
    notifyListeners();
  }

  Future<void> removeIncome(String id) async {
    incomes.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> saveBaseline(BaselineNeeds next) async {
    baseline = next;
    await _persist();
    notifyListeners();
  }

  Future<void> addExpense(ExpenseEntry entry) async {
    expenses.insert(0, entry);
    expenseLogCount += 1;
    await _persist();
    notifyListeners();
    if (expenseLogCount % Monetization.interstitialEveryNthExpense == 0) {
      await ads.showInterstitial();
    }
  }

  Future<void> addEvent(EventBudget event) async {
    events.add(event);
    await _persist();
    notifyListeners();
  }

  Future<void> logEventSpend(String id, double amount) async {
    final event = events.firstWhere((e) => e.id == id);
    event.spent += amount;
    await _persist();
    notifyListeners();
  }

  Future<void> addDebt(DebtRecord debt, {bool scheduleAlert = false}) async {
    if (scheduleAlert && wallet.isUnlocked(CoinFeature.debtNotifications)) {
      final id = notifications.nextId();
      debt.notificationId = id;
      await notifications.scheduleDebtReminder(debt);
    }
    debts.insert(0, debt);
    await _persist();
    notifyListeners();
  }

  Future<void> settleDebt(String id) async {
    final debt = debts.firstWhere((d) => d.id == id);
    debt.settled = true;
    if (debt.notificationId != null) {
      await notifications.cancel(debt.notificationId!);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setEmergency({double? goal, double? saved}) async {
    if (goal != null) emergencyGoal = goal;
    if (saved != null) emergencySaved = saved;
    await _persist();
    notifyListeners();
  }

  String newId() => _uuid.v4();
}
