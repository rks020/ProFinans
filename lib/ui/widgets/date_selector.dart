import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';

class DateSelector extends ConsumerWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final monthFormat = DateFormat('MMM yyyy', 'tr_TR');
    final prevMonthFormat = DateFormat('MMM', 'tr_TR');
    final nextMonthFormat = DateFormat('MMM', 'tr_TR');

    final prevMonth = DateTime(selectedDate.year, selectedDate.month - 1);
    final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () => ref.read(selectedDateProvider.notifier).previousMonth(),
            child: Text('< ${prevMonthFormat.format(prevMonth)}', style: const TextStyle(color: Colors.grey)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              monthFormat.format(selectedDate), 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          TextButton(
            onPressed: () => ref.read(selectedDateProvider.notifier).nextMonth(),
            child: Text('${nextMonthFormat.format(nextMonth)} >', style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
