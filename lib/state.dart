part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  App state (theme, language, time format, alert settings)
// ═══════════════════════════════════════════════════════════════════════
class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('ar');
  bool use24h = false;
  int leadMinutes = 15;
  bool vibrate = true;
  bool snooze = true;
  bool deadlineAlerts = true;
  String? toneUri; // null = system default notification sound
  String? toneTitle;
  bool onboarded = false;

  bool get isAr => locale.languageCode == 'ar';

  /// Applies [change], notifies listeners, persists everything and (when
  /// [reschedule] is true) re-creates all scheduled notifications.
  void update(VoidCallback change, {bool reschedule = false}) {
    change();
    notifyListeners();
    _save();
    if (reschedule) Notifier.sync();
  }

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      themeMode = ThemeMode
          .values[(p.getInt('theme') ?? ThemeMode.system.index).clamp(0, 2).toInt()];
      locale = Locale(p.getString('lang') ?? 'ar');
      use24h = p.getBool('use24h') ?? false;
      leadMinutes = p.getInt('lead') ?? 15;
      vibrate = p.getBool('vibrate') ?? true;
      snooze = p.getBool('snooze') ?? true;
      deadlineAlerts = p.getBool('deadlineAlerts') ?? true;
      toneUri = p.getString('toneUri');
      toneTitle = p.getString('toneTitle');
      onboarded = p.getBool('onboarded') ?? false;
      final tt = p.getString('timetable');
      if (tt != null) {
        final list = jsonDecode(tt) as List<dynamic>;
        timetable
          ..clear()
          ..addAll(list.map((e) => Slot.fromJson(e as Map<String, dynamic>)));
      }
      // Older versions stored reminders separately: merge them into the
      // unified timetable once, then forget the old key.
      final raw = p.getString('reminders');
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final j = e as Map<String, dynamic>;
          final date = DateUtils.dateOnly(DateTime.parse(j['date'] as String));
          final title = j['title'] as String;
          final type = j['type'] as int; // 0 lecture, 1 assignment, 2 exam
          timetable.add(Slot(
            date.weekday,
            TimeOfDay(hour: j['h'] as int, minute: j['m'] as int),
            null,
            Bi(title, title),
            const Bi('', ''),
            type == 2 ? Kind.exam : (type == 1 ? Kind.deadline : Kind.lecture),
            Brand.blue,
            date: (j['repeat'] as bool) ? null : date,
            lead: j['lead'] as int,
          ));
        }
        await p.remove('reminders');
        _save();
      }
    } catch (e) {
      debugPrint('Could not load saved settings: $e');
    }
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt('theme', themeMode.index);
      await p.setString('lang', locale.languageCode);
      await p.setBool('use24h', use24h);
      await p.setInt('lead', leadMinutes);
      await p.setBool('vibrate', vibrate);
      await p.setBool('snooze', snooze);
      await p.setBool('deadlineAlerts', deadlineAlerts);
      if (toneUri == null) {
        await p.remove('toneUri');
        await p.remove('toneTitle');
      } else {
        await p.setString('toneUri', toneUri!);
        await p.setString('toneTitle', toneTitle ?? '');
      }
      await p.setString(
          'timetable', jsonEncode(timetable.map((s) => s.toJson()).toList()));
      await p.setBool('onboarded', onboarded);
    } catch (e) {
      debugPrint('Could not save settings: $e');
    }
  }
}

final app = AppState();
