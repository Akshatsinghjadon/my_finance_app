import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/feature_costs.dart';
import '../config/monetization.dart';

class CoinWallet extends ChangeNotifier {
  CoinWallet();

  static const _balanceKey = 'coin_balance';
  static const _unlockKey = 'unlocked_features';

  int _balance = Monetization.startingCoins;
  final Set<String> _unlocked = {};

  int get balance => _balance;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_balanceKey) ?? Monetization.startingCoins;
    _unlocked
      ..clear()
      ..addAll(prefs.getStringList(_unlockKey) ?? const []);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, _balance);
    await prefs.setStringList(_unlockKey, _unlocked.toList());
  }

  bool isUnlocked(CoinFeature feature) => _unlocked.contains(feature.name);

  bool canAfford(int cost) => _balance >= cost;

  Future<void> credit(int amount) async {
    if (amount <= 0) return;
    _balance += amount;
    await _persist();
    notifyListeners();
  }

  /// Spends coins and permanently unlocks [feature]. Returns false if broke.
  Future<bool> unlock(CoinFeature feature) async {
    if (isUnlocked(feature)) return true;
    if (!canAfford(feature.cost)) return false;
    _balance -= feature.cost;
    _unlocked.add(feature.name);
    await _persist();
    notifyListeners();
    return true;
  }

  /// Pay-per-use for tools that should not stay unlocked forever.
  Future<bool> spend(int cost) async {
    if (!canAfford(cost)) return false;
    _balance -= cost;
    await _persist();
    notifyListeners();
    return true;
  }
}
