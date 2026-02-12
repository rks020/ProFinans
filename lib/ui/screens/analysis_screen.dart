import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sankey_flutter/sankey.dart';
import 'package:sankey_flutter/sankey_node.dart';
import 'package:sankey_flutter/sankey_link.dart';
import 'package:sankey_flutter/sankey_helpers.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../theme/app_theme.dart';

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
      appBar: AppBar(title: const Text('Analiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return _FlowAnimation(
              child: SizedBox(
                height: 400,
                width: constraints.maxWidth,
                child: _SankeyDiagram(transactions: transactions, width: constraints.maxWidth),
              ),
            );
          },
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
}

class _SankeyDiagram extends StatelessWidget {
  final List<Transaction> transactions;
  final double width;

  const _SankeyDiagram({required this.transactions, required this.width});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const Center(child: Text('Veri yok'));

    final incomeByCat = <String, double>{};
    final expenseByCat = <String, double>{};
    final catColors = <String, Color>{};

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        incomeByCat[t.category] = (incomeByCat[t.category] ?? 0) + t.amount;
        catColors[t.category] = Color(t.colorCode);
      } else {
        expenseByCat[t.category] = (expenseByCat[t.category] ?? 0) + t.amount;
        catColors[t.category] = Color(t.colorCode);
      }
    }

    final totalIncome = incomeByCat.values.fold(0.0, (a, b) => a + b);
    final totalExpense = expenseByCat.values.fold(0.0, (a, b) => a + b);
    
    if (totalIncome == 0 && totalExpense == 0) return const Center(child: Text('Diyagram için yetersiz veri'));

    final nodes = <SankeyNode>[];
    final links = <SankeyLink>[];
    final platformNodeColors = <String, Color>{};

    final format = NumberFormat.currency(symbol: '₺', decimalDigits: 0);

    // Middle Node
    final totalIncomeNode = SankeyNode(
      id: 'total_income', 
      label: 'Toplam Gelir\n${format.format(totalIncome).replaceAll('₺', '')}₺'
    );
    nodes.add(totalIncomeNode);
    platformNodeColors['total_income'] = const Color(0xFF0D47A1);

    // Left Nodes (Income Sources)
    for (var entry in incomeByCat.entries) {
      final node = SankeyNode(
        id: 'inc_${entry.key}', 
        label: '${entry.key}\n${format.format(entry.value).replaceAll('₺', '')}₺'
      );
      nodes.add(node);
      platformNodeColors['inc_${entry.key}'] = catColors[entry.key] ?? AppTheme.incomeColor;
      links.add(SankeyLink(source: node, target: totalIncomeNode, value: entry.value));
    }

    // Right Nodes (Expenses)
    for (var entry in expenseByCat.entries) {
      final node = SankeyNode(
        id: 'exp_${entry.key}', 
        label: '${entry.key}\n${format.format(entry.value).replaceAll('₺', '')}₺'
      );
      nodes.add(node);
      platformNodeColors['exp_${entry.key}'] = catColors[entry.key] ?? AppTheme.expenseColor;
      links.add(SankeyLink(source: totalIncomeNode, target: node, value: entry.value));
    }

    // Balance Node (If any)
    final balance = totalIncome - totalExpense;
    if (balance > 0) {
      final balanceNode = SankeyNode(
        id: 'balance', 
        label: 'Artan Gelir\n${format.format(balance).replaceAll('₺', '')}₺'
      );
      nodes.add(balanceNode);
      platformNodeColors['balance'] = AppTheme.incomeColor;
      links.add(SankeyLink(source: totalIncomeNode, target: balanceNode, value: balance));
    }

    final dataSet = SankeyDataSet(nodes: nodes, links: links);
    final layoutEngine = generateSankeyLayout(
      width: width,
      height: 380,
      nodeWidth: 35,
      nodePadding: 25,
    );
    dataSet.layout(layoutEngine);

    return SankeyDiagramWidget(
      data: dataSet,
      size: Size(width, 380),
      nodeColors: platformNodeColors,
      showLabels: true,
      showTexture: false,
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<Transaction> transactions;

  const _TrendChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final last6Months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));

    final data = last6Months.map((month) {
      final monthlyTrans = transactions.where((t) => t.date.year == month.year && t.date.month == month.month);
      final income = monthlyTrans.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
      final expense = monthlyTrans.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
      return {'month': DateFormat('MMM').format(month), 'income': income, 'expense': expense};
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.fold(0.0, (max, d) => (d['income'] as double) > (d['expense'] as double) ? ((d['income'] as double) > max ? d['income'] as double : max) : ((d['expense'] as double) > max ? d['expense'] as double : max)) * 1.2,
        barGroups: List.generate(data.length, (index) {
          final item = data[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: item['income'] as double, color: AppTheme.incomeColor, width: 8),
              BarChartRodData(toY: item['expense'] as double, color: AppTheme.expenseColor, width: 8),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) => Text(data[val.toInt()]['month'] as String, style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _FlowAnimation extends StatefulWidget {
  final Widget child;
  const _FlowAnimation({required this.child});

  @override
  State<_FlowAnimation> createState() => _FlowAnimationState();
}

class _FlowAnimationState extends State<_FlowAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _widthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: _widthAnimation.value,
            child: ClipRect(
              child: SizedBox(
                width: MediaQuery.of(context).size.width, // Force specific width during animation
                child: widget.child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
