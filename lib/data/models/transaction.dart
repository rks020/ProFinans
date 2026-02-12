import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'enums.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
@HiveType(typeId: 3)
abstract class Transaction extends HiveObject with _$Transaction {
  Transaction._();

  factory Transaction({
    @HiveField(0) required String id,
    @HiveField(1) required String groupId,
    @HiveField(2) required String title,
    @HiveField(3) required double amount,
    @HiveField(4) required DateTime date,
    @HiveField(5) required TransactionType type,
    @HiveField(6) required String category,
    @HiveField(7) required int colorCode,
    @HiveField(8) @Default(false) bool isPaid,
    @HiveField(9) @Default(RecurrenceRule.none) RecurrenceRule recurrenceRule,
    @HiveField(10) int? installmentTotal,
    @HiveField(11) int? installmentCurrent,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
