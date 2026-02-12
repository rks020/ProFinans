import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_providers.dart';
import '../../data/models/app_group.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'Grup Yönetimi'),
          ...groups.map((group) => ListTile(
                title: Text(group.name),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.surfaceColor,
                  child: Text(group.name[0]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.expenseColor),
                  onPressed: () => _confirmDeleteGroup(context, ref, group),
                ),
              )),
          ListTile(
            leading: const Icon(Icons.add, color: AppTheme.futureColor),
            title: const Text('Yeni Grup Ekle'),
            onTap: () => _showAddGroupDialog(context, ref),
          ),
          const Divider(height: 40),
          _SectionTitle(title: 'Veri Yönetimi'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Yedekle (JSON Export)'),
            subtitle: const Text('Tüm verileri İndirilenler klasörüne kaydet'),
            onTap: () => _exportData(context, ref),
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
        title: const Text('Grup Ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Grup Adı'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final group = AppGroup(
                  id: const Uuid().v4(),
                  name: controller.text,
                  icon: 'folder',
                );
                ref.read(groupsProvider.notifier).addGroup(group);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, WidgetRef ref, AppGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grubu Sil'),
        content: Text('${group.name} grubunu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              ref.read(groupsProvider.notifier).removeGroup(group.id);
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final groups = ref.read(groupsProvider);
    final transactions = ref.read(transactionsProvider);
    final settings = ref.read(appSettingsProvider);

    final data = {
      'groups': groups.map((g) => g.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'settings': settings.toJson(),
      'exported_at': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/profinans_backup_${DateTime.now().millisecondsSinceEpoch}.json');
        await file.writeAsString(jsonString);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yedeklendi: ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
