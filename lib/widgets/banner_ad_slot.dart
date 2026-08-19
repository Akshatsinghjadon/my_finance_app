import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/monetization.dart';
import '../util/platform.dart';

class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!isMobileAdsPlatform) return;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: Monetization.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed: $error');
        },
      ),
      request: const AdRequest(),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = AdSize.banner.height.toDouble();
    if (!_loaded || _ad == null) {
      return SizedBox(
        height: height,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: Text('Sponsored', style: TextStyle(fontSize: 11)),
          ),
        ),
      );
    }
    return SizedBox(
      width: AdSize.banner.width.toDouble(),
      height: height,
      child: AdWidget(ad: _ad!),
    );
  }
}
