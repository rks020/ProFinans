import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/add_goal_modal.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsProgress = ref.watch(goalsProgressProvider);
    final goalsList = goalsProgress.values.toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('goals.title'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: goalsList.isEmpty 
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: goalsList.length,
              itemBuilder: (context, index) {
                final progress = goalsList[index];
                return _buildGoalCard(context, ref, progress);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalModal(context),
        backgroundColor: AppTheme.futureColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          SizedBox(height: 20),
          Text(
            'goals.empty_title'.tr(),
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'goals.empty_desc'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddGoalModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.futureColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('goals.first_goal_btn'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, GoalProgress progress) {
    final goal = progress.goal;
    final color = Color(goal.colorCode);
    final percent = progress.percent;

    final selectedCurrency = ref.watch(appSettingsProvider).selectedCurrency;
    final displaySymbol = selectedCurrency == 'TRY' ? '₺' : (selectedCurrency == 'USD' ? '\$' : '€');

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (goal.deadline != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'goals.target_date'.tr(namedArgs: {'date': DateFormat('d MMM yyyy', context.locale.languageCode).format(goal.deadline!)}),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey, size: 20),
                onPressed: () => _showEditGoalModal(context, goal),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0).format(progress.currentAmount),
                style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'goals.target'.tr(namedArgs: {'amount': NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0).format(goal.targetAmount)}),
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'goals.completed'.tr(namedArgs: {'percent': (percent * 100).toStringAsFixed(1)}),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (progress.remaining > 0)
                Text(
                  'goals.remaining'.tr(namedArgs: {'amount': NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0).format(progress.remaining)}),
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                )
              else
                Text(
                  'goals.goal_reached'.tr(),
                  style: TextStyle(color: AppTheme.incomeColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddGoalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGoalModal(),
    );
  }

  void _showEditGoalModal(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGoalModal(goalToEdit: goal),
    );
  }
}
