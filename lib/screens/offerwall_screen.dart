import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/monetization.dart';
import '../services/ad_service.dart';
import '../services/tapjoy_service.dart';
import '../state/coin_wallet.dart';
import '../widgets/coin_chip.dart';
import '../widgets/screen_scaffold.dart';

class OfferwallScreen extends StatelessWidget {
  const OfferwallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tapjoy = context.watch<TapjoyService>();
    final coins = context.watch<CoinWallet>().balance;
    return ScreenScaffold(
      title: 'Earn coins',
      actions: const [CoinChip()],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Wallet: $coins coins',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Rewarded video grants a flat +10 coins. Tapjoy Offerwall credits '
            'whatever currency you earn on completion (synced into this wallet).',
          ),
          const SizedBox(height: 16),         
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ondemand_video),
              title: const Text('Rewarded video ad'),
              subtitle: Text(
                'Ad unit ${Monetization.rewardedAdUnitId}',
              ),
              trailing: const Text('+10'),
              onTap: () async {
                final earned = await context.read<AdService>().showRewarded();
                if (!context.mounted) return;
                if (earned) {
                  await context.read<CoinWallet>().credit(
                        Monetization.rewardedCoinGrant,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('+10 coins credited')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rewarded ad not ready')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tapjoy Offerwall',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('App ID: ${Monetization.tapjoyAppId}'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: tapjoy.busy
                        ? null
                        : () => context.read<TapjoyService>().showOfferwall(),
                    icon: tapjoy.busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.storefront),
                    label: Text(
                      tapjoy.connected
                          ? 'Open Offerwall'
                          : 'Initialize Tapjoy & open Offerwall',
                    ),
                  ),
                  if (tapjoy.lastError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      tapjoy.lastError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
