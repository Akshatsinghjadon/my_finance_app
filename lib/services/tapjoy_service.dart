import 'package:flutter/foundation.dart';
import 'package:tapjoy_offerwall/tapjoy_offerwall.dart';

import '../config/monetization.dart';
import '../state/coin_wallet.dart';
import '../util/platform.dart';

class TapjoyService extends ChangeNotifier {
  TapjoyService(this.wallet);

  final CoinWallet wallet;

  bool connected = false;
  String? lastError;
  int _lastTapjoyBalance = 0;
  bool _busy = false;

  bool get busy => _busy;

  Future<void> initialize() async {
    if (!isMobileAdsPlatform) {
      lastError = 'Tapjoy is available on Android and iOS only.';
      notifyListeners();
      return;
    }
    try {
      await Tapjoy.setLoggingLevel(
        kDebugMode ? TJLoggingLevel.debug : TJLoggingLevel.error,
      );
      await Tapjoy.connect(
        sdkKey: Monetization.tapjoySdkKey,
        options: {
          'app_id': Monetization.tapjoyAppId,
        },
        onConnectSuccess: () async {
          connected = true;
          lastError = null;
          notifyListeners();
          await _syncBalance(creditDelta: false);
        },
        onConnectFailure: (code, error) async {
          connected = false;
          lastError = error ?? 'Tapjoy connect failed ($code)';
          notifyListeners();
        },
        onConnectWarning: (code, warning) async {
          debugPrint('Tapjoy warning $code: $warning');
        },
      );
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> _syncBalance({required bool creditDelta}) async {
    await Tapjoy.getCurrencyBalance(
      onGetCurrencyBalanceSuccess: (name, balance) async {
        final next = balance;
        if (creditDelta) {
          final delta = next - _lastTapjoyBalance;
          if (delta > 0) {
            await wallet.credit(delta);
          }
        }
        _lastTapjoyBalance = next;
        notifyListeners();
      },
      onGetCurrencyBalanceFailure: (error) async {
        debugPrint('Tapjoy balance error: $error');
      },
    );
  }

  Future<void> showOfferwall() async {
    if (!isMobileAdsPlatform) {
      lastError = 'Offerwall requires a physical Android/iOS device.';
      notifyListeners();
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      if (!connected) {
        await initialize();
      }
      final placement = await Tapjoy.getPlacement(
        placementName: Monetization.tapjoyOfferwallPlacement,
        onRequestSuccess: (p) {},
        onRequestFailure: (p, error) {
          lastError = error;
          notifyListeners();
        },
        onContentReady: (p) async {
          await p.showContent();
        },
        onContentShow: (p) {},
        onContentDismiss: (p) async {
          await _syncBalance(creditDelta: true);
        },
      );
      if (placement != null) {
        await placement.requestContent();
      }
    } catch (e) {
      lastError = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
