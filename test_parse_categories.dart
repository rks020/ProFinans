import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('appscreenshot/profinans_backup_1771016947115.json');
  final jsonString = await file.readAsString();
  final data = json.decode(jsonString) as Map<String, dynamic>;

  List<dynamic>? transactionsList;
  if (data.containsKey('transactions')) {
    transactionsList = data['transactions'] as List;
  }

  if (transactionsList != null) {
    if (data.containsKey('categories')) {
      print('Categories key exists directly');
      final categoriesList = (data['categories'] as List);
      print('Found ${categoriesList.length} categories directly');
    } else {
      print('Categories key DOES NOT exist. Extracting...');
      final Map<String, int> extractedCategories = {};
      
      for (final t in transactionsList) {
        final category = t['category'] as String?;
        final colorCode = t['colorCode'] as int?;
        if (category != null && colorCode != null) {
          if (!extractedCategories.containsKey(category)) {
            extractedCategories[category] = colorCode;
          }
        }
      }
      
      print('Extracted ${extractedCategories.length} categories:');
      for (final c in extractedCategories.entries) {
        print('- ${c.key}: ${c.value}');
      }
    }
  }
}
