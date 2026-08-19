import 'package:flutter/material.dart';

import 'banner_ad_slot.dart';
import 'theme_toggle.dart';

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.fab,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const ThemeToggleButton(),
          ...?actions,
        ],
      ),
      floatingActionButton: fab,
      body: Column(
        children: [
          Expanded(child: body),
          const SafeArea(
            top: false,
            child: BannerAdSlot(),
          ),
        ],
      ),
    );
  }
}
