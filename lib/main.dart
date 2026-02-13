import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'data/models/enums.dart';
import 'data/models/app_group.dart';
import 'data/models/transaction.dart';
import 'data/models/app_settings.dart';
import 'data/models/category.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'hive_registrar.g.dart';

import 'ui/screens/pin_screen.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ⚠️ BU SATIRI EKLE: Türkçe tarih formatını başlat
  await initializeDateFormatting('tr_TR', null);
  
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapters();
  
  // Open Boxes
  final settingsBox = await Hive.openBox<AppSettings>('settings');
  final groupsBox = await Hive.openBox<AppGroup>('groups');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Category>('categories');

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isVerified = ref.watch(pinStateProvider);

    Widget home;
    if (settings.pinCode == null) {
      // No PIN set yet - force setup
      home = const PinScreen(isSetupMode: true);
    } else if (!isVerified) {
      // PIN set but not verified this session
      home = const PinScreen(isSetupMode: false);
    } else {
      // PIN verified
      home = const MainScreen();
    }

    return MaterialApp(
      title: 'ProFinans',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: home,
    );
  }
}
