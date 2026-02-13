import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../theme/app_theme.dart';
import '../widgets/date_selector.dart';

import '../widgets/sankey_flow_chart.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  int _viewIndex = 0; // 0 for Flow, 1 for Trend

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_remove_outlined),
            tooltip: 'Veri Temizliği',
            onPressed: () => _showAuditModal(context, transactions),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const DateSelector(),
            const SizedBox(height: 16),
            _buildToggleButtons(),
            const SizedBox(height: 24),
            _viewIndex == 0
                ? _buildSankeyView(transactions)
                : _buildTrendView(transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleButton(0, 'Akış', Icons.account_tree_outlined)),
          Expanded(child: _toggleButton(1, 'Grafik', Icons.bar_chart_outlined)),
        ],
      ),
    );
  }

  Widget _toggleButton(int index, String label, IconData icon) {
    final isSelected = _viewIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _viewIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D47A1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSankeyView(List<Transaction> transactions) {
    double income = 0;
    double expenses = 0;
    double investments = 0;
    final incomeMap = <String, double>{};
    final expenseMap = <String, double>{};
    final investmentMap = <String, double>{};
    final colorMap = <String, Color>{};

    for (var t in transactions) {
      colorMap[t.category] = Color(t.colorCode);
      if (t.type == TransactionType.income) {
        income += t.amount;
        incomeMap[t.category] = (incomeMap[t.category] ?? 0) + t.amount;
      } else if (t.type == TransactionType.investment) {
        investments += t.amount;
        investmentMap[t.category] = (investmentMap[t.category] ?? 0) + t.amount;
      } else {
        expenses += t.amount;
        expenseMap[t.category] = (expenseMap[t.category] ?? 0) + t.amount;
      }
    }

    final incomeBreakdown = incomeMap.entries.map((e) => CategoryVolume(
      name: e.key,
      amount: e.value,
      color: colorMap[e.key] ?? Colors.grey,
    )).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final expenseBreakdown = expenseMap.entries.map((e) => CategoryVolume(
      name: e.key,
      amount: e.value,
      color: colorMap[e.key] ?? Colors.grey,
    )).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final investmentBreakdown = investmentMap.entries.map((e) => CategoryVolume(
      name: e.key,
      amount: e.value,
      color: colorMap[e.key] ?? const Color(0xFFFFD700),
    )).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final isPrivacyMode = ref.watch(appSettingsProvider).isPrivacyMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SankeyFlowChart(
          income: income,
          expenses: expenses,
          investments: investments,
          incomeBreakdown: incomeBreakdown,
          expenseBreakdown: expenseBreakdown,
          investmentBreakdown: investmentBreakdown,
          isPrivacyMode: isPrivacyMode,
        ),
      ],
    );
  }

  Widget _buildTrendView(List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Son 6 Ay Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: _TrendChart(transactions: transactions),
        ),
      ],
    );
  }

  void _showAuditModal(BuildContext context, List<Transaction> transactions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AuditListModal(transactions: transactions),
    );
  }
}

class _TrendChart extends ConsumerWidget {
  final List<Transaction> transactions;

