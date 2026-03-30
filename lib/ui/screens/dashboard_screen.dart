import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/app_group.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart'; 
import '../theme/app_theme.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/date_selector.dart';
import '../widgets/transaction_detail_modal.dart';
import '../widgets/add_goal_modal.dart';
import 'goals_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final dashboardData = ref.watch(expenseDashboardProvider);
    final investmentData = ref.watch(investmentDashboardProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GroupSelector(groups: groups, activeGroupId: appSettings.activeGroupId),
        actions: [
          IconButton(
            icon: Icon(appSettings.isPrivacyMode ? Icons.visibility_off_outlined : Icons.visibility_outlined), 
            onPressed: () => ref.watch(appSettingsProvider.notifier).togglePrivacyMode(),
          ),
          TextButton(
            child: Text(context.locale.languageCode == 'tr' ? '🇹🇷 TR' : '🇺🇸 EN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              final newLocale = context.locale.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
              context.setLocale(newLocale);
            },
          ),
          PopupMenuButton<String>(
            icon: Text(
              appSettings.selectedCurrency == 'TRY' ? '₺' : (appSettings.selectedCurrency == 'USD' ? '\$' : '€'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onSelected: (String currency) {
              ref.read(appSettingsProvider.notifier).updateCurrency(currency);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'TRY', child: Text('🇹🇷 ₺ TRY')),
              const PopupMenuItem<String>(value: 'USD', child: Text('🇺🇸 \$ USD')),
              const PopupMenuItem<String>(value: 'EUR', child: Text('🇪🇺 € EUR')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.add_circle, color: AppTheme.futureColor, size: 32),
              onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddTransactionModal(
                      initialDate: ref.watch(selectedDateProvider),
                      initialType: TransactionType.expense,
                      initialCurrency: ref.read(appSettingsProvider).selectedCurrency,
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
              padding: const EdgeInsets.all(16.0),
              child: VerticalSummaryCards(data: dashboardData),
            ),
            const GoalsSummaryHorizontal(),
            if (investmentData.values.any((l) => l.isNotEmpty)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("dashboard.investments".tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InvestmentSummaryCards(data: investmentData),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: _BottomSummary(),
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }
}

class GroupSelector extends ConsumerWidget {
  final List<AppGroup> groups;
  final String? activeGroupId;

  const GroupSelector({super.key, required this.groups, this.activeGroupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (groups.isEmpty) return Text('dashboard.default_group_name').tr();
    final activeGroup = groups.firstWhere(
      (g) => g.id == activeGroupId, 
      orElse: () => groups.first,
    );

    return PopupMenuButton<String>(
      onSelected: (id) => ref.watch(appSettingsProvider.notifier).updateActiveGroup(id),
      itemBuilder: (context) => groups.map((g) => PopupMenuItem<String>(value: g.id, child: Text(g.name))).toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(activeGroup.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

class VerticalSummaryCards extends StatelessWidget {
  final Map<String, List<Transaction>> data;

  const VerticalSummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VerticalSummaryCard(
          title: 'dashboard.status.delayed'.tr(),
          transactions: data['delayed'] ?? [],
          color: const Color(0xFF1A0F0F),
          textColor: AppTheme.expenseColor,
        ),
        const SizedBox(height: 12),
        VerticalSummaryCard(
          title: 'dashboard.status.paid'.tr(),
          transactions: data['paid'] ?? [],
          color: const Color(0xFF0F1A12),
          textColor: AppTheme.incomeColor,
        ),
        const SizedBox(height: 12),
        VerticalSummaryCard(
          title: 'dashboard.status.upcoming'.tr(),
          transactions: data['upcoming'] ?? [],
          color: const Color(0xFF0F141A),
          textColor: AppTheme.futureColor,
        ),
      ],
    );
  }
}

class InvestmentSummaryCards extends StatelessWidget {
  final Map<String, List<Transaction>> data;

  const InvestmentSummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (data['delayed']?.isNotEmpty == true)
          VerticalSummaryCard(
            title: 'dashboard.status.delayed_investment'.tr(),
            transactions: data['delayed'] ?? [],
            color: const Color(0xFF262000), 
            textColor: const Color(0xFFFFD700),
          ),
        if (data['delayed']?.isNotEmpty == true) const SizedBox(height: 12),
        
        VerticalSummaryCard(
          title: 'dashboard.status.completed_investment'.tr(),
          transactions: data['paid'] ?? [],
          color: const Color(0xFF262000), 
          textColor: const Color(0xFFFFD700),
        ),
        const SizedBox(height: 12),
        
        if (data['upcoming']?.isNotEmpty == true)
          VerticalSummaryCard(
            title: 'dashboard.status.planned_investment'.tr(),
            transactions: data['upcoming'] ?? [],
            color: const Color(0xFF1A1A1A),
            textColor: Colors.white70,
          ),
      ],
    );
  }
}

class VerticalSummaryCard extends ConsumerStatefulWidget {
  final String title;
  final List<Transaction> transactions;
  final Color color;
  final Color textColor;

  const VerticalSummaryCard({super.key, 
    required this.title,
    required this.transactions,
    required this.color,
    required this.textColor,
  });

  @override
  ConsumerState<VerticalSummaryCard> createState() => _VerticalSummaryCardState();
}

class _VerticalSummaryCardState extends ConsumerState<VerticalSummaryCard> {
  bool _isExpanded = true;
  final Set<String> _collapsedGroups = {}; 

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingsProvider);
    final ratesAsync = ref.watch(currencyRatesProvider);
    final isPrivacyMode = appSettings.isPrivacyMode;
    final currencySymbol = appSettings.selectedCurrency;
    final count = widget.transactions.length;

    // Convert total amount to selected currency
    double displayTotal = 0;
    if (currencySymbol == 'TRY') {
      displayTotal = widget.transactions.fold(0.0, (sum, t) => sum + t.amount);
    } else {
      ratesAsync.whenData((rates) {
        final rate = rates[currencySymbol]?.buying ?? 1.0;
        for (var t in widget.transactions) {
          if (t.currency == currencySymbol && t.originalAmount != null) {
            displayTotal += t.originalAmount!;
          } else {
            displayTotal += t.amount / rate;
          }
        }
      });
    }

    final displaySymbol = currencySymbol == 'TRY' ? '₺' : (currencySymbol == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0);
    final amountStr = isPrivacyMode ? '***$displaySymbol' : format.format(displayTotal);

    final groupedTransactions = <String, List<Transaction>>{};
    for (var t in widget.transactions) {
      final key = t.category.trim();
      if (!groupedTransactions.containsKey(key)) {
        groupedTransactions[key] = [];
      }
      groupedTransactions[key]!.add(t);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(amountStr, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Text(count.toString(), style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.chevron_right, 
                      color: Colors.grey
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            
            ...groupedTransactions.entries.map((entry) {
              final title = entry.key;
              final transactions = entry.value;
              
              double totalAmount = 0;
              if (currencySymbol == 'TRY') {
                totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);
              } else {
                final rates = ratesAsync.value;
                if (rates != null) {
                  final rate = rates[currencySymbol]?.buying ?? 1.0;
                  for (var t in transactions) {
                    if (t.currency == currencySymbol && t.originalAmount != null) {
                      totalAmount += t.originalAmount!;
                    } else {
                      totalAmount += t.amount / rate;
                    }
                  }
                }
              }
              
              final isCollapsed = _collapsedGroups.contains(title);
              
              final budgetStatus = ref.watch(categoryBudgetStatusProvider)[title];
              
              Widget content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isCollapsed) {
                          _collapsedGroups.remove(title);
                        } else {
                          _collapsedGroups.add(title);
                        }
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${title.tr()} (${transactions.length})", 
                              style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                              color: widget.textColor.withValues(alpha: 0.5),
                              size: 16,
                            ),
                          ],
                        ),
                        Text(
                          isPrivacyMode ? '***$currencySymbol' : format.format(totalAmount),
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (budgetStatus?.limit != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: budgetStatus!.percent,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budgetStatus.isOverBudget ? AppTheme.expenseColor : Color(budgetStatus.colorCode).withValues(alpha: 0.7)
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'dashboard.budget.used'.tr(namedArgs: {'percent': (budgetStatus.percent * 100).toStringAsFixed(0)}),
                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        ),
                        if (budgetStatus.isOverBudget)
                          Text(
                            'dashboard.budget.over'.tr(namedArgs: {'amount': format.format(budgetStatus.spent - budgetStatus.limit!)}),
                          style: TextStyle(color: AppTheme.expenseColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  if (!isCollapsed) ...[
                    const SizedBox(height: 8),
                    ...transactions.map((t) => _buildTransactionItem(t)),
                  ],
                ],
              );

              if (transactions.length == 1) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: content,
                );
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: content,
              );
            }),

          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction t) {
    final appSettings = ref.watch(appSettingsProvider);
    final currencySymbol = appSettings.selectedCurrency;
    final ratesAsync = ref.watch(currencyRatesProvider);
    
    double displayAmount = t.amount;
    if (currencySymbol != 'TRY') {
      if (t.currency == currencySymbol && t.originalAmount != null) {
        displayAmount = t.originalAmount!;
      } else {
        // Fallback to conversion from base TRY
        final rates = ratesAsync.value;
        if (rates != null) {
          final rate = rates[currencySymbol]?.buying ?? 1.0;
          displayAmount = t.amount / rate;
        }
      }
    }

    final displaySymbol = currencySymbol == 'TRY' ? '₺' : (currencySymbol == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0);
    final dateStr = DateFormat('dd MMM', context.locale.languageCode).format(t.date);
    final isPrivacyMode = appSettings.isPrivacyMode;
    final isNewlyAdded = ref.watch(lastAddedTransactionIdProvider) == t.id;

    return TweenAnimationBuilder<double>(
      key: ValueKey('${t.id}_$isNewlyAdded'),
      tween: Tween<double>(begin: isNewlyAdded ? 1.0 : 0.0, end: 0.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, animValue, child) {
        final bgColor = Color.lerp(
          Colors.white.withValues(alpha: 0.05), 
          AppTheme.futureColor.withValues(alpha: 0.8), 
          animValue
        ) ?? Colors.white.withValues(alpha: 0.05);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Dismissible(
            key: Key('dismiss_${t.id}'),
            direction: DismissDirection.horizontal,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.edit, color: Colors.blue),
            ),
            secondaryBackground: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _openEditModal(context, t);
                return false;
              } else {
                final result = await _showDeleteConfirmation(context);
                if (result == 'bulk') {
                  ref.watch(transactionsProvider.notifier).deleteBulkTransactions(t);
                  return false; 
                }
                return result == 'single';
              }
            },
            onDismissed: (_) {
              ref.watch(transactionsProvider.notifier).deleteTransaction(t.id);
            },
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => TransactionDetailModal(transaction: t),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                children: [
                  Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(t.colorCode),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => ref.watch(transactionsProvider.notifier).togglePaid(t.id),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(
                        side: BorderSide(
                          color: t.isPaid ? AppTheme.incomeColor : Colors.white24,
                          width: 2,
                        ),
                      ),
                      color: t.isPaid
                          ? AppTheme.incomeColor.withValues(alpha: 0.2)
                          : Colors.white10,
                    ),
                    child: Icon(
                      t.isPaid
                          ? Icons.check
                          : (widget.title == 'dashboard.status.delayed'.tr()
                              ? Icons.priority_high
                              : Icons.remove),
                      color: t.isPaid
                          ? AppTheme.incomeColor
                          : (widget.title == 'dashboard.status.delayed'.tr()
                              ? AppTheme.expenseColor
                              : AppTheme.futureColor),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    Text(dateStr, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Text(
                isPrivacyMode ? '***$displaySymbol' : format.format(displayAmount),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ),
  );
      },
    );
  }

  Future<String?> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151A25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("dashboard.delete_confirm.title").tr(),
          content: Text(
            "dashboard.delete_confirm.content", 
            style: const TextStyle(color: Colors.grey)
          ).tr(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text("dashboard.delete_confirm.cancel", style: const TextStyle(color: Colors.grey)).tr(),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('single'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
              ),
              child: Text("dashboard.delete_confirm.only_this_month").tr(),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('bulk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.expenseColor,
                foregroundColor: Colors.white,
              ),
              child: Text("dashboard.delete_confirm.all_months").tr(),
            ),
          ],
        );
      },
    );
  }

  void _openEditModal(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionModal(transactionToEdit: transaction),
    );
  }
}

