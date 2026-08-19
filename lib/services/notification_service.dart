import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/finance_models.dart';
import '../theme/app_theme.dart';
import '../util/platform.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  int _seq = 1000;
  bool _ready = false;

  int nextId() => _seq++;

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> scheduleDebtReminder(DebtRecord debt) async {
    if (!_ready || !isMobileAdsPlatform) return;
    final when = DateTime(
      debt.dueDate.year,
      debt.dueDate.month,
      debt.dueDate.day,
      9,
    );
    if (when.isBefore(DateTime.now())) return;

    final message = debt.direction == DebtDirection.lent
        ? 'Today is the date to request ${inr(debt.amount)} back from ${debt.contactName}'
        : 'Today is the date to pay back ${inr(debt.amount)} to ${debt.contactName}';

    try {
      await _plugin.zonedSchedule(
        debt.notificationId ?? nextId(),
        'CampusLedger debt reminder',
        message,
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'debt_due',
            'Debt due dates',
            channelDescription: 'Alerts when lent/borrowed money is due',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Could not schedule notification: $e');
    }
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
