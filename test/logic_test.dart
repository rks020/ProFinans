import 'package:flutter_test/flutter_test.dart';
import 'package:profinans/data/models/transaction.dart';
import 'package:profinans/data/models/enums.dart';

void main() {
  test('Transaction filtering logic test', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final t1 = Transaction(
      id: '1',
      groupId: 'g1',
      title: 'Delayed',
      amount: 100,
      date: yesterday,
      type: TransactionType.expense,
      category: 'Food',
      colorCode: 0,
      isPaid: false,
    );

    final t2 = Transaction(
      id: '2',
      groupId: 'g1',
      title: 'Paid',
      amount: 200,
      date: today,
      type: TransactionType.expense,
      category: 'Rent',
      colorCode: 0,
      isPaid: true,
    );

    final t3 = Transaction(
      id: '3',
      groupId: 'g1',
      title: 'Upcoming',
      amount: 300,
      date: tomorrow,
      type: TransactionType.expense,
      category: 'Bills',
      colorCode: 0,
      isPaid: false,
    );

    // Manual filtering mock
    final delayed = [t1, t2, t3].where((t) => t.date.isBefore(today) && !t.isPaid).toList();
    final paid = [t1, t2, t3].where((t) => t.date.year == now.year && t.date.month == now.month && t.isPaid).toList();
    final upcoming = [t1, t2, t3].where((t) => t.date.isAfter(today) && t.date.month == now.month).toList();

    expect(delayed.length, 1);
    expect(delayed.first.id, '1');
    expect(paid.length, 1);
    expect(paid.first.id, '2');
    expect(upcoming.length, 1);
    expect(upcoming.first.id, '3');
  });
}
