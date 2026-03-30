import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/category.dart';
import '../theme/app_theme.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('categories_screen.title'.tr())),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            color: AppTheme.surfaceColor,
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(category.colorCode),
              ),
              title: Text(category.name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                category.budgetLimit == null 
                  ? 'categories_screen.no_limit'.tr() 
                  : 'categories_screen.limit'.tr(namedArgs: {
                      'amount': category.budgetLimit!.toStringAsFixed(0),
                      'currency': ref.watch(appSettingsProvider).selectedCurrency
                    })
              ),
              trailing: Icon(Icons.edit_outlined, color: Colors.grey),
              onTap: () => _showEditCategoryDialog(context, ref, category),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditCategoryDialog(context, ref, null),
        backgroundColor: AppTheme.futureColor,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category? category) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final limitController = TextEditingController(
      text: category?.budgetLimit?.toStringAsFixed(0) ?? ''
    );
    int selectedColor = category?.colorCode ?? 0xFF1E88E5;

    final List<int> colorPalette = [
      0xFFE53935, // Red
      0xFFD81B60, // Pink
      0xFF8E24AA, // Purple
      0xFF5E35B1, // Deep Purple
      0xFF3949AB, // Indigo
      0xFF1E88E5, // Blue
      0xFF039BE5, // Light Blue
      0xFF00ACC1, // Cyan
      0xFF00897B, // Teal
      0xFF43A047, // Green
      0xFF7CB342, // Light Green
      0xFFC0CA33, // Lime
      0xFFFDD835, // Yellow
      0xFFFFB300, // Amber
      0xFFFB8C00, // Orange
      0xFFF4511E, // Deep Orange
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF151A25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            top: 32,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category == null ? 'categories_screen.new_category'.tr() : 'categories_screen.edit_category'.tr(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 24),
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'categories_screen.name_label'.tr(),
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.futureColor),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'categories_screen.monthly_limit_label'.tr(namedArgs: {'currency': ref.read(appSettingsProvider).selectedCurrency}),
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'categories_screen.limit_hint'.tr(),
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.futureColor),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text('categories_screen.color_selection'.tr(), style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: colorPalette.length,
                  itemBuilder: (context, index) {
                    final color = colorPalette[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: selectedColor == color 
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  if (category != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(categoriesProvider.notifier).deleteCategory(category.name);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.expenseColor,
                          side: BorderSide(color: AppTheme.expenseColor),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('categories_screen.delete'.tr()),
                      ),
                    ),
                  if (category != null) SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          final newCategory = Category(
                            name: nameController.text,
                            colorCode: selectedColor,
                            budgetLimit: double.tryParse(limitController.text),
                          );
                          
                          if (category == null) {
                            ref.read(categoriesProvider.notifier).addCategory(newCategory);
                          } else {
                            ref.read(categoriesProvider.notifier).updateCategory(newCategory);
                          }
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.futureColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(category == null ? 'categories_screen.add'.tr() : 'categories_screen.update'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
