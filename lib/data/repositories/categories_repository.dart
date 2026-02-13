import 'package:hive_ce/hive.dart';
import '../models/category.dart';

class CategoriesRepository {
  final Box<Category> _box;

  CategoriesRepository(this._box);

  List<Category> getAllCategories() {
    return _box.values.toList();
  }

  Future<void> saveCategory(Category category) async {
    await _box.put(category.name, category);
  }

  Future<void> deleteCategory(String name) async {
    await _box.delete(name);
  }

  Future<void> saveCategories(List<Category> categories) async {
    final Map<String, Category> map = {
      for (var c in categories) c.name: c
    };
    await _box.putAll(map);
  }
}
