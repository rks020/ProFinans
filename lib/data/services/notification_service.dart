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

  Future<void> scheduleTransactionReminder(Transaction transaction) async {
    if (transaction.reminderInterval == ReminderInterval.none ||
        transaction.type != TransactionType.expense) return;

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
    final title = 'Yaklaşan Ödeme: ${transaction.title}';
    final body =
        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} '
        'tarihli ${transaction.amount.toStringAsFixed(0)} TL tutarındaki ödemenize $intervalText kaldı.';

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'expense_reminders',
          'Ödeme Hatırlatıcıları',
          channelDescription: 'Yaklaşan gider ödemeleriniz için hatırlatmalar',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  String _getIntervalText(ReminderInterval interval) {
    switch (interval) {
      case ReminderInterval.thirtyMinutes: return '30 dakika';
      case ReminderInterval.oneHour: return '1 saat';
      case ReminderInterval.twelveHours: return '12 saat';
      case ReminderInterval.oneDay: return '1 gün';
      case ReminderInterval.twoDays: return '2 gün';
      case ReminderInterval.oneWeek: return '1 hafta';
      case ReminderInterval.none: return '';
    }
  }
}
