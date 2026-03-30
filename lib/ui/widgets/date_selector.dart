import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';

class DateSelector extends ConsumerWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final locale = context.locale.toString();
    final monthFormat = DateFormat('MMM yyyy', locale);
    final prevMonthFormat = DateFormat('MMM', locale);
    final nextMonthFormat = DateFormat('MMM', locale);

    final prevMonth = DateTime(selectedDate.year, selectedDate.month - 1);
    final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () => ref.read(selectedDateProvider.notifier).previousMonth(),
            child: Text('< ${prevMonthFormat.format(prevMonth)}', style: TextStyle(color: Colors.grey)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              monthFormat.format(selectedDate), 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          TextButton(
            onPressed: () => ref.read(selectedDateProvider.notifier).nextMonth(),
            child: Text('${nextMonthFormat.format(nextMonth)} >', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
