part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Local notifications (flutter_local_notifications + timezone)
// ═══════════════════════════════════════════════════════════════════════
final navigatorKey = GlobalKey<NavigatorState>();

/// A class to show in test alerts: the first saved class, or a placeholder.
Slot demoSlot() => timetable.isNotEmpty
    ? timetable.first
    : Slot(DateTime.now().weekday, TimeOfDay.now(), null,
        const Bi('تنبيه تجريبي', 'Test alert'), const Bi('', ''), Kind.lecture,
        Brand.blue);

class Notifier {
  Notifier._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static String? _launchPayload;

  /// Call once at start-up.
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      tz_data.initializeTimeZones();
      try {
        // Works with flutter_timezone returning either a String or a
        // TimezoneInfo object (depends on the package version).
        final dynamic info = await FlutterTimezone.getLocalTimezone();
        final String name = info is String ? info : info.identifier as String;
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        // Falls back to UTC if the device timezone cannot be resolved.
      }

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (r) => _open(r.payload),
      );

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _launchPayload = launch!.notificationResponse?.payload;
      }
      _ready = true;
    } catch (e) {
      debugPrint('Notifier init failed: $e');
    }
  }

  /// Asks for notification (and Android exact-alarm) permission.
  static Future<bool> requestPermissions() async {
    if (!_ready) return false;
    var granted = true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
      try {
        await android.requestExactAlarmsPermission();
      } catch (_) {}
    }
    if (ios != null) {
      granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true) ??
              false;
    }
    return granted;
  }

  /// Re-creates every scheduled notification from the current data:
  /// weekly items repeat every week, one-off items fire once on their date.
  static Future<void> sync() async {
    if (!_ready) return;
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < timetable.length; i++) {
      final s = timetable[i];
      if (s.kind == Kind.deadline && !app.deadlineAlerts) continue;
      final lead = s.lead ?? app.leadMinutes;
      final body = [
        inMinutes(lead),
        if (s.place.v.isNotEmpty) s.place.v,
      ].join(' · ');

      if (s.date == null) {
        final when = _nextOccurrence(s.weekday, s.start, lead);
        if (when == null) continue;
        await _schedule(
          id: 1000 + i,
          title: s.title.v,
          body: body,
          when: when,
          payload: 'c:$i',
          repeat: DateTimeComponents.dayOfWeekAndTime,
        );
      } else {
        final d = s.date!;
        final when = tz.TZDateTime(
                tz.local, d.year, d.month, d.day, s.start.hour, s.start.minute)
            .subtract(Duration(minutes: lead));
        if (!when.isAfter(now)) continue; // already in the past
        await _schedule(
          id: 1000 + i,
          title: s.title.v,
          body: body,
          when: when,
          payload: 'c:$i',
        );
      }
    }
  }

  /// Fires a notification in 5 seconds (used by Settings → Test alert).
  static Future<void> test() async {
    if (!_ready) return;
    await _schedule(
      id: 9000,
      title: demoSlot().title.v,
      body: [inMinutes(app.leadMinutes), if (demoSlot().place.v.isNotEmpty) demoSlot().place.v]
          .join(' · '),
      when: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      payload: 't',
    );
  }

  /// Re-schedules [slot] five minutes from now (Snooze button).
  static Future<void> snooze(Slot slot) async {
    if (!_ready) return;
    final i = timetable.indexOf(slot);
    await _schedule(
      id: 3000,
      title: slot.title.v,
      body: app.isAr ? 'تذكير مؤجَّل' : 'Snoozed reminder',
      when: tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5)),
      payload: i >= 0 ? 'c:$i' : null,
    );
  }

  /// Opens the alert screen if the app was launched by tapping a notification.
  static void openLaunchAlert() {
    final p = _launchPayload;
    _launchPayload = null;
    _open(p);
  }

  // ── internals ───────────────────────────────────────────────────────
  static void _open(String? payload) {
    if (payload == null) return;
    Slot? slot;
    if (payload.startsWith('c:')) {
      final i = int.tryParse(payload.substring(2));
      if (i != null && i >= 0 && i < timetable.length) slot = timetable[i];
    } else if (payload == 't') {
      slot = demoSlot();
    }
    final s = slot;
    if (s == null) return;
    navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => AlertPage(slot: s, lead: s.lead ?? app.leadMinutes)));
  }

  /// Next moment (strictly in the future) at which a weekly class on
  /// [weekday] starting at [t] should alert, [lead] minutes beforehand.
  static tz.TZDateTime? _nextOccurrence(int weekday, TimeOfDay t, int lead) {
    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < 8; i++) {
      final base = now.add(Duration(days: i));
      if (base.weekday != weekday) continue;
      final c = tz.TZDateTime(
              tz.local, base.year, base.month, base.day, t.hour, t.minute)
          .subtract(Duration(minutes: lead));
      if (c.isAfter(now)) return c;
    }
    return null;
  }

  /// Android: the chosen phone ringtone/notification sound (content:// URI).
  /// Returns null (= system default sound) on other platforms.
  static AndroidNotificationSound? _toneSound() {
    final uri = app.toneUri;
    if (uri == null || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    return UriAndroidNotificationSound(uri);
  }

  /// Android channel sound is fixed at creation, so each tone gets its own
  /// channel id (stable hash of the URI).
  static String _toneKey() {
    final uri = app.toneUri;
    if (uri == null) return 'd';
    var h = 0;
    for (final c in uri.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h.toRadixString(36);
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    String? payload,
    DateTimeComponents? repeat,
  }) async {
    // Android channel settings are fixed once created, so the vibration
    // preference is part of the channel id.
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'jadwali_alerts_${app.vibrate ? 1 : 0}_${_toneKey()}',
        app.isAr ? 'تنبيهات المواعيد' : 'Schedule alerts',
        channelDescription: app.isAr
            ? 'تنبيهات المحاضرات والواجبات والامتحانات'
            : 'Lecture, assignment and exam alerts',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: app.vibrate,
        playSound: true,
        sound: _toneSound(),
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    Future<void> go(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: mode,
          payload: payload,
          matchDateTimeComponents: repeat,
        );

    try {
      await go(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      // Exact alarms not permitted -> fall back to an inexact alarm.
      try {
        await go(AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (e) {
        debugPrint('Could not schedule notification $id: $e');
      }
    }
  }
}
