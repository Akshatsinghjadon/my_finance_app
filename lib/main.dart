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

  await theme.load();
  await wallet.load();
  await store.load();
  await notifications.initialize();
  await ads.initialize();
  await tapjoy.initialize();

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
  const CampusLedgerApp({
    super.key,
    required this.theme,
    required this.wallet,
    required this.ads,
    required this.tapjoy,
    required this.store,
  });

  final ThemeController theme;
  final CoinWallet wallet;
  final AdService ads;
  final TapjoyService tapjoy;
  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: wallet),
        ChangeNotifierProvider.value(value: ads),
        ChangeNotifierProvider.value(value: tapjoy),
        ChangeNotifierProvider.value(value: store),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'CampusLedger',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

/// Kept so existing tests that pump [MyApp] still compile.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    return CampusLedgerApp(
      theme: theme,
      wallet: wallet,
      ads: ads,
      tapjoy: tapjoy,
      store: store,
    );
  }
}