class _BottomSummary extends ConsumerWidget {
  const _BottomSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(expenseDashboardProvider);
    final ratesAsync = ref.watch(currencyRatesProvider);
    final rates = ratesAsync.value;
    final displayCurrency = ref.watch(appSettingsProvider).selectedCurrency;

    double calculateTotal(List<Transaction>? transactions) {
      if (transactions == null) return 0.0;
      if (displayCurrency == 'TRY') {
        return transactions.fold(0.0, (sum, t) => sum + t.amount);
      }
      
      if (rates == null) return 0.0;
      final rate = rates[displayCurrency]?.buying ?? 1.0;
      
      return transactions.fold(0.0, (sum, t) {
        if (t.currency == displayCurrency && t.originalAmount != null) {
          return sum + t.originalAmount!;
        }
        return sum + (t.amount / rate);
      });
    }

    final delayed = calculateTotal(dashboardData['delayed']);
    final paid = calculateTotal(dashboardData['paid']);
    final upcoming = calculateTotal(dashboardData['upcoming']);
    
    final investmentData = ref.watch(investmentDashboardProvider);
    final investmentTotal = calculateTotal(investmentData['paid']) +
                           calculateTotal(investmentData['delayed']) +
                           calculateTotal(investmentData['upcoming']);

    final isPrivacyMode = ref.watch(appSettingsProvider).isPrivacyMode;
    final total = delayed + paid + upcoming;
    final remaining = delayed + upcoming;

