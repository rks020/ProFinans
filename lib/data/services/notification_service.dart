import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/transaction.dart';
import '../models/enums.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (details) {},
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelReminder(String transactionId) async {
    final notificationId = transactionId.hashCode;
    await _plugin.cancel(id: notificationId);
  }

  Future<void> scheduleTransactionReminder(Transaction transaction, String currencySymbol) async {
    if (transaction.reminderInterval == ReminderInterval.none ||
        transaction.type != TransactionType.expense) {
      return;
    }

    final notificationId = transaction.id.hashCode;
    await cancelReminder(transaction.id);

    DateTime scheduledDate;
    switch (transaction.reminderInterval) {
      case ReminderInterval.thirtyMinutes:
        scheduledDate = transaction.date.subtract(const Duration(minutes: 30));
        break;
      case ReminderInterval.oneHour:
        scheduledDate = transaction.date.subtract(const Duration(hours: 1));
        break;
      case ReminderInterval.twelveHours:
        scheduledDate = transaction.date.subtract(const Duration(hours: 12));
        break;
      case ReminderInterval.oneDay:
        // 1 gün öncesi sabah 09:00
        final d = transaction.date.subtract(const Duration(days: 1));
        scheduledDate = DateTime(d.year, d.month, d.day, 9, 0);
        break;
      case ReminderInterval.twoDays:
        final d = transaction.date.subtract(const Duration(days: 2));
        scheduledDate = DateTime(d.year, d.month, d.day, 9, 0);
        break;
      case ReminderInterval.oneWeek:
        final d = transaction.date.subtract(const Duration(days: 7));
        scheduledDate = DateTime(d.year, d.month, d.day, 9, 0);
        break;
      case ReminderInterval.none:
        return;
    }

    // Zaman geçmişse zamanlamayı iptal et
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final intervalText = _getIntervalText(transaction.reminderInterval);
    final title = 'notifications.upcoming_payment.title'.tr(namedArgs: {'title': transaction.title});
    final body = 'notifications.upcoming_payment.body'.tr(namedArgs: {
      'date': '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
      'amount': '${transaction.amount.toStringAsFixed(0)} $currencySymbol',
      'interval': intervalText
    });

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'expense_reminders',
          'notifications.upcoming_payment.channel_name'.tr(),
          channelDescription: 'notifications.upcoming_payment.channel_desc'.tr(),
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
    required String currencySymbol,
  }) async {
    final notificationId = categoryName.hashCode;
    
    final isOver = spent > limit;
    final percent = (spent / limit * 100).toStringAsFixed(0);
    
    final title = isOver 
        ? 'notifications.budget_warning.title_over'.tr(namedArgs: {'category': categoryName})
        : 'notifications.budget_warning.title_warning'.tr(namedArgs: {'category': categoryName});
    
    final body = isOver 
        ? 'notifications.budget_warning.body_over'.tr(namedArgs: {
            'category': categoryName,
            'amount': '${(spent - limit).toStringAsFixed(0)} $currencySymbol',
            'spent': '${spent.toStringAsFixed(0)} $currencySymbol'
          })
        : 'notifications.budget_warning.body_warning'.tr(namedArgs: {
            'category': categoryName,
            'percent': percent,
            'spent': spent.toStringAsFixed(0),
            'limit': limit.toStringAsFixed(0)
          });

    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'notifications.budget_warning.channel_name'.tr(),
          channelDescription: 'notifications.budget_warning.channel_desc'.tr(),
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );

  }

  String _getIntervalText(ReminderInterval interval) {
    switch (interval) {
      case ReminderInterval.thirtyMinutes: return 'reminder.30_min'.tr();
      case ReminderInterval.oneHour: return 'reminder.1_hour'.tr();
      case ReminderInterval.twelveHours: return 'reminder.12_hours'.tr();
      case ReminderInterval.oneDay: return 'reminder.1_day'.tr();
      case ReminderInterval.twoDays: return 'reminder.2_days'.tr();
      case ReminderInterval.oneWeek: return 'reminder.1_week'.tr();
      case ReminderInterval.none: return '';
    }
  }
}
