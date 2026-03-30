import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
@HiveType(typeId: 7)
abstract class Goal extends HiveObject with _$Goal {
  Goal._();

  factory Goal({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required double targetAmount,
    @HiveField(3) @Default(0.0) double currentAmount,
    @HiveField(4) required int colorCode,
    @HiveField(5) String? iconPath,
    @HiveField(6) DateTime? deadline,
    @HiveField(7) @Default(true) bool isActive,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
