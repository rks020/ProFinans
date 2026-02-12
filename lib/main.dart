import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'data/models/enums.dart';
import 'data/models/app_group.dart';
import 'data/models/transaction.dart';
import 'data/models/app_settings.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ⚠️ BU SATIRI EKLE: Türkçe tarih formatını başlat
  await initializeDateFormatting('tr_TR', null);
  
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(RecurrenceRuleAdapter());
  Hive.registerAdapter(AppGroupAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  
  // Open Boxes
  final settingsBox = await Hive.openBox<AppSettings>('settings');
  final groupsBox = await Hive.openBox<AppGroup>('groups');
  await Hive.openBox<Transaction>('transactions');

  // Initialize with default group if none exists
  if (groupsBox.isEmpty) {
    final defaultGroup = AppGroup(
      id: const Uuid().v4(),
      name: 'Kişisel',
      icon: 'person',
    );
    await groupsBox.put(defaultGroup.id, defaultGroup);
    
    var settings = settingsBox.get('current') ?? AppSettings();
    await settingsBox.put('current', settings.copyWith(activeGroupId: defaultGroup.id));
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProFinans',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
