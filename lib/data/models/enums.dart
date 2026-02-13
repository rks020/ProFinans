import 'package:hive_ce/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0) income,
  @HiveField(1) expense,
  @HiveField(2) investment,
}

@HiveType(typeId: 1)
enum RecurrenceRule {
  @HiveField(0)
  none,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
  @HiveField(4) daily,           // Her gün
  @HiveField(5) biweekly,        // 2 haftada bir
  @HiveField(6) quarterly,       // 3 ayda bir
  @HiveField(7) semiannually,    // 6 ayda bir
  @HiveField(8) firstWorkday,    // Her ayın ilk iş günü
  @HiveField(9) lastWorkday,
}

