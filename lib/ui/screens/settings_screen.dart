import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/app_providers.dart';
import '../../providers/repository_providers.dart';
import '../../data/models/app_group.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../theme/app_theme.dart';
import 'yearly_analysis_screen.dart';
import 'pin_screen.dart';
import 'category_management_screen.dart';
import 'goals_screen.dart';
import 'subscriptions_screen.dart';
import 'reports_screen.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title').tr()),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'settings.group_management'.tr()),
          ...groups.map((group) => ListTile(
                title: Text(group.name),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.surfaceColor,
                  child: Text(group.name[0]),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: AppTheme.expenseColor),
                  onPressed: () => _confirmDeleteGroup(context, ref, group),
                ),
              )),
          ListTile(
            leading: Icon(Icons.add, color: AppTheme.futureColor),
            title: Text('settings.add_new_group').tr(),
            onTap: () => _showAddGroupDialog(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.category_outlined, color: AppTheme.futureColor),
            title: Text('settings.category_management').tr(),
            subtitle: Text('settings.category_management_desc').tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryManagementScreen()),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
          ListTile(
            leading: Icon(Icons.flag_rounded, color: AppTheme.futureColor),
            title: Text('settings.savings_goals').tr(),
            subtitle: Text('settings.savings_goals_desc').tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GoalsScreen()),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
          ListTile(
            leading: Icon(Icons.subscriptions_rounded, color: AppTheme.futureColor),
            title: Text('settings.my_subscriptions').tr(),
            subtitle: Text('settings.my_subscriptions_desc').tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubscriptionsScreen()),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
          Divider(height: 40),

          _SectionTitle(title: 'settings.data_management'.tr()),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('settings.backup_json').tr(),
            subtitle: Text('settings.backup_json_desc').tr(),
            onTap: () => _exportData(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.restore),
            title: Text('settings.import_data').tr(),
            subtitle: Text('settings.import_data_desc').tr(),
            onTap: () => _importData(context, ref),
          ),
          Divider(height: 40),
          ListTile(
            leading: Icon(Icons.pin, color: AppTheme.futureColor),
            title: Text('settings.security_pin').tr(),
            subtitle: Text('settings.security_pin_desc').tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PinScreen(isSetupMode: true)),
            ),
          ),
          Divider(height: 40),
          _SectionTitle(title: 'settings.general'.tr()),
          ListTile(
            leading: Icon(Icons.language, color: AppTheme.futureColor),
            title: Text('settings.language').tr(),
            subtitle: Text(context.locale.languageCode == 'tr' ? 'settings.turkish'.tr() : 'settings.english'.tr()),
            onTap: () {
              if (context.locale.languageCode == 'tr') {
                context.setLocale(Locale('en', 'US'));
              } else {
                context.setLocale(Locale('tr', 'TR'));
              }
            },
            trailing: Icon(Icons.swap_horiz, color: Colors.grey),
          ),
          Divider(height: 40),
          _SectionTitle(title: 'settings.reports'.tr()),
          ListTile(
            leading: Icon(Icons.analytics, color: AppTheme.futureColor),
            title: Text('settings.yearly_analysis').tr(),
            subtitle: Text('settings.yearly_analysis_desc').tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => YearlyAnalysisScreen()),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
          ListTile(
            leading: Icon(Icons.picture_as_pdf, color: AppTheme.futureColor),
            title: Text('settings.reports_and_export').tr(),
            subtitle: Text('settings.reports_and_export_desc').tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportsScreen()),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reports.add_group.title').tr(),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'reports.add_group.hint'.tr()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('reports.add_group.cancel').tr()),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final group = AppGroup(
                  id: Uuid().v4(),
                  name: controller.text,
                  icon: 'folder',
                );
                ref.read(groupsProvider.notifier).addGroup(group);
                Navigator.pop(context);
              }
            },
            child: Text('reports.add_group.add').tr(),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, WidgetRef ref, AppGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reports.delete_group.title').tr(),
        content: Text('reports.delete_group.content'.tr(namedArgs: {'group': group.name})),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('reports.delete_group.cancel').tr()),
          TextButton(
            onPressed: () {
              ref.read(groupsProvider.notifier).removeGroup(group.id);
              Navigator.pop(context);
            },
            child: Text('reports.delete_group.delete'.tr(), style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final groups = ref.read(groupsProvider);
    final transactions = ref.read(transactionsProvider);
    final settings = ref.read(appSettingsProvider);
    final categories = ref.read(categoriesProvider);

    final data = {
      'groups': groups.map((g) => g.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'goals': ref.read(goalsProvider).map((g) => g.toJson()).toList(),
      'settings': settings.toJson(),
      'exported_at': DateTime.now().toIso8601String(),
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(data);

    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'profinance_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'reports.backup.share_subject'.tr(),
        text: 'reports.backup.share_text'.tr(namedArgs: {'file': fileName}),
      );

      if (result.status == ShareResultStatus.success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('reports.backup.success').tr()),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reports.backup.error'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString) as Map<String, dynamic>;

        // 1. Grupları Yükle
        if (data.containsKey('groups')) {
          final groupsList = (data['groups'] as List).map((g) => AppGroup.fromJson(g)).toList();
          await ref.read(groupsProvider.notifier).restoreGroups(groupsList);
        }

        // 2. Ayarları Yükle
        if (data.containsKey('settings')) {
          final settings = AppSettings.fromJson(data['settings']);
          await ref.read(appSettingsProvider.notifier).restoreSettings(settings);
        }

        // 3. İşlemleri Yükle
        List<Transaction>? transactionsList;
        if (data.containsKey('transactions')) {
          transactionsList = (data['transactions'] as List)
              .map((t) => Transaction.fromJson(t))
              .toList()
              .cast<Transaction>();
          await ref.read(transactionsProvider.notifier).restoreTransactions(transactionsList);
        }

        // 4. Kategorileri Yükle
        final Map<String, Category> allCategories = {};
        if (data.containsKey('categories')) {
          final importedCategories = (data['categories'] as List)
              .map((c) => Category.fromJson(c))
              .toList()
              .cast<Category>();
          for (final c in importedCategories) {
            allCategories[c.name] = c;
          }
        }
        
        if (transactionsList != null) {
          for (final t in transactionsList) {
            if (!allCategories.containsKey(t.category)) {
              allCategories[t.category] = Category(
                name: t.category,
                colorCode: t.colorCode,
              );
            }
          }
        }
        
        if (data.containsKey('goals')) {
          final goalsList = (data['goals'] as List).map((g) => Goal.fromJson(g)).toList();
          await ref.read(goalsRepositoryProvider).saveGoals(goalsList);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('reports.import.success').tr()),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reports.import.error'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.futureColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
