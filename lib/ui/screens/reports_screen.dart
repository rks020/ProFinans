import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../../data/services/export_service.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  String? _selectedCategory;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionsProvider);
    final settings = ref.watch(appSettingsProvider);
    
    // Filtreleme
    final filteredTransactions = allTransactions.where((t) {
      final isWithinDate = t.date.isAfter(_startDate.subtract(Duration(seconds: 1))) && 
                           t.date.isBefore(_endDate.add(Duration(days: 1)));
      final matchesCategory = _selectedCategory == null || t.category == _selectedCategory;
      return t.groupId == settings.activeGroupId && isWithinDate && matchesCategory;
    }).toList();

    // Özet Hesaplama
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categorySummary = {};

    for (var t in filteredTransactions) {
      if (t.type == TransactionType.income) totalIncome += t.amount;
      if (t.type == TransactionType.expense) {
        totalExpense += t.amount;
        categorySummary[t.category] = (categorySummary[t.category] ?? 0) + t.amount;
      }
    }

    final categories = allTransactions
        .where((t) => t.groupId == settings.activeGroupId)
        .map((t) => t.category)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('reports.title'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDateRangePicker(),
            SizedBox(height: 16),
            _buildCategoryFilter(categories),
            SizedBox(height: 32),
            _buildSummaryCard(totalIncome, totalExpense, settings),
            SizedBox(height: 32),
            _buildExportSection(filteredTransactions, categorySummary, settings),
            if (_isExporting)
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator(color: AppTheme.futureColor)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('reports.date_range'.tr(), style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  child: _buildDateBox('reports.start'.tr(), _startDate),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  child: _buildDateBox('reports.end'.tr(), _endDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 10)),
        SizedBox(height: 4),
        Text(
          DateFormat('dd MMM yyyy', context.locale.languageCode).format(date),
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String?>(
        value: _selectedCategory,
        dropdownColor: AppTheme.surfaceColor,
        isExpanded: true,
        underline: SizedBox(),
        hint: Text('reports.all_categories'.tr(), style: TextStyle(color: Colors.white70)),
        icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.futureColor),
        items: [
          DropdownMenuItem<String?>(value: null, child: Text('reports.all_categories'.tr(), style: TextStyle(color: Colors.white))),
          ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: Colors.white)))),
        ],
        onChanged: (val) => setState(() => _selectedCategory = val),
      ),
    );
  }

  Widget _buildSummaryCard(double income, double expense, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.futureColor, AppTheme.futureColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.futureColor.withValues(alpha: 0.3), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('reports.total_income'.tr(), income, Colors.white, settings),
          Divider(color: Colors.white24, height: 24),
          _buildSummaryRow('reports.total_expense'.tr(), expense, Colors.white, settings),
          Divider(color: Colors.white24, height: 24),
          _buildSummaryRow('reports.net_status'.tr(), income - expense, Colors.white, settings, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, AppSettings settings, {bool isBold = false}) {
    final displaySymbol = settings.selectedCurrency == 'TRY' ? '₺' : (settings.selectedCurrency == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(symbol: displaySymbol, decimalDigits: 0, locale: context.locale.languageCode);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 16)),
        Text(
          format.format(amount),
          style: TextStyle(color: color, fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildExportSection(List<Transaction> transactions, Map<String, double> categorySummary, AppSettings settings) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.search_off, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text('reports.no_transactions'.tr(), style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildExportButton(
          'reports.create_pdf'.tr(),
          Icons.picture_as_pdf,
          Colors.redAccent,
          () => _handleExport(() {
            final displaySymbol = settings.selectedCurrency == 'TRY' ? '₺' : (settings.selectedCurrency == 'USD' ? '\$' : '€');
            return ExportService.exportToPDF(
              transactions: transactions,
              start: _startDate,
              end: _endDate,
              categorySummary: categorySummary,
              currencySymbol: displaySymbol,
            );
          }),
        ),
        SizedBox(height: 12),
        _buildExportButton(
          'reports.get_excel'.tr(),
          Icons.table_view,
          Colors.greenAccent,
          () => _handleExport(() => ExportService.exportToExcel(
                transactions: transactions,
                start: _startDate,
                end: _endDate,
              )),
        ),
        SizedBox(height: 12),
        _buildExportButton(
          'reports.csv_export'.tr(),
          Icons.code,
          Colors.blueAccent,
          () => _handleExport(() => ExportService.exportToCSV(transactions: transactions)),
        ),
      ],
    );
  }

  Widget _buildExportButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: _isExporting ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 16),
            Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.futureColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleExport(Future<void> Function() exportFn) async {
    setState(() => _isExporting = true);
    try {
      await exportFn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reports.error'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
