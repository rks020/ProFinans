import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';

class TransactionDetailModal extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailModal({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isPrivacyMode = settings.isPrivacyMode;
    final format = NumberFormat.currency(symbol: '₺', decimalDigits: 0, locale: 'tr_TR');
    
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

    final amountStr = isPrivacyMode ? '***₺' : format.format(transaction.amount);
    
    // Determine Header Color based on Type
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
        headerColor = const Color(0xFFFFD700);
        headerIcon = Icons.savings;
        break;
    }

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 40),
      decoration: const BoxDecoration(
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
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
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
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
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
                          const SizedBox(width: 8),
                          Text(
                            transaction.category,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(headerIcon, color: headerColor),
                      const SizedBox(height: 8),
                      Text(
                        amountStr,
                        style: TextStyle(color: headerColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Details List
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Tarih',
              value: DateFormat('d MMMM yyyy', 'tr_TR').format(transaction.date),
            ),
            
            _buildDetailRow(
              icon: transaction.isPaid ? Icons.check_circle : Icons.pending,
              iconColor: transaction.isPaid ? AppTheme.incomeColor : Colors.orange,
              label: 'Durum',
              value: transaction.isPaid ? 'Ödendi' : 'Bekliyor',
              valueColor: transaction.isPaid ? AppTheme.incomeColor : Colors.orange,
            ),

            if (transaction.installmentTotal != null && transaction.installmentTotal! > 1) ...[
              const Divider(color: Colors.white10, height: 32),
              _buildDetailRow(
                icon: Icons.credit_card,
                label: 'Taksit',
                value: '${transaction.installmentCurrent} / ${transaction.installmentTotal}',
              ),
            ],

            if (transaction.recurrenceRule != RecurrenceRule.none && endDate != null) ...[
              const Divider(color: Colors.white10, height: 32),
              _buildDetailRow(
                icon: Icons.repeat,
                label: 'Tekrar Tipi',
                value: _getRecurrenceLabel(transaction.recurrenceRule),
              ),
              _buildDetailRow(
                icon: Icons.event_available,
                label: 'Bitiş Tarihi',
                value: DateFormat('MMMM yyyy', 'tr_TR').format(endDate), // Mostly care about month/year
              ),
              _buildDetailRow(
                icon: Icons.pie_chart_outline,
                label: 'Ödenen / Toplam',
                value: '$paidRelated / $totalRelated İşlem',
              ),
            ],

            const SizedBox(height: 32),
            
            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Kapat', style: TextStyle(color: Colors.white, fontSize: 16)),
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
          Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getRecurrenceLabel(RecurrenceRule rule) {
    switch (rule) {
      case RecurrenceRule.none: return 'Bir kez';
      case RecurrenceRule.daily: return 'Her gün';
      case RecurrenceRule.weekly: return 'Her hafta';
      case RecurrenceRule.biweekly: return 'Her 2 haftada bir';
      case RecurrenceRule.monthly: return 'Her ay';
      case RecurrenceRule.quarterly: return 'Her 3 ayda bir';
      case RecurrenceRule.semiannually: return 'Her 6 ayda bir';
      case RecurrenceRule.yearly: return 'Her yıl';
      case RecurrenceRule.firstWorkday: return 'Her ayın ilk iş günü';
      case RecurrenceRule.lastWorkday: return 'Her ayın son iş günü';
      default: return 'Bir kez';
    }
  }
}
