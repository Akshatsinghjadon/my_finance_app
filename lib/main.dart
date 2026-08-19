import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/app_shell.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/tapjoy_service.dart';
import 'state/coin_wallet.dart';
import 'state/finance_store.dart';
import 'state/theme_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // 1. Initialize native Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  final theme = ThemeController();
  final wallet = CoinWallet();
  final ads = AdService();
  final notifications = NotificationService();
  final tapjoy = TapjoyService(wallet);
  final store = FinanceStore(
    wallet: wallet,
    ads: ads,
    notifications: notifications,
  );

  // 2. Load essential local storage states
  await theme.load();
  await wallet.load();
  await store.load();

  // 3. Initialize native external plugins safely
  try {
    await notifications.initialize();
  } catch (e) {
    debugPrint('Notifications init error: $e');
  }

  try {
    await ads.initialize();
  } catch (e) {
    debugPrint('AdMob init error: $e');
  }

  try {
    await tapjoy.initialize();
  } catch (e) {
    debugPrint('Tapjoy init error: $e');
  }

  runApp(
    CampusLedgerApp(
      theme: theme,
      wallet: wallet,
      ads: ads,
      tapjoy: tapjoy,
      store: store,
    ),
  );
}

class CampusLedgerApp extends StatelessWidget {
  final ThemeController theme;
  final CoinWallet wallet;
  final AdService ads;
  final TapjoyService tapjoy;
  final FinanceStore store;

  const CampusLedgerApp({
    super.key,
    required this.theme,
    required this.wallet,
    required this.ads,
    required this.tapjoy,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: wallet),
        Provider.value(value: ads),
        Provider.value(value: tapjoy),
        ChangeNotifierProvider.value(value: store),
      ],
      child: AnimatedBuilder(
        animation: theme,
        builder: (context, child) {
          return MaterialApp(
            title: 'Expense manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}