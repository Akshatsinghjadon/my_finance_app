import 'package:flutter/material.dart';

import 'debt_ledger_screen.dart';
import 'event_budget_screen.dart';
import 'expenses_screen.dart';
import 'home_screen.dart';
import 'income_profiler_screen.dart';
import 'tools_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    ExpensesScreen(),
    IncomeProfilerScreen(),
    EventBudgetScreen(),
    DebtLedgerScreen(),
    ToolsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Spend'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Income'),
          NavigationDestination(icon: Icon(Icons.celebration_outlined), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), label: 'IOUs'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Tools'),
        ],
      ),
    );
  }
}