  const _TrendChart({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) return const Center(child: Text("Veri Yok", style: TextStyle(color: Colors.grey)));

    final appSettings = ref.watch(appSettingsProvider);
    final isPrivacyMode = appSettings.isPrivacyMode;

    final now = DateTime.now();
    // Generate dates for current month + previous 5 months (total 6)
    final last6Months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));

    final data = last6Months.map((month) {
      final monthlyTrans = transactions.where((t) => t.date.year == month.year && t.date.month == month.month);
      final income = monthlyTrans.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
      final expense = monthlyTrans.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
      final investment = monthlyTrans.where((t) => t.type == TransactionType.investment).fold(0.0, (sum, t) => sum + t.amount);
      return {
        'month': DateFormat('MMM', 'tr_TR').format(month),
        'income': income,
        'expense': expense,
        'investment': investment,
      };
    }).toList();

    // Calculate max Y for scale
    double maxY = 0;
    for (var d in data) {
      final inc = d['income'] as double;
      final exp = d['expense'] as double;
      final inv = d['investment'] as double;
      if (inc > maxY) maxY = inc;
      if (exp > maxY) maxY = exp;
      if (inv > maxY) maxY = inv;
    }
    maxY = maxY * 1.2; // Add buffer
    if (maxY == 0) maxY = 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppTheme.surfaceColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final type = rodIndex == 0 ? 'Gelir' : (rodIndex == 1 ? 'Gider' : 'Yatırım');
                    final value = isPrivacyMode 
                        ? '***₺' 
                        : NumberFormat.currency(symbol: '₺', decimalDigits: 0, locale: 'tr_TR').format(rod.toY);
                    return BarTooltipItem(
                      '$type\n$value',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              barGroups: List.generate(data.length, (index) {
                final item = data[index];
                final income = item['income'] as double;
                final expense = item['expense'] as double;
                final investment = item['investment'] as double;

                return BarChartGroupData(
                  x: index,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: AppTheme.incomeColor,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: expense,
                      color: AppTheme.expenseColor,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: investment,
                      color: const Color(0xFFFFD700),
                      width: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      if (val.toInt() >= data.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          data[val.toInt()]['month'] as String,
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (val, meta) {
                      if (val == 0 || isPrivacyMode) return const SizedBox();
                      return Text(
                        NumberFormat.compact(locale: 'tr_TR').format(val),
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 5,
                getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: AppTheme.incomeColor, label: 'Gelirler'),
            const SizedBox(width: 16),
            _LegendItem(color: AppTheme.expenseColor, label: 'Giderler'),
            const SizedBox(width: 16),
            _LegendItem(color: const Color(0xFFFFD700), label: 'Yatırımlar'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _AuditListModal extends ConsumerWidget {
  final List<Transaction> transactions;

  const _AuditListModal({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Veri Listesi (Tümü)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              Expanded(
                child: transactions.isEmpty 
                    ? const Center(child: Text('Bu ay için veri yok', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        controller: controller,
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final isIncome = t.type == TransactionType.income;
                          final isInvestment = t.type == TransactionType.investment;
                          final format = NumberFormat.currency(symbol: '₺', decimalDigits: 0);
                          
                          Color displayColor = isIncome 
                              ? AppTheme.incomeColor 
                              : (isInvestment ? const Color(0xFFFFD700) : AppTheme.expenseColor);
                          
                          IconData displayIcon = isIncome 
                              ? Icons.arrow_downward 
                              : (isInvestment ? Icons.savings : Icons.arrow_upward);

                          return Dismissible(
                             key: Key(t.id),
                             direction: DismissDirection.endToStart,
                             background: Container(
                               alignment: Alignment.centerRight,
                               padding: const EdgeInsets.only(right: 20),
                               color: Colors.red,
                               child: const Icon(Icons.delete, color: Colors.white),
                             ),
                             onDismissed: (_) {
                               ref.read(transactionsProvider.notifier).deleteTransaction(t.id);
                             },
                             child: ListTile(
                               leading: CircleAvatar(
                                 backgroundColor: displayColor.withOpacity(0.2),
                                 child: Icon(
                                   displayIcon,
                                   color: displayColor,
                                   size: 20,
                                 ),
                               ),
                               title: Text(t.title, style: const TextStyle(color: Colors.white)),
                               subtitle: Text(
                                 '${DateFormat('dd MMM', 'tr_TR').format(t.date)} • ${t.category}', 
                                 style: const TextStyle(color: Colors.grey)
                               ),
                               trailing: Text(
                                 '${isIncome ? '+' : '-'}${ref.watch(appSettingsProvider).isPrivacyMode ? '***' : format.format(t.amount).replaceAll('₺', '')}₺',
                                 style: TextStyle(
                                   color: displayColor,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                 ),
                               ),
                             ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
