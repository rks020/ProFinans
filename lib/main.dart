import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'data/models/app_group.dart';
import 'data/models/transaction.dart';
import 'data/models/app_settings.dart';
import 'data/models/category.dart';
import 'ui/theme/app_theme.dart';

import 'ui/screens/main_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'hive_registrar.g.dart';
import 'package:path_provider/path_provider.dart';

import 'ui/screens/pin_screen.dart';
import 'providers/app_providers.dart';

import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
  
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  
  await Hive.initFlutter();
  Hive.registerAdapters();
  
  final settingsBox = await Hive.openBox<AppSettings>('settings');
  final groupsBox = await Hive.openBox<AppGroup>('groups');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Goal>('goals');

  if (groupsBox.isEmpty) {
    final defaultGroup = AppGroup(
      id: const Uuid().v4(),
      name: 'Personal',
      icon: 'person',
    );
    await groupsBox.put(defaultGroup.id, defaultGroup);
    
    var settings = settingsBox.get('current') ?? AppSettings();
    await settingsBox.put('current', settings.copyWith(activeGroupId: defaultGroup.id));
  } else {
    // Migration for existing users: rename 'dashboard.default_group_name' to 'Personal'
    for (var key in groupsBox.keys) {
      final group = groupsBox.get(key);
      if (group != null && group.name == 'dashboard.default_group_name') {
        await groupsBox.put(key, group.copyWith(name: 'Personal'));
      }
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('en', 'US'),
      useOnlyLangCode: true,
      child: const ProviderScope(
        child: MyApp(),
      ),
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
      home = PinScreen(isSetupMode: true);
    } else if (!isVerified) {
      home = PinScreen(isSetupMode: false);
    } else {
      home = MainScreen();
    }

    return MaterialApp(
      title: 'ProFinance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: home,
    );
  }
}
