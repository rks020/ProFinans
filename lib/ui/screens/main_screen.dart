import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'income_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../data/models/enums.dart'; // TransactionType için
import '../widgets/add_transaction_modal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              final selectedDate = ref.read(selectedDateProvider);
              TransactionType? type;
              if (_selectedIndex == 2) type = TransactionType.income; // Gelir ekranı
              else type = TransactionType.expense; // Diğer ekranlar (Varsayılan: Gider)

              return AddTransactionModal(
                initialDate: selectedDate,
                initialType: type,
              );
            },
          );
        },
        backgroundColor: AppTheme.futureColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppTheme.surfaceColor,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sol Tarafta 2 Menü
              _buildNavItem(0, Icons.assignment, 'Gider'),
              _buildNavItem(1, Icons.bar_chart, 'Analiz'),
              
              const SizedBox(width: 40), // Merkeze boşluk (FAB için)
              
              // Sağ Tarafta 2 Menü
              _buildNavItem(2, Icons.account_balance_wallet, 'Gelir'),
              _buildNavItem(3, Icons.settings, 'Ayarlar'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isSelected ? AppTheme.futureColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.futureColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
