import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../data/models/app_group.dart';
import '../../data/models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/add_transaction_modal.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final dashboardData = ref.watch(expenseDashboardProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GroupSelector(groups: groups, activeGroupId: appSettings.activeGroupId),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined), 
            onPressed: () => _showSoon(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined), 
            onPressed: () => _showSoon(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.futureColor, size: 32),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddTransactionModal(),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: _BottomSummary(),
            ),
          ],
        ),
      ),
    );
  }
  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik yakında eklenecek'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class GroupSelector extends ConsumerWidget {
  final List<AppGroup> groups;
  final String? activeGroupId;

  const GroupSelector({required this.groups, this.activeGroupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (groups.isEmpty) return const Text('Ev giderleri');
    final activeGroup = groups.firstWhere(
      (g) => g.id == activeGroupId, 
      orElse: () => groups.first,
    );

    return PopupMenuButton<String>(
      onSelected: (id) => ref.read(appSettingsProvider.notifier).updateActiveGroup(id),
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

class DateSelector extends StatelessWidget {
  const DateSelector();

  @override
  Widget build(BuildContext context) {
    // Hardcoded for UI match
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(onPressed: () {}, child: const Text('< Oca', style: TextStyle(color: Colors.grey))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Şub 2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () {}, child: const Text('Mar >', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class VerticalSummaryCards extends StatelessWidget {
  final Map<String, List<Transaction>> data;

  const VerticalSummaryCards({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VerticalSummaryCard(
          title: 'Geciken',
          transactions: data['delayed'] ?? [],
          color: const Color(0xFF1A0F0F),
          textColor: AppTheme.expenseColor,
        ),
        const SizedBox(height: 12),
        VerticalSummaryCard(
          title: 'Ödenen',
          transactions: data['paid'] ?? [],
          color: const Color(0xFF0F1A12),
          textColor: AppTheme.incomeColor,
        ),
        const SizedBox(height: 12),
        VerticalSummaryCard(
          title: 'Gelecek',
          transactions: data['upcoming'] ?? [],
          color: const Color(0xFF0F141A),
          textColor: AppTheme.futureColor,
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

  const VerticalSummaryCard({
    required this.title,
    required this.transactions,
    required this.color,
    required this.textColor,
  });

  @override
  ConsumerState<VerticalSummaryCard> createState() => _VerticalSummaryCardState();
}

// ... importlar aynen kalacak
class _VerticalSummaryCardState extends ConsumerState<VerticalSummaryCard> {
  bool _isExpanded = true;
  final Set<String> _collapsedGroups = {}; // Track collapsed group titles

  @override
  Widget build(BuildContext context) {
    final amount = widget.transactions.fold(0.0, (sum, t) => sum + t.amount);
    final count = widget.transactions.length;
    final format = NumberFormat.currency(symbol: '₺', decimalDigits: 0);
    final amountStr = format.format(amount).replaceAll('₺', '') + '₺';

    // Grouping logic by title
    final groupedTransactions = <String, List<Transaction>>{};
    for (var t in widget.transactions) {
      final key = t.title.trim();
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
              final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);
              final isCollapsed = _collapsedGroups.contains(title);
              
              if (transactions.length == 1) {
                return _buildTransactionItem(transactions.first);
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
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
                                "$title (${transactions.length})", 
                                style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                color: widget.textColor.withOpacity(0.5),
                                size: 16,
                              ),
                            ],
                          ),
                          Text(
                            format.format(totalAmount).replaceAll('₺', '') + '₺',
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(height: 8),
                      ...transactions.map((t) => _buildTransactionItem(t)),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction t) {
    final format = NumberFormat.currency(symbol: '₺', decimalDigits: 0);
    final dateStr = DateFormat('dd MMM', 'tr_TR').format(t.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
        key: Key(t.id),
        direction: DismissDirection.horizontal,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.edit, color: Colors.blue),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
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
            return await _showDeleteConfirmation(context);
          }
        },
        onDismissed: (_) {
          ref.read(transactionsProvider.notifier).deleteTransaction(t.id);
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => ref.read(transactionsProvider.notifier).togglePaid(t.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t.isPaid ? AppTheme.incomeColor.withOpacity(0.2) : Colors.white10,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: t.isPaid ? AppTheme.incomeColor : Colors.transparent,
                      width: 1
                    ),
                  ),
                  child: Icon(
                    t.isPaid ? Icons.check : (widget.title == 'Geciken' ? Icons.priority_high : Icons.remove),
                    color: t.isPaid ? AppTheme.incomeColor : (widget.title == 'Geciken' ? AppTheme.expenseColor : AppTheme.futureColor),
                    size: 18,
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
                format.format(t.amount).replaceAll('₺', '') + '₺',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151A25),
          title: const Text("Silinsin mi?", style: TextStyle(color: Colors.white)),
          content: const Text("Bu işlem geri alınamaz.", style: TextStyle(color: Colors.grey)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Vazgeç", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("SİL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ) ?? false;
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
    final delayed = dashboardData['delayed']?.fold(0.0, (sum, t) => sum! + t.amount) ?? 0.0;
    final paid = dashboardData['paid']?.fold(0.0, (sum, t) => sum! + t.amount) ?? 0.0;
    final upcoming = dashboardData['upcoming']?.fold(0.0, (sum, t) => sum! + t.amount) ?? 0.0;

    final total = delayed + paid + upcoming;
    final remaining = delayed + upcoming;

    final format = NumberFormat.currency(symbol: '₺', decimalDigits: 0);
    final totalStr = format.format(total).replaceAll('₺', '') + '₺';
    final remainingStr = format.format(remaining).replaceAll('₺', '') + '₺';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Toplam Gider', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text(totalStr, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Kalan Gider', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text(remainingStr, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik yakında eklenecek'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