    final displaySymbol = displayCurrency == 'TRY' ? '₺' : (displayCurrency == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0);
    final totalStr = isPrivacyMode ? '***$displaySymbol' : format.format(total);
    final remainingStr = isPrivacyMode ? '***$displaySymbol' : format.format(remaining);
    final investmentStr = isPrivacyMode ? '***$displaySymbol' : format.format(investmentTotal);

    final usdRate = rates?['USD']?.buying;
    final eurRate = rates?['EUR']?.buying;

    Widget buildCurrencyEquivalents(double amountInTry) {
      if (displayCurrency != 'TRY') return const SizedBox.shrink();
      if (usdRate == null || eurRate == null || amountInTry <= 0 || isPrivacyMode) return const SizedBox.shrink();
      
      final usdAmount = amountInTry / usdRate;
      final eurAmount = amountInTry / eurRate;
      final usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0, customPattern: '\$#,##0');
      final eurFormat = NumberFormat.currency(symbol: '€', decimalDigits: 0, customPattern: '€#,##0');
      
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          '${usdFormat.format(usdAmount)} • ${eurFormat.format(eurAmount)}',
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryRow(
          'dashboard.summary.total_expense'.tr(),
          totalStr,
          total,
          Colors.white,
          buildCurrencyEquivalents(total),
        ),
        const SizedBox(height: 12),
        _buildSummaryRow(
          'dashboard.summary.remaining_expense'.tr(),
          remainingStr,
          remaining,
          Colors.white,
          buildCurrencyEquivalents(remaining),
        ),
        if (investmentTotal > 0) ...[
          const SizedBox(height: 12),
          _buildSummaryRow(
            'dashboard.summary.investment'.tr(),
            investmentStr,
            investmentTotal,
            const Color(0xFFFFD700),
            buildCurrencyEquivalents(investmentTotal),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(String label, String valueStr, double amount, Color valueColor, Widget equivalents) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              equivalents,
            ],
          ),
          Text(
            valueStr,
            style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class GoalsSummaryHorizontal extends ConsumerWidget {
  const GoalsSummaryHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsProgress = ref.watch(goalsProgressProvider);
    final goals = goalsProgress.values.toList();

    if (goals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'dashboard.savings_goals'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GoalsScreen()),
                  );
                },
                child: Text('dashboard.view_all'.tr(), style: TextStyle(color: AppTheme.futureColor)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final progress = goals[index];
              final goal = progress.goal;
              final color = Color(goal.colorCode);
              final currencySymbol = ref.watch(appSettingsProvider).selectedCurrency;
              final displaySymbol = currencySymbol == 'TRY' ? '₺' : (currencySymbol == 'USD' ? '\$' : '€');

              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => AddGoalModal(goalToEdit: goal),
                            );
                          },
                          child: Icon(Icons.edit, color: color.withValues(alpha: 0.5), size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0).format(progress.currentAmount)} / ${NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 0).format(goal.targetAmount)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.percent,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '%${(progress.percent * 100).toStringAsFixed(0)}',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
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
