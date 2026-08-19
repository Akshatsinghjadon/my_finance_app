import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/monetization.dart';
import '../util/platform.dart';

class AdService extends ChangeNotifier {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _sdkReady = false;
  bool interstitialReady = false;
  bool rewardedReady = false;
  String? lastError;

  bool get isReady => _sdkReady;

  Future<void> initialize() async {
    if (!isMobileAdsPlatform) {
      lastError = 'AdMob runs on Android and iOS devices only.';
      notifyListeners();
      return;
    }
    try {
      final status = await MobileAds.instance.initialize();
      _sdkReady = status.adapterStatuses.isNotEmpty;
      lastError = _sdkReady ? null : 'AdMob initialized with no adapters.';
      notifyListeners();
      await Future.wait([preloadInterstitial(), preloadRewarded()]);
    } catch (e) {
      lastError = 'AdMob init failed: $e';
      debugPrint(lastError);
      notifyListeners();
    }
  }

  Future<void> preloadInterstitial() async {
    if (!isMobileAdsPlatform) return;
    interstitialReady = false;
    notifyListeners();
    await InterstitialAd.load(
      adUnitId: Monetization.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          interstitialReady = true;
          lastError = null;
          notifyListeners();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              interstitialReady = false;
              notifyListeners();
              preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              lastError = 'Interstitial show failed: $error';
              ad.dispose();
              _interstitial = null;
              interstitialReady = false;
              notifyListeners();
              preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          lastError =
              'Interstitial ${Monetization.interstitialAdUnitId} failed: $error';
          debugPrint(lastError);
          _interstitial = null;
          interstitialReady = false;
          notifyListeners();
        },
      ),
    );
  }

  Future<void> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      await preloadInterstitial();
      return;
    }
    await ad.show();
  }

  Future<void> preloadRewarded() async {
    if (!isMobileAdsPlatform) return;
    rewardedReady = false;
    notifyListeners();
    await RewardedAd.load(
      adUnitId: Monetization.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          rewardedReady = true;
          lastError = null;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          lastError = 'Rewarded ${Monetization.rewardedAdUnitId} failed: $error';
          debugPrint(lastError);
          _rewarded = null;
          rewardedReady = false;
          notifyListeners();
        },
      ),
    );
  }

  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null) {
      await preloadRewarded();
      return false;
    }
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        rewardedReady = false;
        notifyListeners();
        preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        lastError = 'Rewarded show failed: $error';
        ad.dispose();
        _rewarded = null;
        rewardedReady = false;
        notifyListeners();
        preloadRewarded();
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
      },
    );
    return earned;
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
    super.dispose();
  }
}
