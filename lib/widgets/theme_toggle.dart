import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return IconButton(
      tooltip: theme.isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: theme.toggle,
      icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}

class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return SwitchListTile(
      secondary: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode),
      title: const Text('Dark mode'),
      subtitle: Text(theme.isDark ? 'On' : 'Off'),
      value: theme.isDark,
      onChanged: theme.setDark,
    );
  }
}
