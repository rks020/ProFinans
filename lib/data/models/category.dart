import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
@HiveType(typeId: 5)
abstract class Category extends HiveObject with _$Category {
  Category._();

  factory Category({
    @HiveField(0) required String name,
    @HiveField(1) required int colorCode,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
