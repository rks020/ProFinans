import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    final transactions = ref.watch(transactionsProvider);
    final settings = ref.watch(appSettingsProvider);
    final currencySymbol = settings.selectedCurrency;

    // Filter transactions by year
    final yearTransactions = transactions.where((t) => t.date.year == _selectedYear).toList();

    // Data Processing
    final monthlyStats = _calculateMonthlyStats(yearTransactions);
    final topExpenseMonth = _findTopMonth(monthlyStats['expense']!);
    final topGrowthMonth = _findTopGrowthMonth(monthlyStats);
    final topCategory = _findTopCategory(yearTransactions);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Yıllık Analiz Raporu'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          DropdownButton<int>(
            dropdownColor: AppTheme.surfaceColor,
            value: _selectedYear,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.futureColor),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          const SizedBox(width: 16),
        ],
      ),
      body: yearTransactions.isEmpty
          ? Center(
              child: Text(
                '$_selectedYear yılına ait veri bulunamadı.',
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                          title: 'En Çok Harcanan Ay',
                          value: '${_getMonthName(topExpenseMonth.key)}\n${_formatCurrency(topExpenseMonth.value, currencySymbol)}',
                          icon: Icons.calendar_month,
                          color: AppTheme.expenseColor,
                        ),
                        const SizedBox(width: 12),
                        _SummaryCard(
                          title: 'En Yüksek Artan Gelir',
                          value: '${_getMonthName(topGrowthMonth.key)}\n${_formatCurrency(topGrowthMonth.value, currencySymbol)}',
                          icon: Icons.trending_up,
                          color: AppTheme.incomeColor,
                        ),
                        const SizedBox(width: 12),
                        if (topCategory != null)
                          _SummaryCard(
                            title: 'En Çok Harcanan Kategori',
                            value: '${topCategory.key}\n${_formatCurrency(topCategory.value, currencySymbol)}',
                            icon: Icons.category,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Monthly Chart ---
                  const Text('Aylık Gelir - Gider',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _getMonthNameShort(value.toInt()),
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis numbers for clean look
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(12, (index) {
                          final month = index + 1;
                          final income = monthlyStats['income']![month] ?? 0;
                          final expense = monthlyStats['expense']![month] ?? 0;
                          return BarChartGroupData(
                            x: month,
                            barRods: [
                              BarChartRodData(toY: income, color: AppTheme.incomeColor, width: 6),
                              BarChartRodData(toY: expense, color: AppTheme.expenseColor, width: 6),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Category Pie Chart ---
                  const Text('Kategori Bazlı Harcama',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _CategoryPieChart(transactions: yearTransactions, currencySymbol: currencySymbol),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Map<String, Map<int, double>> _calculateMonthlyStats(List<Transaction> transactions) {
    final income = <int, double>{};
    final expense = <int, double>{};

    for (var t in transactions) {
      final month = t.date.month;
      if (t.type == TransactionType.income) {
        income[month] = (income[month] ?? 0) + t.amount;
      } else {
        expense[month] = (expense[month] ?? 0) + t.amount;
      }
    }
    return {'income': income, 'expense': expense};
  }

  MapEntry<int, double> _findTopMonth(Map<int, double> stats) {
    if (stats.isEmpty) return const MapEntry(0, 0);
    return stats.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  MapEntry<int, double> _findTopGrowthMonth(Map<String, Map<int, double>> stats) {
    final income = stats['income']!;
    final expense = stats['expense']!;
    final growth = <int, double>{};

    for (int i = 1; i <= 12; i++) {
      final inc = income[i] ?? 0;
      final exp = expense[i] ?? 0;
      if (inc > 0 || exp > 0) {
        growth[i] = inc - exp;
      }
    }

    if (growth.isEmpty) return const MapEntry(0, 0);
    // Find max growth (can be negative if all months are loss, but usually we want "best" month)
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
    return NumberFormat.currency(locale: 'tr_TR', symbol: symbol, decimalDigits: 0).format(value);
  }

  String _getMonthName(int month) {
    if (month == 0) return '-';
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month];
  }

  String _getMonthNameShort(int month) {
    if (month == 0) return '-';
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return months[month];
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String currencySymbol;

  const _CategoryPieChart({required this.transactions, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{};
    final categoryColors = <String, int>{};

    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        categories[t.category] = (categories[t.category] ?? 0) + t.amount;
        categoryColors[t.category] = t.colorCode;
      }
    }

    // Sort by amount desc and take top 5, others grouped
    var sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) {
      return const Center(child: Text('Veri yok', style: TextStyle(color: Colors.grey)));
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sortedEntries.map((e) {
                final isOther = false; // logic for "Other" can be added if needed
                return PieChartSectionData(
                  color: Color(categoryColors[e.key] ?? 0xFF9E9E9E),
                  value: e.value,
                  title: '${((e.value / categories.values.reduce((a,b)=>a+b)) * 100).toInt()}%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  showTitle: true,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final e = sortedEntries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
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
