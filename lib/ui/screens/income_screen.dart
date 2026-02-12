import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/add_transaction_modal.dart';
import 'dashboard_screen.dart'; // Reuse some widgets

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
            icon: const Icon(Icons.visibility_outlined), 
            onPressed: () => _showSoon(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined), 
            onPressed: () => _showSoon(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.futureColor, size: 32),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddTransactionModal(),
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
              padding: const EdgeInsets.all(16.0),
              child: _IncomeSummaryCards(data: dashboardData),
            ),
          ],
        ),
      ),
    );
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik yakında eklenecek'),
        duration: Duration(seconds: 1),
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
          title: 'Gelecek Gelir',
          transactions: data['upcoming'] ?? [],
          color: const Color(0xFF0F141A),
          textColor: AppTheme.futureColor,
        ),
        const SizedBox(height: 12),
        VerticalSummaryCard(
          title: 'Alınan',
          transactions: data['paid'] ?? [],
          color: const Color(0xFF0F1A12),
          textColor: AppTheme.incomeColor,
        ),
      ],
    );
  }
}
