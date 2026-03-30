import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'income_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../data/models/enums.dart';
import '../widgets/add_transaction_modal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalysisScreen(),
    const IncomeScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainScreenIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
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
              if (selectedIndex == 2) {
                type = TransactionType.income;
              } else {
                type = TransactionType.expense;
              }

              return AddTransactionModal(
                initialDate: selectedDate,
                initialType: type,
                initialCurrency: ref.read(appSettingsProvider).selectedCurrency,
              );
            },
          );
        },
        backgroundColor: AppTheme.futureColor,
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppTheme.surfaceColor,
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.assignment, 'bottom_nav.expenses'.tr(), selectedIndex),
              _buildNavItem(1, Icons.bar_chart, 'bottom_nav.analysis'.tr(), selectedIndex),
              
              SizedBox(width: 40),
              
              _buildNavItem(2, Icons.account_balance_wallet, 'bottom_nav.income'.tr(), selectedIndex),
              _buildNavItem(3, Icons.settings, 'bottom_nav.settings'.tr(), selectedIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int selectedIndex) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => ref.read(mainScreenIndexProvider.notifier).setIndex(index),
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
