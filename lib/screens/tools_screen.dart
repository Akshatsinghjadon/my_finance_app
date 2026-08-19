import 'package:flutter/material.dart';

import '../engines/micro_tools.dart';
import '../widgets/coin_chip.dart';
import '../widgets/screen_scaffold.dart';
import 'tool_detail_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: '30+ micro-tools',
      actions: const [CoinChip()],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final cross = width >= 900
              ? 4
              : width >= 600
                  ? 3
                  : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: microTools.length,
            itemBuilder: (context, i) {
              final tool = microTools[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ToolDetailScreen(tool: tool),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _icon(tool.iconName),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Spacer(),
                        Text(
                          tool.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tool.blurb,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (tool.superFeature || tool.basicFeature)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              tool.superFeature ? '5 coins' : '1 coin',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _icon(String name) {
    switch (name) {
      case 'today':
        return Icons.today;
      case 'hotel':
        return Icons.hotel;
      case 'timer':
        return Icons.timer;
      case 'currency_exchange':
        return Icons.currency_exchange;
      case 'show_chart':
        return Icons.show_chart;
      case 'restaurant':
        return Icons.restaurant;
      case 'savings':
        return Icons.savings;
      case 'speed':
        return Icons.speed;
      case 'work':
        return Icons.work;
      case 'groups':
        return Icons.groups;
      case 'subscriptions':
        return Icons.subscriptions;
      case 'celebration':
        return Icons.celebration;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'account_balance':
        return Icons.account_balance;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'coffee':
        return Icons.coffee;
      case 'school':
        return Icons.school;
      case 'trending_up':
        return Icons.trending_up;
      case 'stacked_line_chart':
        return Icons.stacked_line_chart;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'query_stats':
        return Icons.query_stats;
      case 'train':
        return Icons.train;
      case 'nightlife':
        return Icons.nightlife;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'menu_book':
        return Icons.menu_book;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'gavel':
        return Icons.gavel;
      case 'umbrella':
        return Icons.beach_access;
      case 'content_cut':
        return Icons.content_cut;
      case 'no_meals':
        return Icons.no_meals;
      case 'calculate':
        return Icons.calculate;
      case 'analytics':
        return Icons.analytics;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.handyman;
    }
  }
}
