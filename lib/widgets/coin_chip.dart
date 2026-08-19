import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/coin_wallet.dart';

class CoinChip extends StatelessWidget {
  const CoinChip({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<CoinWallet>().balance;
    return Chip(
      avatar: const Icon(Icons.monetization_on, color: Color(0xFFD97706)),
      label: Text('$balance coins'),
      visualDensity: VisualDensity.compact,
    );
  }
}
