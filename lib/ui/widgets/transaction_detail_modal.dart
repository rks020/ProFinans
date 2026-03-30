import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../../data/services/notification_service.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';

class TransactionDetailModal extends ConsumerStatefulWidget {
  final Transaction transaction;

  const TransactionDetailModal({super.key, required this.transaction});

  @override
  ConsumerState<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends ConsumerState<TransactionDetailModal> {
  late ReminderInterval _reminderInterval;
  late bool _isSubscription;

  @override
  void initState() {
    super.initState();
    _reminderInterval = widget.transaction.reminderInterval;
    _isSubscription = widget.transaction.isSubscription;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final isPrivacyMode = settings.isPrivacyMode;
    final currencyCode = settings.selectedCurrency;
    final displaySymbol = currencyCode == 'TRY' ? '₺' : (currencyCode == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(symbol: displaySymbol, decimalDigits: 0, locale: context.locale.languageCode);
    final transaction = widget.transaction;

    DateTime? endDate;
    int totalRelated = 0;
    int paidRelated = 0;

    if (transaction.recurrenceRule != RecurrenceRule.none) {
      final allTransactions = ref.watch(transactionsProvider);
      final related = allTransactions.where((t) =>
        t.groupId == transaction.groupId &&
        t.title == transaction.title &&
        t.category == transaction.category &&
        t.type == transaction.type &&
        t.recurrenceRule == transaction.recurrenceRule).toList();

      if (related.isNotEmpty) {
        related.sort((a, b) => a.date.compareTo(b.date));
        endDate = related.last.date;
        totalRelated = related.length;
        paidRelated = related.where((t) => t.isPaid).length;
      }
    }

    final amountStr = isPrivacyMode ? '***$displaySymbol' : format.format(transaction.amount);

    Color headerColor;
    IconData headerIcon;
    switch (transaction.type) {
      case TransactionType.income:
        headerColor = AppTheme.incomeColor;
        headerIcon = Icons.arrow_downward;
        break;
      case TransactionType.expense:
        headerColor = AppTheme.expenseColor;
        headerIcon = Icons.arrow_upward;
        break;
      case TransactionType.investment:
        headerColor = Color(0xFFFFD700);
        headerIcon = Icons.savings;
        break;
    }

    return Container(
      padding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 40),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Hatırlatıcı (Only for expenses)
            if (transaction.type == TransactionType.expense)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'transaction_detail.reminder_time'.tr(),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Spacer(),
                    DropdownButton<ReminderInterval>(
                      dropdownColor: AppTheme.surfaceColor,
                      value: _reminderInterval,
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: AppTheme.futureColor),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      items: ReminderInterval.values.map((interval) {
                        return DropdownMenuItem(
                          value: interval,
                          child: Text(_getReminderIntervalLabel(interval)),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        if (val == null) return;
                        // Update UI immediately
                        setState(() => _reminderInterval = val);

                        final isRecurring = transaction.recurrenceRule != RecurrenceRule.none;
                        if (isRecurring) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppTheme.surfaceColor,
                              title: Text('transaction_detail.recurring_future'.tr(), style: TextStyle(color: Colors.white)),
                              content: Text(
                                'transaction_detail.recurring_future_desc'.tr(),
                                style: TextStyle(color: Colors.grey),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    _updateReminder(transaction, val, updateAll: false);
                                  },
                                  child: Text('transaction_detail.no'.tr(), style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    _updateReminder(transaction, val, updateAll: true);
                                  },
                                  child: Text('transaction_detail.yes'.tr(), style: TextStyle(color: AppTheme.futureColor)),
                                ),
                              ],
                            ),
                          );
                        } else {
                          _updateReminder(transaction, val, updateAll: false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            
            // Abonelik Toggle (New)
            if (transaction.type == TransactionType.expense) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isSubscription ? AppTheme.futureColor.withValues(alpha: 0.3) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSubscription ? Icons.subscriptions : Icons.subscriptions_outlined, 
                      color: _isSubscription ? AppTheme.futureColor : Colors.grey, 
                      size: 20
                    ),
                    SizedBox(width: 8),
                    Text(
                      'transaction_detail.mark_subscription'.tr(),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Spacer(),
                    Switch(
                      value: _isSubscription,
                      activeThumbColor: AppTheme.futureColor,
                      onChanged: (val) {
                        setState(() => _isSubscription = val);
                        _updateSubscription(transaction, val);
                      },
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(transaction.colorCode),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            transaction.category.tr(),
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(headerIcon, color: headerColor),
                      SizedBox(height: 8),
                      Text(
                        amountStr,
                        style: TextStyle(color: headerColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Details List
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'transaction_detail.date'.tr(),
              value: DateFormat('d MMMM yyyy HH:mm', context.locale.languageCode).format(transaction.date),
            ),

            _buildDetailRow(
              icon: transaction.isPaid ? Icons.check_circle : Icons.pending,
              iconColor: transaction.isPaid ? AppTheme.incomeColor : Colors.orange,
              label: 'transaction_detail.status'.tr(),
              value: transaction.isPaid ? 'transaction_detail.paid'.tr() : 'transaction_detail.pending'.tr(),
              valueColor: transaction.isPaid ? AppTheme.incomeColor : Colors.orange,
            ),

            if (transaction.installmentTotal != null && transaction.installmentTotal! > 1) ...[
              Divider(color: Colors.white10, height: 32),
              _buildDetailRow(
                icon: Icons.credit_card,
                label: 'transaction_detail.installment'.tr(),
                value: '${transaction.installmentCurrent} / ${transaction.installmentTotal}',
              ),
              _buildDetailRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'transaction_detail.total_amount'.tr(),
                value: isPrivacyMode ? '***$displaySymbol' : format.format(transaction.amount * transaction.installmentTotal!),
              ),
            ],

            if (transaction.recurrenceRule != RecurrenceRule.none && endDate != null) ...[
              Divider(color: Colors.white10, height: 32),
              _buildDetailRow(
                icon: Icons.repeat,
                label: 'transaction_detail.recurrence_type'.tr(),
                value: _getRecurrenceLabel(transaction.recurrenceRule, isFinite: true),
              ),
              _buildDetailRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'transaction_detail.total_amount'.tr(),
                value: isPrivacyMode ? '***$displaySymbol' : format.format(transaction.amount * totalRelated),
              ),
              _buildDetailRow(
                icon: Icons.event_available,
                label: 'transaction_detail.end_date'.tr(),
                value: DateFormat('MMMM yyyy', context.locale.languageCode).format(endDate),
              ),
              _buildDetailRow(
                icon: Icons.pie_chart_outline,
                label: 'transaction_detail.paid_total'.tr(),
                value: 'transaction_detail.transactions_count'.tr(namedArgs: {'count': '$paidRelated / $totalRelated'}),
              ),
            ],

            SizedBox(height: 32),

            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('transaction_detail.close'.tr(), style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    Color iconColor = Colors.grey,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 16)),
          Spacer(),
          Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getRecurrenceLabel(RecurrenceRule rule, {bool isFinite = false}) {
    switch (rule) {
      case RecurrenceRule.none: return 'recurrence.none'.tr();
      case RecurrenceRule.daily: return 'recurrence.daily'.tr();
      case RecurrenceRule.weekly: return 'recurrence.weekly'.tr();
      case RecurrenceRule.biweekly: return 'recurrence.biweekly'.tr();
      case RecurrenceRule.monthly: return 'recurrence.monthly'.tr();
      case RecurrenceRule.quarterly: return 'recurrence.quarterly'.tr();
      case RecurrenceRule.semiannually: return 'recurrence.semiannually'.tr();
      case RecurrenceRule.yearly: return 'recurrence.yearly'.tr();
      case RecurrenceRule.firstWorkday: return 'recurrence.firstWorkday'.tr();
      case RecurrenceRule.lastWorkday: return 'recurrence.lastWorkday'.tr();
    }
  }

  String _getReminderIntervalLabel(ReminderInterval interval) {
    switch (interval) {
      case ReminderInterval.none: return 'reminder.none'.tr();
      case ReminderInterval.thirtyMinutes: return 'reminder.30_min'.tr();
      case ReminderInterval.oneHour: return 'reminder.1_hour'.tr();
      case ReminderInterval.twelveHours: return 'reminder.12_hours'.tr();
      case ReminderInterval.oneDay: return 'reminder.1_day'.tr();
      case ReminderInterval.twoDays: return 'reminder.2_days'.tr();
      case ReminderInterval.oneWeek: return 'reminder.1_week'.tr();
    }
  }

  void _updateReminder(Transaction transaction, ReminderInterval val, {bool updateAll = false}) async {
    try {
      final updatedTransaction = transaction.copyWith(
        reminderInterval: val,
        hasReminder: val != ReminderInterval.none,
      );

      if (updateAll && transaction.recurrenceRule != RecurrenceRule.none && transaction.groupId.isNotEmpty) {
        final allTransactions = ref.read(allGroupTransactionsProvider);
        final relatedTransactions = allTransactions.where((t) =>
          t.groupId == transaction.groupId &&
          t.title == transaction.title &&
          t.amount == transaction.amount &&
          t.date.isAfter(transaction.date.subtract(Duration(days: 1)))
        ).toList();

        for (var t in relatedTransactions) {
          final tUpdated = t.copyWith(
            reminderInterval: val,
            hasReminder: val != ReminderInterval.none,
          );
          await ref.read(transactionsProvider.notifier).addTransaction(tUpdated);
          if (val != ReminderInterval.none) {
            await NotificationService().scheduleTransactionReminder(tUpdated, ref.read(appSettingsProvider).selectedCurrency);
          } else {
            await NotificationService().cancelReminder(tUpdated.id);
          }
        }
      } else {
        await ref.read(transactionsProvider.notifier).addTransaction(updatedTransaction);
        if (val != ReminderInterval.none) {
          await NotificationService().scheduleTransactionReminder(updatedTransaction, ref.read(appSettingsProvider).selectedCurrency);
        } else {
          await NotificationService().cancelReminder(updatedTransaction.id);
        }
      }
    } catch (e) {
      debugPrint('Error updating reminder status: $e');
    }
  }

  void _updateSubscription(Transaction transaction, bool val) async {
    try {
      final updatedTransaction = transaction.copyWith(isSubscription: val);
      await ref.read(transactionsProvider.notifier).addTransaction(updatedTransaction);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'transaction_detail.subscription_marked'.tr() : 'transaction_detail.subscription_unmarked'.tr()),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('Error updating subscription status: $e');
    }
  }
}
