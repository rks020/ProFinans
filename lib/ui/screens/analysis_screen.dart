import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../../data/services/currency_service.dart';
import '../theme/app_theme.dart';
import '../widgets/date_selector.dart';
import '../widgets/transaction_detail_modal.dart';
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
    final selectedDate = ref.watch(selectedDateProvider);
    
    // Use the global selected date for filtering in Analysis screen
    final allTransactions = ref.watch(allGroupTransactionsProvider);
    final transactions = allTransactions.where((t) => 
      t.date.year == selectedDate.year && 
      t.date.month == selectedDate.month
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('analysis.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_remove_outlined),
            tooltip: 'analysis.data_clean'.tr(),
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
                : _buildTrendView(transactions, selectedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleButton(0, 'analysis.flow'.tr(), Icons.account_tree_outlined)),
          Expanded(child: _toggleButton(1, 'analysis.chart'.tr(), Icons.bar_chart_outlined)),
        ],
      ),
    );
  }

  Widget _toggleButton(int index, String label, IconData icon) {
    final isSelected = _viewIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _viewIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0D47A1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
            SizedBox(width: 8),
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
    final expenseCountMap = <String, int>{};
    final investmentCountMap = <String, int>{};

    final appSettings = ref.watch(appSettingsProvider);
    final currencySymbol = appSettings.selectedCurrency;
    final AsyncValue<Map<String, CurrencyRate>> ratesAsync = ref.watch(currencyRatesProvider);
    final rates = ratesAsync.value;

    for (var t in transactions) {
      double amount = t.amount;
      if (currencySymbol != 'TRY' && rates != null) {
        if (t.currency == currencySymbol && t.originalAmount != null) {
          amount = t.originalAmount!;
        } else {
          final rate = rates[currencySymbol]?.buying ?? 1.0;
          amount = t.amount / rate;
        }
      }

      colorMap[t.category] = Color(t.colorCode);
      if (t.type == TransactionType.income) {
        income += amount;
        incomeMap[t.category] = (incomeMap[t.category] ?? 0) + amount;
      } else if (t.type == TransactionType.investment) {
        investments += amount;
        investmentMap[t.category] = (investmentMap[t.category] ?? 0) + amount;
        investmentCountMap[t.category] = (investmentCountMap[t.category] ?? 0) + 1;
      } else {
        expenses += amount;
        expenseMap[t.category] = (expenseMap[t.category] ?? 0) + amount;
        expenseCountMap[t.category] = (expenseCountMap[t.category] ?? 0) + 1;
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
      color: colorMap[e.key] ?? Color(0xFFFFD700),
    )).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final settings = ref.watch(appSettingsProvider);
    final isPrivacyMode = settings.isPrivacyMode;
    final displaySymbol = settings.selectedCurrency == 'TRY' ? '₺' : (settings.selectedCurrency == 'USD' ? '\$' : '€');
    final currencyFormat = NumberFormat.currency(
      locale: context.locale.toString(), 
      symbol: displaySymbol, 
      decimalDigits: 0
    );

    // Dynamic height - no max cap so everything is visible
    final leftItems = incomeBreakdown.length;
    final rightItems = expenseBreakdown.length + investmentBreakdown.length + (income - expenses - investments > 0 ? 1 : 0);
    final maxSideItems = leftItems > rightItems ? leftItems : rightItems;
    
    final minHeight = 350.0;
    final calculatedHeight = maxSideItems * 40.0 + 80.0; 
    final chartHeight = calculatedHeight < minHeight ? minHeight : calculatedHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SankeyFlowChart(
          height: chartHeight,
          income: income,
          expenses: expenses,
          investments: investments,
          incomeBreakdown: incomeBreakdown,
          expenseBreakdown: expenseBreakdown,
          investmentBreakdown: investmentBreakdown,
          isPrivacyMode: isPrivacyMode,
          currencySymbol: displaySymbol,
        ),
        SizedBox(height: 24),
        // --- Gider Detayları ---
        if (expenseBreakdown.isNotEmpty) ...[
          Text(
            'analysis.expense_details'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 12),
          ...expenseBreakdown.map((cat) {
            final count = expenseCountMap[cat.name] ?? 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: cat.color, borderRadius: BorderRadius.circular(3)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${cat.name.tr()} x $count',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  Text(
                    isPrivacyMode ? '***$currencySymbol' : currencyFormat.format(cat.amount),
                    style: TextStyle(color: cat.color, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            );
          }),
          Divider(color: Colors.white24, height: 16),
          Row(
            children: [
              Expanded(
                child: Text('analysis.total_expense'.tr(), style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              Text(
                isPrivacyMode ? '***$currencySymbol' : currencyFormat.format(expenses),
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
        // --- Yatırım Detayları ---
        if (investmentBreakdown.isNotEmpty) ...[
          SizedBox(height: 20),
          Text(
            'analysis.investment_details'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 12),
          ...investmentBreakdown.map((cat) {
            final count = investmentCountMap[cat.name] ?? 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: cat.color, borderRadius: BorderRadius.circular(3)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${cat.name.tr()} x $count',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  Text(
                    isPrivacyMode ? '***$currencySymbol' : currencyFormat.format(cat.amount),
                    style: TextStyle(color: cat.color, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            );
          }),
          Divider(color: Colors.white24, height: 16),
          Row(
            children: [
              Expanded(
                child: Text('analysis.total_investment'.tr(), style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              Text(
                isPrivacyMode ? '***$currencySymbol' : currencyFormat.format(investments),
                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
        // --- Genel Toplam ---
        if (expenseBreakdown.isNotEmpty || investmentBreakdown.isNotEmpty) ...[
          SizedBox(height: 16),
          Divider(color: Colors.white38, height: 16, thickness: 1.5),
          Row(
            children: [
              Expanded(
                child: Text('analysis.total_spending'.tr(), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Text(
                isPrivacyMode ? '***$currencySymbol' : currencyFormat.format(expenses + investments),
                style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          // --- Negatif gelir uyarısı ---
          if (income - expenses - investments < 0) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPrivacyMode 
                          ? 'analysis.income_warning'.tr(namedArgs: {'amount': '***$currencySymbol'}) 
                          : 'analysis.income_warning'.tr(namedArgs: {'amount': currencyFormat.format((expenses + investments - income).abs())}),
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTrendView(List<Transaction> transactions, DateTime selectedDate) {
    final monthName = DateFormat('MMMM', context.locale.languageCode).format(selectedDate);
    final yearStr = selectedDate.year.toString();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'analysis.monthly_data'.tr(namedArgs: {'month': monthName, 'year': yearStr}), 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 350,
          child: _TrendChart(selectedDate: selectedDate),
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
  final DateTime selectedDate;

  const _TrendChart({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(allGroupTransactionsProvider);
    if (transactions.isEmpty) return Center(child: Text("analysis.no_data".tr(), style: const TextStyle(color: Colors.grey)));

    final appSettings = ref.watch(appSettingsProvider);
    final currencySymbol = appSettings.selectedCurrency;
    final AsyncValue<Map<String, CurrencyRate>> ratesAsync = ref.watch(currencyRatesProvider);
    final rates = ratesAsync.value;
    final isPrivacyMode = appSettings.isPrivacyMode;

    // Generate data for the last 6 months
    final last6Months = List.generate(6, (i) {
      final date = DateTime(DateTime.now().year, DateTime.now().month - 5 + i, 1);
      final monthTrans = transactions.where((t) => 
        t.date.year == date.year && t.date.month == date.month
      );
      
      double income = 0;
      double expense = 0;
      double investment = 0;

      for (var t in monthTrans) {
        double amount = t.amount;
        if (currencySymbol != 'TRY' && rates != null) {
          if (t.currency == currencySymbol && t.originalAmount != null) {
            amount = t.originalAmount!;
          } else {
            final rate = rates[currencySymbol]?.buying ?? 1.0;
            amount = t.amount / rate;
          }
        }

        if (t.type == TransactionType.income) {
          income += amount;
        } else if (t.type == TransactionType.expense) {
          expense += amount;
        } else if (t.type == TransactionType.investment) {
          investment += amount;
        }
      }
      
      return {
        'month': DateFormat('MMM', context.locale.languageCode).format(date),
        'income': income,
        'expense': expense,
        'investment': investment,
        'savings': income - (expense + investment),
      };
    });

    double maxY = 0;
    for (var m in last6Months) {
      final vals = [m['income'] as double, m['expense'] as double, m['investment'] as double, (m['savings'] as double).abs()];
      for (var v in vals) if (v > maxY) maxY = v;
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 1000;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppTheme.surfaceColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final type = rodIndex == 0 ? 'transactions.income'.tr() : 
                                (rodIndex == 1 ? 'transactions.expense'.tr() : 
                                (rodIndex == 2 ? 'transactions.investment'.tr() : 'analysis.savings'.tr()));
                    final displaySymbol = currencySymbol == 'TRY' ? '₺' : (currencySymbol == 'USD' ? '\$' : '€');
                    final value = isPrivacyMode 
                        ? '***$displaySymbol' 
                        : NumberFormat.currency(symbol: displaySymbol, decimalDigits: 0, locale: context.locale.languageCode).format(rod.toY);
                    return BarTooltipItem(
                      '$type\n$value',
                      TextStyle(color: rod.gradient?.colors.first ?? rod.color, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      if (val.toInt() < 0 || val.toInt() >= last6Months.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          last6Months[val.toInt()]['month'] as String,
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (val, meta) {
                      if (val == 0 || isPrivacyMode) return const SizedBox();
                      return Text(
                        NumberFormat.compact(locale: context.locale.languageCode).format(val),
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
              barGroups: last6Months.asMap().entries.map((entry) {
                final i = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(toY: data['income'] as double, color: AppTheme.incomeColor, width: 6),
                    BarChartRodData(toY: data['expense'] as double, color: AppTheme.expenseColor, width: 6),
                    BarChartRodData(toY: data['investment'] as double, color: const Color(0xFFFFD700), width: 6),
                    BarChartRodData(toY: (data['savings'] as double).clamp(0.0, double.infinity), color: Colors.cyanAccent, width: 6),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _LegendItem(color: AppTheme.incomeColor, label: 'transactions.income'.tr()),
            _LegendItem(color: AppTheme.expenseColor, label: 'transactions.expense'.tr()),
            _LegendItem(color: const Color(0xFFFFD700), label: 'transactions.investment'.tr()),
            _LegendItem(color: Colors.cyanAccent, label: 'analysis.savings'.tr()),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

class _AuditListModal extends ConsumerWidget {
  final List<Transaction> transactions;

  const _AuditListModal({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final currencySymbol = appSettings.selectedCurrency;
    final AsyncValue<Map<String, CurrencyRate>> ratesAsync = ref.watch(currencyRatesProvider);
    final isPrivacyMode = appSettings.isPrivacyMode;
    final displaySymbol = currencySymbol == 'TRY' ? '₺' : (currencySymbol == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(symbol: displaySymbol, decimalDigits: 0, locale: context.locale.languageCode);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('analysis.data_list_all'.tr(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
                ],
              ),
              Divider(),
              Expanded(
                child: transactions.isEmpty 
                    ? Center(child: Text('analysis.no_data_this_month'.tr(), style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        controller: controller,
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final isIncome = t.type == TransactionType.income;
                          final isInvestment = t.type == TransactionType.investment;
                          
                          Color displayColor = isIncome 
                              ? AppTheme.incomeColor 
                              : (isInvestment ? Color(0xFFFFD700) : AppTheme.expenseColor);
                          
                          IconData displayIcon = isIncome 
                              ? Icons.arrow_downward 
                              : (isInvestment ? Icons.savings : Icons.arrow_upward);

                          double displayAmount = t.amount;
                          if (currencySymbol != 'TRY') {
                            if (t.currency == currencySymbol && t.originalAmount != null) {
                              displayAmount = t.originalAmount!;
                            } else {
                              final rates = ratesAsync.value;
                              if (rates != null) {
                                final rate = rates[currencySymbol]?.buying ?? 1.0;
                                displayAmount = t.amount / rate;
                              }
                            }
                          }

                          return Dismissible(
                             key: Key(t.id),
                             direction: DismissDirection.endToStart,
                             background: Container(
                               alignment: Alignment.centerRight,
                               padding: EdgeInsets.only(right: 20),
                               color: Colors.red,
                               child: Icon(Icons.delete, color: Colors.white),
                             ),
                             onDismissed: (_) {
                               ref.read(transactionsProvider.notifier).deleteTransaction(t.id);
                             },
                             child: ListTile(
                               onTap: () {
                                 showModalBottomSheet(
                                   context: context,
                                   isScrollControlled: true,
                                   backgroundColor: Colors.transparent,
                                   builder: (context) => TransactionDetailModal(transaction: t),
                                 );
                               },
                               leading: CircleAvatar(
                                 backgroundColor: displayColor.withValues(alpha: 0.2),
                                 child: Icon(
                                   displayIcon,
                                   color: displayColor,
                                   size: 20,
                                 ),
                               ),
                               title: Text(t.title, style: TextStyle(color: Colors.white)),
                               subtitle: Text(
                                 '${DateFormat('dd MMM', context.locale.languageCode).format(t.date)} • ${t.category.tr()}', 
                                 style: TextStyle(color: Colors.grey)
                               ),
                               trailing: Text(
                                 '${isIncome ? '+' : '-'}${isPrivacyMode ? '*** $currencySymbol' : format.format(displayAmount)}',
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
