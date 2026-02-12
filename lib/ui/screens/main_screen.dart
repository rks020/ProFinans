import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'income_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(), // Gider (Dashboard)
    const AnalysisScreen(),
    const IncomeScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppTheme.futureColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppTheme.surfaceColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Gider'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analiz'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Gelir'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}
