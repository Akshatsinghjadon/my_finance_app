import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/feature_costs.dart';
import '../config/monetization.dart';
import '../services/ad_service.dart';
import '../services/tapjoy_service.dart';
import '../state/coin_wallet.dart';
import '../util/platform.dart';

Future<void> showEarnCoinsSheet(BuildContext context, {CoinFeature? forFeature}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => EarnCoinsSheet(forFeature: forFeature),
  );
}

class EarnCoinsSheet extends StatefulWidget {
  const EarnCoinsSheet({super.key, this.forFeature});

  final CoinFeature? forFeature;

  @override
  State<EarnCoinsSheet> createState() => _EarnCoinsSheetState();
}

class _EarnCoinsSheetState extends State<EarnCoinsSheet> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<CoinWallet>();
    final feature = widget.forFeature;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            feature == null
                ? 'Need more coins'
                : 'Not enough coins for ${feature.label}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You have ${wallet.balance} coins. '
            '${feature == null ? '' : 'This costs ${feature.cost}. '}'
            'Watch a rewarded ad for +${Monetization.rewardedCoinGrant} coins, '
            'or complete Tapjoy offers for a dynamic coin payout.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _working ? null : _watchAd,
            icon: const Icon(Icons.ondemand_video),
            label: Text(
              'Watch rewarded video (+${Monetization.rewardedCoinGrant} coins)',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _working ? null : _openWall,
            icon: const Icon(Icons.storefront),
            label: const Text('Open Tapjoy Offerwall'),
          ),
          if (!isMobileAdsPlatform) ...[
            const SizedBox(height: 8),
            Text(
              'Ads and Offerwall run on Android/iOS. On this desktop preview, '
              'a demo grant is available.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton(
              onPressed: _working
                  ? null
                  : () async {
                      await context.read<CoinWallet>().credit(
                            Monetization.rewardedCoinGrant,
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
              child: const Text('Preview: credit +10 coins'),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _watchAd() async {
    setState(() => _working = true);
    final ads = context.read<AdService>();
    final earned = await ads.showRewarded();
    if (!mounted) return;
    if (earned) {
      await context.read<CoinWallet>().credit(Monetization.rewardedCoinGrant);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+10 coins added to your wallet'),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rewarded ad not ready. Try again in a moment.'),
        ),
      );
    }
    if (mounted) setState(() => _working = false);
  }

  Future<void> _openWall() async {
    setState(() => _working = true);
    await context.read<TapjoyService>().showOfferwall();
    if (mounted) {
      setState(() => _working = false);
      Navigator.pop(context);
    }
  }
}

Future<bool> consumeFeature(BuildContext context, CoinFeature feature) async {
  final wallet = context.read<CoinWallet>();
  if (wallet.isUnlocked(feature)) return true;
  final ok = await wallet.unlock(feature);
  if (ok) return true;
  if (context.mounted) {
    await showEarnCoinsSheet(context, forFeature: feature);
  }
  if (!context.mounted) return false;
  return context.read<CoinWallet>().isUnlocked(feature);
}
