import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart'; // TransactionType için
import '../theme/app_theme.dart';
import '../widgets/date_selector.dart';
import '../widgets/add_transaction_modal.dart';
import 'dashboard_screen.dart'; // Needed for GroupSelector

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final dashboardData = ref.watch(incomeDashboardProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GroupSelector(groups: groups, activeGroupId: appSettings.activeGroupId),
        actions: [
          IconButton(
            icon: Icon(appSettings.isPrivacyMode ? Icons.visibility_off_outlined : Icons.visibility_outlined), 
            onPressed: () => ref.read(appSettingsProvider.notifier).togglePrivacyMode(),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.add_circle, color: AppTheme.futureColor, size: 32),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddTransactionModal(
                    initialDate: ref.read(selectedDateProvider), // Tarih bilgisini de ekleyelim
                    initialType: TransactionType.income,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DateSelector(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: _IncomeSummaryCards(data: dashboardData),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeSummaryCards extends StatelessWidget {
  final Map<String, List<Transaction>> data;

  const _IncomeSummaryCards({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VerticalSummaryCard(
          title: 'income_screen.upcoming_income'.tr(),
          transactions: data['upcoming'] ?? [],
          color: Color(0xFF0F141A),
          textColor: AppTheme.futureColor,
        ),
        SizedBox(height: 12),
        VerticalSummaryCard(
          title: 'income_screen.received'.tr(),
          transactions: data['paid'] ?? [],
          color: Color(0xFF0F1A12),
          textColor: AppTheme.incomeColor,
        ),
      ],
    );
  }
}
