import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../theme/app_theme.dart';

class YearlyAnalysisScreen extends ConsumerStatefulWidget {
  const YearlyAnalysisScreen({super.key});

  @override
  ConsumerState<YearlyAnalysisScreen> createState() => _YearlyAnalysisScreenState();
}

class _YearlyAnalysisScreenState extends ConsumerState<YearlyAnalysisScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(allGroupTransactionsProvider);
    final settings = ref.watch(appSettingsProvider);
    final currencySymbol = settings.selectedCurrency;
    final displaySymbol = currencySymbol == 'TRY' ? '₺' : (currencySymbol == 'USD' ? '\$' : '€');

    // Filter transactions by year
    final yearTransactions = transactions.where((t) => t.date.year == _selectedYear).toList();

    // Data Processing
    final monthlyStats = _calculateMonthlyStats(yearTransactions);
    final topExpenseMonth = _findTopMonth(monthlyStats['expense']!);
    final topInvestmentMonth = _findTopMonth(monthlyStats['investment']!);
    final topGrowthMonth = _findTopGrowthMonth(monthlyStats);
    final topCategory = _findTopCategory(yearTransactions);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('yearly_analysis.title'.tr()),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          DropdownButton<int>(
            dropdownColor: AppTheme.surfaceColor,
            value: _selectedYear,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.futureColor),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            items: List.generate(5, (index) => DateTime.now().year - index)
                .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text('$year'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedYear = value);
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: yearTransactions.isEmpty
          ? Center(
              child: Text(
                'yearly_analysis.no_data'.tr(namedArgs: {'year': _selectedYear.toString()}),
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Summary Cards ---
                  SizedBox(
                    height: 160, // Increased height to prevent overflow
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _SummaryCard(
                          title: 'yearly_analysis.top_expense_month'.tr(),
                          value: '${_getMonthName(topExpenseMonth.key)}\n${settings.isPrivacyMode ? '***$displaySymbol' : _formatCurrency(topExpenseMonth.value, displaySymbol)}',
                          icon: Icons.calendar_month,
                          color: AppTheme.expenseColor,
                        ),
                        SizedBox(width: 12),
                        if (topInvestmentMonth.value > 0) ...[
                          _SummaryCard(
                            title: 'yearly_analysis.top_investment_month'.tr(),
                            value: '${_getMonthName(topInvestmentMonth.key)}\n${settings.isPrivacyMode ? '***$displaySymbol' : _formatCurrency(topInvestmentMonth.value, displaySymbol)}',
                            icon: Icons.savings,
                            color: Color(0xFFFFD700),
                          ),
                          SizedBox(width: 12),
                        ],
                        _SummaryCard(
                          title: 'yearly_analysis.top_growth_month'.tr(),
                          value: '${_getMonthName(topGrowthMonth.key)}\n${settings.isPrivacyMode ? '***$displaySymbol' : _formatCurrency(topGrowthMonth.value, displaySymbol)}',
                          icon: Icons.trending_up,
                          color: AppTheme.incomeColor,
                        ),
                        SizedBox(width: 12),
                        if (topCategory != null)
                          _SummaryCard(
                            title: 'yearly_analysis.top_category'.tr(),
                            value: '${topCategory.key}\n${settings.isPrivacyMode ? '***$displaySymbol' : _formatCurrency(topCategory.value, displaySymbol)}',
                            icon: Icons.category,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // --- Monthly Chart ---
                  Text('yearly_analysis.chart_title'.tr(),
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Container(
                    height: 250,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: false),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppTheme.surfaceColor,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final settings = ref.watch(appSettingsProvider);
                              final isPrivacyMode = settings.isPrivacyMode;
                              final currencySymbol = settings.selectedCurrency;
                              final displaySymbol = currencySymbol == 'TRY' ? '₺' : (currencySymbol == 'USD' ? '\$' : '€');
                              
                              final type = rodIndex == 0 ? 'transactions.income'.tr() : (rodIndex == 1 ? 'transactions.expense'.tr() : 'transactions.investment'.tr());
                              final value = isPrivacyMode 
                                  ? '***$displaySymbol' 
                                  : NumberFormat.currency(symbol: displaySymbol, decimalDigits: 0, locale: context.locale.languageCode).format(rod.toY);
                              return BarTooltipItem(
                                '$type\n$value',
                                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _getMonthNameShort(value.toInt()),
                                    style: TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis numbers for clean look
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(12, (index) {
                          final month = index + 1;
                          final income = monthlyStats['income']![month] ?? 0;
                          final expense = monthlyStats['expense']![month] ?? 0;
                          final investment = monthlyStats['investment']![month] ?? 0;
                          return BarChartGroupData(
                            x: month,
                            barRods: [
                              BarChartRodData(toY: income, color: AppTheme.incomeColor, width: 6),
                              BarChartRodData(toY: expense, color: AppTheme.expenseColor, width: 6),
                              if (investment > 0)
                                BarChartRodData(toY: investment, color: Color(0xFFFFD700), width: 6),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // --- Category Pie Chart ---
                  Text('yearly_analysis.expense_by_category'.tr(),
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Container(
                    height: 400,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _CategoryPieChart(
                      transactions: yearTransactions, 
                      currencySymbol: currencySymbol,
                      isPrivacyMode: settings.isPrivacyMode,
                    ),
                  ),
                  SizedBox(height: 32),

                  // --- Investment Pie Chart ---
                   if (monthlyStats['investment']!.isNotEmpty && monthlyStats['investment']!.values.any((v) => v > 0)) ...[
                    Text('yearly_analysis.investment_by_category'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Container(
                      height: 400,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _CategoryPieChart(
                        transactions: yearTransactions, 
                        currencySymbol: currencySymbol, 
                        type: TransactionType.investment,
                        isPrivacyMode: settings.isPrivacyMode,
                      ),
                    ),
                    SizedBox(height: 50),
                   ],
                ],
              ),
            ),
    );
  }

  Map<String, Map<int, double>> _calculateMonthlyStats(List<Transaction> transactions) {
    final income = <int, double>{};
    final expense = <int, double>{};
    final investment = <int, double>{};

    for (var t in transactions) {
      final month = t.date.month;
      if (t.type == TransactionType.income) {
        income[month] = (income[month] ?? 0) + t.amount;
      } else if (t.type == TransactionType.investment) {
        investment[month] = (investment[month] ?? 0) + t.amount;
      } else {
        expense[month] = (expense[month] ?? 0) + t.amount;
      }
    }
    return {'income': income, 'expense': expense, 'investment': investment};
  }

  MapEntry<int, double> _findTopMonth(Map<int, double> stats) {
    if (stats.isEmpty) return MapEntry(0, 0);
    return stats.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  MapEntry<int, double> _findTopGrowthMonth(Map<String, Map<int, double>> stats) {
    final income = stats['income']!;
    final expense = stats['expense']!;
    final investment = stats['investment']!;
    final growth = <int, double>{};

    for (int i = 1; i <= 12; i++) {
      final inc = income[i] ?? 0;
      final exp = expense[i] ?? 0;
      final inv = investment[i] ?? 0;
      // Artan Gelir = Gelir - Gider - Yatırım (net kalan)
      if (inc > 0 || exp > 0 || inv > 0) {
        final net = inc - exp - inv;
        if (net > 0) {
          growth[i] = net;
        }
      }
    }

    if (growth.isEmpty) return MapEntry(0, 0);
    return growth.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  MapEntry<String, double>? _findTopCategory(List<Transaction> transactions) {
    final categories = <String, double>{};
    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        categories[t.category] = (categories[t.category] ?? 0) + t.amount;
      }
    }
    if (categories.isEmpty) return null;
    return categories.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  String _formatCurrency(double value, String symbol) {
    return NumberFormat.currency(locale: context.locale.languageCode, symbol: symbol, decimalDigits: 0).format(value);
  }

  String _getMonthName(int month) {
    if (month == 0) return '-';
    final date = DateTime(_selectedYear, month, 1);
    return DateFormat('MMMM', context.locale.languageCode).format(date);
  }

  String _getMonthNameShort(int month) {
    if (month == 0) return '-';
    final date = DateTime(_selectedYear, month, 1);
    return DateFormat('MMM', context.locale.languageCode).format(date);
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          Spacer(),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String currencySymbol;
  final TransactionType type;
  final bool isPrivacyMode;

  const _CategoryPieChart({
    required this.transactions, 
    required this.currencySymbol,
    this.type = TransactionType.expense,
    required this.isPrivacyMode,
  });

  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{};
    final categoryColors = <String, int>{};

    for (var t in transactions) {
      if (t.type == type) {
        categories[t.category] = (categories[t.category] ?? 0) + t.amount;
        categoryColors[t.category] = t.colorCode;
      }
    }

    // Sort by amount desc and take top 5, others grouped
    var sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) {
      return Center(child: Text('yearly_analysis.no_pie_data'.tr(), style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sortedEntries.map((e) {
                final total = categories.values.reduce((a,b)=>a+b);
                final pct = (e.value / total) * 100;
                return PieChartSectionData(
                  color: Color(categoryColors[e.key] ?? 0xFF9E9E9E),
                  value: e.value,
                  title: pct >= 5 ? '${pct.toInt()}%\n${e.key}' : '',
                  radius: 50,
                  titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  showTitle: pct >= 5,
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final e = sortedEntries[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(categoryColors[e.key] ?? 0xFF9E9E9E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final currencyCode = ref.watch(appSettingsProvider).selectedCurrency;
                            final displaySymbol = currencyCode == 'TRY' ? '₺' : (currencyCode == 'USD' ? '\$' : '€');
                            final format = NumberFormat.currency(locale: context.locale.languageCode, symbol: '', decimalDigits: 0);
                            final amountStr = format.format(e.value).trim();
                            
                            return Text(
                               isPrivacyMode
                                  ? '${e.key} - *** $displaySymbol'
                               : '${e.key} - $amountStr $displaySymbol',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
