import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'app_group.freezed.dart';
part 'app_group.g.dart';

@freezed
@HiveType(typeId: 2)
abstract class AppGroup extends HiveObject with _$AppGroup {
  AppGroup._();

  factory AppGroup({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String icon,
    @HiveField(3) @Default([]) List<String> members,
  }) = _AppGroup;

  factory AppGroup.fromJson(Map<String, dynamic> json) => _$AppGroupFromJson(json);
}
