import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'app_state.dart';

/// Schedules a weekly reminder 15 minutes before every lecture.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const reminderMinutes = 15;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initing;
  String _signature = '';

  Future<void> init() => _initing ??= _init();

  Future<void> _init() async {
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // falls back to UTC; reminders would be offset on devices outside UTC
    }
    await _plugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    if (await android?.canScheduleExactNotifications() == false) {
      await android?.requestExactAlarmsPermission();
    }
  }

  NotificationDetails _details(AppState s) {
    final tone = s.tone;
    AndroidNotificationSound? sound;
    if (tone == 1) sound = const UriAndroidNotificationSound('content://settings/system/ringtone');
    if (tone == 2) sound = const UriAndroidNotificationSound('content://settings/system/alarm_alert');
    return NotificationDetails(
      android: AndroidNotificationDetails(
        // A channel's sound is fixed once created, so each tone gets its own channel.
        'lectures_tone_$tone',
        s.ar ? 'تنبيهات المحاضرات' : 'Lecture reminders',
        channelDescription: s.ar ? 'تذكير قبل بدء المحاضرة' : 'Reminder before a lecture starts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: tone != 3,
        sound: sound,
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
      ),
    );
  }

  /// Re-schedules everything when lectures, tone, language or the on/off switch change.
  Future<void> sync(AppState s) async {
    final lectures = s.lectures
        .map((l) => [l.id, l.day, l.startMin, l.nameAr, l.nameEn, l.room].join(':'))
        .join(',');
    final sig = [s.notifications, s.tone, s.lang, lectures].join('|');
    if (sig == _signature) return;
    _signature = sig;
    await init();
    await _plugin.cancelAll();
    if (!s.notifications) return;
    for (final l in s.lectures) {
      await _schedule(s, l);
    }
  }

  Future<void> _schedule(AppState s, Lecture l) async {
    final now = tz.TZDateTime.now(tz.local);
    final daysAhead = (l.weekday - now.weekday) % 7;
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day)
        .add(Duration(days: daysAhead, minutes: l.startMinutes - reminderMinutes));
    if (!when.isAfter(now)) when = when.add(const Duration(days: 7));

    Future<void> go(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          l.id & 0x3fffffff,
          l.name(s.ar),
          '${s.t('starts_in')} • ${l.room}',
          when,
          _details(s),
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

    try {
      await go(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      await go(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  /// Shows a notification immediately, to verify permissions and the chosen tone.
  Future<void> showTest(AppState s) async {
    await init();
    await _plugin.show(0, s.t('test_title'), s.t('test_body'), _details(s));
  }
}