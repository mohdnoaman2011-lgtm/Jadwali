import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// ───────────────────────── النصوص / Strings ─────────────────────────

const Map<String, Map<String, String>> _tr = {
  'ar': {
    'app': 'جدولي',
    'tagline': 'جدولك الجامعي وتذكيرات محاضراتك وواجباتك واختباراتك في مكان واحد',
    'start': 'ابدأ الآن',
    'home': 'الرئيسية',
    'schedule': 'الجدول',
    'reminders': 'التذكيرات',
    'todayTitle': 'جدول اليوم',
    'nextLecture': 'المحاضرة القادمة',
    'noNext': 'لا توجد محاضرات. اضغط + لإضافة محاضرتك الأولى',
    'todayLec': 'محاضرات اليوم',
    'viewWeek': 'عرض الأسبوع',
    'noToday': 'لا محاضرات اليوم',
    'weekTitle': 'الجدول الأسبوعي',
    'noDay': 'لا محاضرات في هذا اليوم',
    'remTitle': 'التذكيرات',
    'upcoming': 'قادمة',
    'completed': 'مكتملة',
    'allDone': 'أنجزت كل التذكيرات',
    'noneDone': 'لا توجد تذكيرات مكتملة بعد',
    'today': 'اليوم',
    'tomorrow': 'غداً',
    'newReminder': 'تذكير جديد',
    'lecture': 'محاضرة',
    'assignment': 'واجب',
    'exam': 'اختبار',
    'title': 'العنوان',
    'subject': 'المادة',
    'room': 'القاعة',
    'day': 'اليوم',
    'date': 'التاريخ',
    'time': 'الوقت',
    'startTime': 'وقت البداية',
    'endTime': 'وقت الانتهاء',
    'remindBefore': 'ذكّرني قبل',
    'm10': '10 دقائق',
    'h1': 'ساعة',
    'd1': 'يوم',
    'w1': 'أسبوع',
    'soundRow': 'نغمة التنبيه',
    'save': 'حفظ',
    'saveReminder': 'حفظ التذكير',
    'required': 'مطلوب',
    'delete': 'حذف',
    'editLecture': 'تعديل المحاضرة',
    'deleteLecture': 'حذف المحاضرة',
    'confirmDelete': 'هل تريد حذف هذه المحاضرة؟',
    'yesDelete': 'نعم، احذف',
    'cancel': 'إلغاء',
    'soundTitle': 'نغمة التنبيه',
    'phoneDefault': 'نغمة الهاتف الافتراضية',
    'phoneDefaultSub': 'تستخدم النغمة المحددة في إعدادات هاتفك',
    'pickFromPhone': 'اختيار نغمة من الهاتف',
    'pickFromPhoneSub': 'من نغمات جهازك',
    'chooseTone': 'اختيار النغمة',
    'noToneChosen': 'لم تُختر نغمة بعد',
    'continuous': 'تنبيه مستمر',
    'continuousSub': 'يتكرر الصوت حتى توقفه بنفسك',
    'repeatFor': 'مدة التكرار',
    'untilStop': 'حتى أوقفه',
    'min1': 'دقيقة',
    'min5': '5 دقائق',
    'min10': '10 دقائق',
    'vibrate': 'اهتزاز مع النغمة',
    'preview': 'معاينة',
    'settings': 'الإعدادات',
    'appearance': 'المظهر',
    'light': 'فاتح',
    'dark': 'داكن',
    'system': 'حسب النظام',
    'language': 'اللغة',
    'timeFormat': 'نظام الوقت',
    'h12': '12 ساعة',
    'h24': '24 ساعة',
    'alarmBadge': 'تذكير',
    'stop': 'إيقاف التنبيه',
    'snooze': 'غفوة 5 دقائق',
    'previewBody': 'هذه معاينة لنغمة التنبيه',
  },
  'en': {
    'app': 'Jadwali',
    'tagline': 'Your university schedule and reminders for lectures, assignments and exams in one place',
    'start': 'Get started',
    'home': 'Home',
    'schedule': 'Schedule',
    'reminders': 'Reminders',
    'todayTitle': "Today's schedule",
    'nextLecture': 'Next lecture',
    'noNext': 'No lectures yet. Tap + to add your first one',
    'todayLec': "Today's lectures",
    'viewWeek': 'View week',
    'noToday': 'No lectures today',
    'weekTitle': 'Weekly schedule',
    'noDay': 'No lectures on this day',
    'remTitle': 'Reminders',
    'upcoming': 'Upcoming',
    'completed': 'Completed',
    'allDone': "You're all caught up",
    'noneDone': 'No completed reminders yet',
    'today': 'Today',
    'tomorrow': 'Tomorrow',
    'newReminder': 'New reminder',
    'lecture': 'Lecture',
    'assignment': 'Assignment',
    'exam': 'Exam',
    'title': 'Title',
    'subject': 'Subject',
    'room': 'Room',
    'day': 'Day',
    'date': 'Date',
    'time': 'Time',
    'startTime': 'Start time',
    'endTime': 'End time',
    'remindBefore': 'Remind me before',
    'm10': '10 minutes',
    'h1': '1 hour',
    'd1': '1 day',
    'w1': '1 week',
    'soundRow': 'Alert sound',
    'save': 'Save',
    'saveReminder': 'Save reminder',
    'required': 'Required',
    'delete': 'Delete',
    'editLecture': 'Edit lecture',
    'deleteLecture': 'Delete lecture',
    'confirmDelete': 'Delete this lecture?',
    'yesDelete': 'Yes, delete',
    'cancel': 'Cancel',
    'soundTitle': 'Alert sound',
    'phoneDefault': 'Phone default ringtone',
    'phoneDefaultSub': 'Uses the ringtone set in your phone settings',
    'pickFromPhone': 'Choose a tone from your phone',
    'pickFromPhoneSub': 'From your device tones',
    'chooseTone': 'Choose tone',
    'noToneChosen': 'No tone chosen yet',
    'continuous': 'Continuous alert',
    'continuousSub': 'Sound repeats until you stop it',
    'repeatFor': 'Repeat for',
    'untilStop': 'Until I stop it',
    'min1': '1 minute',
    'min5': '5 minutes',
    'min10': '10 minutes',
    'vibrate': 'Vibrate with tone',
    'preview': 'Preview',
    'settings': 'Settings',
    'appearance': 'Appearance',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'language': 'Language',
    'timeFormat': 'Time format',
    'h12': '12-hour',
    'h24': '24-hour',
    'alarmBadge': 'Reminder',
    'stop': 'Stop alarm',
    'snooze': 'Snooze 5 minutes',
    'previewBody': 'This is a preview of your alert sound',
  },
};

const _daysAr = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const _daysEn = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _monthsAr = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const _monthsEn = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

// أيام الأسبوع الدراسي: السبت إلى الخميس (DateTime.weekday: الإثنين=1 ... الأحد=7)
const List<int> kWeekdays = [6, 7, 1, 2, 3, 4];

// ───────────────────────── النماذج / Models ─────────────────────────

class Lecture {
  Lecture({
    required this.id,
    required this.subject,
    required this.weekday,
    required this.start,
    required this.end,
    this.room = '',
    this.before = 10,
  });

  int id;
  String subject;
  int weekday; // 1..7
  int start; // دقائق من منتصف الليل
  int end;
  String room;
  int before; // دقائق

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'weekday': weekday,
        'start': start,
        'end': end,
        'room': room,
        'before': before,
      };

  factory Lecture.fromJson(Map<String, dynamic> j) => Lecture(
        id: j['id'] as int,
        subject: j['subject'] as String,
        weekday: j['weekday'] as int,
        start: j['start'] as int,
        end: j['end'] as int,
        room: (j['room'] ?? '') as String,
        before: (j['before'] ?? 10) as int,
      );
}

class Reminder {
  Reminder({
    required this.id,
    required this.title,
    required this.kind,
    required this.subject,
    required this.when,
    required this.before,
    this.done = false,
  });

  int id;
  String title;
  String kind; // assignment | exam
  String subject;
  DateTime when;
  int before;
  bool done;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind,
        'subject': subject,
        'when': when.millisecondsSinceEpoch,
        'before': before,
        'done': done,
      };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
        id: j['id'] as int,
        title: j['title'] as String,
        kind: j['kind'] as String,
        subject: (j['subject'] ?? '') as String,
        when: DateTime.fromMillisecondsSinceEpoch(j['when'] as int),
        before: j['before'] as int,
        done: (j['done'] ?? false) as bool,
      );
}

// ───────────────────────── حالة التطبيق / App state ─────────────────────────

class AppState extends ChangeNotifier {
  late SharedPreferences _p;

  bool onboarded = false;
  String lang = 'ar';
  ThemeMode themeMode = ThemeMode.light;
  bool use24 = false;

  String soundMode = 'default'; // default | custom
  String toneUri = '';
  String toneTitle = '';
  bool continuous = true;
  int repeatMin = 0; // 0 = حتى أوقفه
  bool vibrate = true;

  List<Lecture> lectures = [];
  List<Reminder> reminders = [];
  int _nextId = 1;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    onboarded = _p.getBool('onboarded') ?? false;
    lang = _p.getString('lang') ?? 'ar';
    final tm = _p.getString('theme');
    themeMode = ThemeMode.values.firstWhere((m) => m.name == tm, orElse: () => ThemeMode.light);
    use24 = _p.getBool('use24') ?? false;
    soundMode = _p.getString('soundMode') ?? 'default';
    toneUri = _p.getString('toneUri') ?? '';
    toneTitle = _p.getString('toneTitle') ?? '';
    continuous = _p.getBool('continuous') ?? true;
    repeatMin = _p.getInt('repeatMin') ?? 0;
    vibrate = _p.getBool('vibrate') ?? true;
    final raw = _p.getString('data');
    if (raw != null) {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      lectures = (j['lectures'] as List).map((e) => Lecture.fromJson(e as Map<String, dynamic>)).toList();
      reminders = (j['reminders'] as List).map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
      _nextId = (j['nextId'] ?? 1) as int;
    }
  }

  Future<void> save() async {
    await _p.setBool('onboarded', onboarded);
    await _p.setString('lang', lang);
    await _p.setString('theme', themeMode.name);
    await _p.setBool('use24', use24);
    await _p.setString('soundMode', soundMode);
    await _p.setString('toneUri', toneUri);
    await _p.setString('toneTitle', toneTitle);
    await _p.setBool('continuous', continuous);
    await _p.setInt('repeatMin', repeatMin);
    await _p.setBool('vibrate', vibrate);
    await _p.setString(
      'data',
      jsonEncode({
        'lectures': lectures.map((e) => e.toJson()).toList(),
        'reminders': reminders.map((e) => e.toJson()).toList(),
        'nextId': _nextId,
      }),
    );
  }

  /// يغيّر الحالة ثم يحفظها ويحدّث الواجهة.
  Future<void> update(VoidCallback change) async {
    change();
    notifyListeners();
    await save();
  }

  int newId() => _nextId++;

  bool get ar => lang == 'ar';
  String t(String k) => _tr[lang]![k] ?? k;
  String dayName(int weekday) => ar ? _daysAr[weekday] : _daysEn[weekday];
  String shortDay(int weekday) {
    final n = dayName(weekday);
    return ar ? n : n.substring(0, 3);
  }

  String fmtMin(int m) {
    final h = m ~/ 60;
    final mm = (m % 60).toString().padLeft(2, '0');
    if (use24) return '${h.toString().padLeft(2, '0')}:$mm';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final suffix = h < 12 ? (ar ? 'ص' : 'AM') : (ar ? 'م' : 'PM');
    return '$h12:$mm $suffix';
  }

  String fmtDateTime(DateTime d) => fmtMin(d.hour * 60 + d.minute);

  String longDate(DateTime d) {
    final month = ar ? _monthsAr[d.month] : _monthsEn[d.month];
    return ar ? '${dayName(d.weekday)}، ${d.day} $month' : '${dayName(d.weekday)}, $month ${d.day}';
  }

  String dayLabel(DateTime d) {
    final now = DateTime.now();
    final a = DateTime(now.year, now.month, now.day);
    final b = DateTime(d.year, d.month, d.day);
    final diff = b.difference(a).inDays;
    if (diff == 0) return t('today');
    if (diff == 1) return t('tomorrow');
    return longDate(d);
  }

  String inText(Duration d) {
    final m = d.inMinutes;
    if (m < 1) return ar ? 'الآن' : 'now';
    if (m < 60) return ar ? 'بعد $m دقيقة' : 'in $m min';
    if (m < 1440) {
      final h = m ~/ 60;
      return ar ? 'بعد $h ساعة' : 'in $h h';
    }
    final days = m ~/ 1440;
    return ar ? 'بعد $days يوم' : 'in $days d';
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState app, required super.child}) : super(notifier: app);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

// ───────────────────────── أدوات مساعدة / Helpers ─────────────────────────

DateTime nextOccurrence(int weekday, int minutes, DateTime from) {
  var d = DateTime(from.year, from.month, from.day, minutes ~/ 60, minutes % 60);
  for (var i = 0; i < 9; i++) {
    if (d.weekday == weekday && !d.isBefore(from)) return d;
    d = DateTime(d.year, d.month, d.day + 1, minutes ~/ 60, minutes % 60);
  }
  return d;
}

Color subjectColor(String s) {
  const palette = [
    Color(0xFF5B5BD6),
    Color(0xFF0B7A6B),
    Color(0xFFD98A1F),
    Color(0xFFC2386B),
    Color(0xFF3157C8),
  ];
  var h = 0;
  for (final c in s.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return palette[h % palette.length];
}

// ───────────────────────── الإشعارات / Notifications ─────────────────────────

final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
const MethodChannel _ringtoneChannel = MethodChannel('jadwali/ringtone');

String _payload(int id, String title, String sub) => jsonEncode({'id': id, 'title': title, 'sub': sub});

void openAlarm(String? payload) {
  if (payload == null) return;
  try {
    final j = jsonDecode(payload) as Map<String, dynamic>;
    navKey.currentState?.push(MaterialPageRoute<void>(
      builder: (_) => AlarmPage(id: j['id'] as int, title: j['title'] as String, sub: j['sub'] as String),
    ));
  } catch (_) {}
}

Future<void> initNotifications() async {
  tzdata.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (_) {}

  await plugin.initialize(
    const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    onDidReceiveNotificationResponse: (r) => openAlarm(r.payload),
  );

  final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.requestNotificationsPermission();
  try {
    await android?.requestExactAlarmsPermission();
  } catch (_) {}

  final launch = await plugin.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp ?? false) {
    final payload = launch!.notificationResponse?.payload;
    WidgetsBinding.instance.addPostFrameCallback((_) => openAlarm(payload));
  }
}

NotificationDetails _details(AppState a) {
  final custom = a.soundMode == 'custom' && a.toneUri.isNotEmpty;
  var h = 0;
  if (custom) {
    for (final c in a.toneUri.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
  }
  // القناة في أندرويد لا تتغير بعد إنشائها، لذلك يتغير معرّفها مع الإعدادات.
  final channelId = 'jadwali_${h}_${a.continuous ? 1 : 0}_${a.vibrate ? 1 : 0}';
  return NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      'Jadwali alerts',
      channelDescription: 'Lecture, assignment and exam alerts',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: custom ? UriAndroidNotificationSound(a.toneUri) : null,
      enableVibration: a.vibrate,
      fullScreenIntent: true,
      autoCancel: true,
      timeoutAfter: (a.continuous && a.repeatMin > 0) ? a.repeatMin * 60000 : null,
      // FLAG_INSISTENT = 4: يكرر الصوت حتى يتم إغلاق الإشعار
      additionalFlags: a.continuous ? Int32List.fromList(<int>[4]) : null,
    ),
  );
}

Future<void> _schedule(
  int id,
  String title,
  String body,
  DateTime at,
  AppState a, {
  DateTimeComponents? repeat,
}) async {
  final when = tz.TZDateTime.from(at, tz.local);
  Future<void> go(AndroidScheduleMode mode) => plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details(a),
        payload: _payload(id, title, body),
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: repeat,
      );
  try {
    await go(AndroidScheduleMode.exactAllowWhileIdle);
  } catch (_) {
    await go(AndroidScheduleMode.inexactAllowWhileIdle);
  }
}

Future<void> scheduleReminder(AppState a, Reminder r) async {
  await plugin.cancel(r.id);
  if (r.done) return;
  final at = r.when.subtract(Duration(minutes: r.before));
  if (at.isBefore(DateTime.now())) return;
  final body = r.subject.isEmpty ? a.t(r.kind) : '${r.subject} · ${a.t(r.kind)}';
  await _schedule(r.id, r.title, body, at, a);
}

Future<void> scheduleLecture(AppState a, Lecture l) async {
  await plugin.cancel(l.id);
  final now = DateTime.now();
  var start = nextOccurrence(l.weekday, l.start, now);
  var at = start.subtract(Duration(minutes: l.before));
  while (at.isBefore(now)) {
    start = DateTime(start.year, start.month, start.day + 7, l.start ~/ 60, l.start % 60);
    at = start.subtract(Duration(minutes: l.before));
  }
  final body = l.room.isEmpty ? a.fmtMin(l.start) : '${a.fmtMin(l.start)} · ${a.t('room')} ${l.room}';
  await _schedule(l.id, l.subject, body, at, a, repeat: DateTimeComponents.dayOfWeekAndTime);
}

/// يعيد جدولة كل شيء (بعد تغيير إعدادات النغمة أو اللغة أو نظام الوقت).
Future<void> rescheduleAll(AppState a) async {
  for (final l in a.lectures) {
    await scheduleLecture(a, l);
  }
  for (final r in a.reminders) {
    await scheduleReminder(a, r);
  }
}

Future<void> previewAlert(AppState a) async {
  const id = 2147483000;
  final payload = _payload(id, a.t('soundTitle'), a.t('previewBody'));
  await plugin.show(id, a.t('soundTitle'), a.t('previewBody'), _details(a), payload: payload);
  openAlarm(payload);
}

Future<void> pickRingtone(AppState a) async {
  try {
    final res = await _ringtoneChannel.invokeMethod<Map<dynamic, dynamic>>('pick', {'current': a.toneUri});
    if (res != null) {
      final uri = (res['uri'] ?? '') as String;
      final title = (res['title'] ?? '') as String;
      if (uri.isNotEmpty) {
        await a.update(() {
          a.toneUri = uri;
          a.toneTitle = title;
          a.soundMode = 'custom';
        });
      }
    }
  } catch (_) {}
}

// ───────────────────────── التطبيق / App ─────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppState();
  await app.load();
  await initNotifications();
  runApp(JadwaliApp(app: app));
}

ThemeData _theme(Brightness b) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B7A6B), brightness: b),
  );
  return base.copyWith(textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme));
}

class JadwaliApp extends StatelessWidget {
  const JadwaliApp({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      app: app,
      child: Builder(builder: (context) {
        final a = AppScope.of(context);
        return MaterialApp(
          navigatorKey: navKey,
          debugShowCheckedModeBanner: false,
          title: a.t('app'),
          locale: Locale(a.lang),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: a.themeMode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: a.onboarded ? const ShellPage() : const SplashPage(),
        );
      }),
    );
  }
}

// ───────────────────────── شاشة البداية ─────────────────────────

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const _navy = Color(0xFF0F2A6B);

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', width: 240, semanticLabel: a.t('app')),
                    const SizedBox(height: 16),
                    Text(
                      a.t('tagline'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, height: 1.7, color: Color(0xFF3D4A66)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => a.update(() => a.onboarded = true),
                  child: Text(a.t('start'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── الهيكل الرئيسي ─────────────────────────

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final pages = [
      HomePage(onOpenWeek: () => setState(() => index = 1)),
      const WeekPage(),
      const RemindersPage(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[index]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddPage())),
        icon: const Icon(Icons.add),
        label: Text(a.t('newReminder')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: a.t('home')),
          NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), selectedIcon: const Icon(Icons.calendar_month), label: a.t('schedule')),
          NavigationDestination(icon: const Icon(Icons.notifications_outlined), selectedIcon: const Icon(Icons.notifications), label: a.t('reminders')),
        ],
      ),
    );
  }
}

// ───────────────────────── الرئيسية ─────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenWeek});
  final VoidCallback onOpenWeek;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    final today = a.lectures.where((l) => l.weekday == now.weekday).toList()
      ..sort((x, y) => x.start.compareTo(y.start));

    Lecture? next;
    DateTime? nextAt;
    for (final l in a.lectures) {
      final o = nextOccurrence(l.weekday, l.start, now);
      if (nextAt == null || o.isBefore(nextAt)) {
        next = l;
        nextAt = o;
      }
    }

    final due = a.reminders.where((r) => !r.done && r.when.isAfter(now)).toList()
      ..sort((x, y) => x.when.compareTo(y.when));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.longDate(now), style: TextStyle(color: cs.onSurfaceVariant)),
                  Text(a.t('todayTitle'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: a.t('settings'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (next == null)
          Card(
            child: Padding(padding: const EdgeInsets.all(20), child: Text(a.t('noNext'))),
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: cs.onPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(a.t('nextLecture'), style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 14),
                Text(next.subject, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: cs.onPrimary)),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.schedule, size: 18, color: cs.onPrimary),
                  const SizedBox(width: 8),
                  Text('${a.dayLabel(nextAt!)} · ${a.fmtMin(next.start)} – ${a.fmtMin(next.end)}', style: TextStyle(color: cs.onPrimary)),
                ]),
                if (next.room.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.place_outlined, size: 18, color: cs.onPrimary),
                    const SizedBox(width: 8),
                    Text('${a.t('room')} ${next.room}', style: TextStyle(color: cs.onPrimary)),
                  ]),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: cs.onPrimary, borderRadius: BorderRadius.circular(20)),
                  child: Text(a.inText(nextAt!.difference(now)), style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: Text(a.t('todayLec'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            TextButton(onPressed: onOpenWeek, child: Text(a.t('viewWeek'))),
          ],
        ),
        if (today.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(a.t('noToday'), style: TextStyle(color: cs.onSurfaceVariant)))
        else
          for (final l in today) LectureTile(lecture: l),
        if (due.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFFBEBCB),
            child: ListTile(
              title: Text('${a.dayLabel(due.first.when)} · ${a.fmtDateTime(due.first.when)}', style: const TextStyle(fontSize: 13, color: Color(0xFF5E3C00))),
              subtitle: Text(due.first.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF5E3C00))),
            ),
          ),
        ],
      ],
    );
  }
}

class LectureTile extends StatelessWidget {
  const LectureTile({super.key, required this.lecture});
  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final color = subjectColor(lecture.subject);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showLectureActions(context, lecture),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(width: 6, height: 52, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.fmtMin(lecture.start), style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(a.fmtMin(lecture.end), style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lecture.subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (lecture.room.isNotEmpty)
                      Text('${a.t('room')} ${lecture.room}', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// ورقة سفلية بخيارات المحاضرة: تعديل أو حذف (مع تأكيد).
Future<void> showLectureActions(BuildContext context, Lecture l) {
  final a = AppScope.of(context);
  final cs = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 6, height: 48, decoration: BoxDecoration(color: subjectColor(l.subject), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.subject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(
                        [
                          '${a.dayName(l.weekday)} · ${a.fmtMin(l.start)} – ${a.fmtMin(l.end)}',
                          if (l.room.isNotEmpty) '${a.t('room')} ${l.room}',
                        ].join(' · '),
                        style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(sheetCtx).pop();
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddPage(edit: l)));
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(a.t('editLecture')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: cs.errorContainer,
                  foregroundColor: cs.onErrorContainer,
                ),
                onPressed: () async {
                  Navigator.of(sheetCtx).pop();
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: Text(a.t('confirmDelete')),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(a.t('cancel'))),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                          onPressed: () => Navigator.of(d).pop(true),
                          child: Text(a.t('yesDelete')),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await plugin.cancel(l.id);
                    await a.update(() => a.lectures.removeWhere((x) => x.id == l.id));
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(a.t('deleteLecture')),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── الجدول الأسبوعي ─────────────────────────

class WeekPage extends StatefulWidget {
  const WeekPage({super.key});

  @override
  State<WeekPage> createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
  late int day = kWeekdays.contains(DateTime.now().weekday) ? DateTime.now().weekday : 6;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final list = a.lectures.where((l) => l.weekday == day).toList()..sort((x, y) => x.start.compareTo(y.start));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Text(a.t('weekTitle'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final d in kWeekdays)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => day = d),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: d == day ? cs.primary : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        a.shortDay(d),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: d == day ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(child: Text(a.t('noDay'), style: TextStyle(color: cs.onSurfaceVariant))),
          )
        else
          for (final l in list) LectureTile(lecture: l),
      ],
    );
  }
}

// ───────────────────────── التذكيرات ─────────────────────────

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  bool showDone = false;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final list = a.reminders.where((r) => r.done == showDone).toList()..sort((x, y) => x.when.compareTo(y.when));

    final groups = <String, List<Reminder>>{};
    for (final r in list) {
      groups.putIfAbsent('${r.when.year}-${r.when.month}-${r.when.day}', () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Text(a.t('remTitle'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, label: Text(a.t('upcoming'))),
            ButtonSegment(value: true, label: Text(a.t('completed'))),
          ],
          selected: {showDone},
          onSelectionChanged: (s) => setState(() => showDone = s.first),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: [
                Icon(Icons.task_alt, size: 44, color: cs.onSurfaceVariant),
                const SizedBox(height: 10),
                Text(showDone ? a.t('noneDone') : a.t('allDone'), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
              ],
            ),
          ),
        for (final g in groups.values) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(a.dayLabel(g.first.when), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          ),
          for (final r in g) ReminderTile(reminder: r),
        ],
      ],
    );
  }
}

class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.reminder});
  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final r = reminder;
    final isExam = r.kind == 'exam';
    final tagBg = isExam ? const Color(0xFFFBDDE6) : const Color(0xFFFBEBCB);
    final tagFg = isExam ? const Color(0xFF8A1F42) : const Color(0xFF5E3C00);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              await a.update(() => r.done = !r.done);
              await scheduleReminder(a, r);
            },
            icon: Icon(r.done ? Icons.check_circle : Icons.radio_button_unchecked, color: r.done ? cs.primary : cs.outline),
          ),
          Expanded(
            child: Opacity(
              opacity: r.done ? 0.55 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, decoration: r.done ? TextDecoration.lineThrough : null),
                    ),
                    Text(
                      [a.fmtDateTime(r.when), if (r.subject.isNotEmpty) r.subject].join(' · '),
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(10)),
            child: Text(a.t(r.kind), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tagFg)),
          ),
          IconButton(
            tooltip: a.t('delete'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await plugin.cancel(r.id);
              await a.update(() => a.reminders.removeWhere((x) => x.id == r.id));
            },
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── إضافة تذكير ─────────────────────────

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.edit});
  final Lecture? edit;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String kind = 'assignment'; // lecture | assignment | exam
  final titleCtl = TextEditingController();
  final subjectCtl = TextEditingController();
  final roomCtl = TextEditingController();
  int weekday = 6;
  DateTime date = DateTime.now().add(const Duration(days: 1));
  int startMin = 9 * 60;
  int endMin = 10 * 60 + 30;
  int before = 60;
  String? error;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      kind = 'lecture';
      subjectCtl.text = e.subject;
      roomCtl.text = e.room;
      weekday = e.weekday;
      startMin = e.start;
      endMin = e.end;
      before = e.before;
    }
  }

  @override
  void dispose() {
    titleCtl.dispose();
    subjectCtl.dispose();
    roomCtl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isEnd) async {
    final cur = isEnd ? endMin : startMin;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: cur ~/ 60, minute: cur % 60));
    if (t == null) return;
    setState(() {
      final m = t.hour * 60 + t.minute;
      if (isEnd) {
        endMin = m;
      } else {
        startMin = m;
        if (endMin <= startMin) endMin = (startMin + 90).clamp(0, 23 * 60 + 59);
      }
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => date = d);
  }

  Future<void> _save() async {
    final a = AppScope.of(context);
    final isLecture = kind == 'lecture';
    final subject = subjectCtl.text.trim();
    final title = titleCtl.text.trim();
    if ((isLecture && subject.isEmpty) || (!isLecture && title.isEmpty)) {
      setState(() => error = a.t('required'));
      return;
    }
    final nav = Navigator.of(context);
    if (isLecture) {
      final e = widget.edit;
      final l = Lecture(
        id: e?.id ?? a.newId(),
        subject: subject,
        weekday: weekday,
        start: startMin,
        end: endMin,
        room: roomCtl.text.trim(),
        before: before > 60 ? 60 : before,
      );
      if (e != null) {
        await a.update(() {
          final i = a.lectures.indexWhere((x) => x.id == e.id);
          if (i >= 0) a.lectures[i] = l;
        });
      } else {
        await a.update(() => a.lectures.add(l));
      }
      await scheduleLecture(a, l);
    } else {
      final r = Reminder(
        id: a.newId(),
        title: title,
        kind: kind,
        subject: subject,
        when: DateTime(date.year, date.month, date.day, startMin ~/ 60, startMin % 60),
        before: before,
      );
      await a.update(() => a.reminders.add(r));
      await scheduleReminder(a, r);
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final isLecture = kind == 'lecture';
    final subjects = {...a.lectures.map((l) => l.subject), ...a.reminders.map((r) => r.subject)}..remove('');
    final befores = <int, String>{10: a.t('m10'), 60: a.t('h1'), 1440: a.t('d1'), 10080: a.t('w1')};

    return Scaffold(
      appBar: AppBar(title: Text(widget.edit != null ? a.t('editLecture') : a.t('newReminder'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (widget.edit == null)
            SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 'lecture', label: Text(a.t('lecture'))),
              ButtonSegment(value: 'assignment', label: Text(a.t('assignment'))),
              ButtonSegment(value: 'exam', label: Text(a.t('exam'))),
            ],
            selected: {kind},
            onSelectionChanged: (s) => setState(() {
              kind = s.first;
              before = kind == 'lecture' ? 10 : 60;
              error = null;
            }),
          ),
          const SizedBox(height: 16),
          if (!isLecture) ...[
            TextField(
              controller: titleCtl,
              decoration: InputDecoration(labelText: a.t('title'), border: const OutlineInputBorder(), errorText: error),
            ),
            const SizedBox(height: 14),
          ],
          TextField(
            controller: subjectCtl,
            decoration: InputDecoration(
              labelText: a.t('subject'),
              border: const OutlineInputBorder(),
              errorText: isLecture ? error : null,
            ),
          ),
          if (subjects.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in subjects)
                  ActionChip(
                    avatar: CircleAvatar(backgroundColor: subjectColor(s), radius: 6),
                    label: Text(s),
                    onPressed: () => setState(() => subjectCtl.text = s),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          if (isLecture) ...[
            TextField(controller: roomCtl, decoration: InputDecoration(labelText: a.t('room'), border: const OutlineInputBorder())),
            const SizedBox(height: 14),
            Text(a.t('day'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in kWeekdays)
                  ChoiceChip(label: Text(a.dayName(d)), selected: weekday == d, onSelected: (_) => setState(() => weekday = d)),
              ],
            ),
          ] else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(a.t('date')),
              subtitle: Text(a.longDate(date)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickDate,
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(isLecture ? a.t('startTime') : a.t('time')),
                  subtitle: Text(a.fmtMin(startMin)),
                  onTap: () => _pickTime(false),
                ),
              ),
              if (isLecture)
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(a.t('endTime')),
                    subtitle: Text(a.fmtMin(endMin)),
                    onTap: () => _pickTime(true),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(a.t('remindBefore'), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final e in befores.entries)
                if (!isLecture || e.key <= 60)
                  ChoiceChip(label: Text(e.value), selected: before == e.key, onSelected: (_) => setState(() => before = e.key)),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: Icon(Icons.volume_up_outlined, color: cs.onSurfaceVariant),
              title: Text(a.t('soundRow')),
              subtitle: Text(a.soundMode == 'custom' && a.toneTitle.isNotEmpty ? a.toneTitle : a.t('phoneDefault')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SoundPage()));
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: FilledButton(onPressed: _save, child: Text(a.t('saveReminder'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── نغمة التنبيه ─────────────────────────

class SoundPage extends StatelessWidget {
  const SoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;

    Widget option({required bool selected, required String title, required String sub, required VoidCallback onTap}) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? cs.primary : Colors.transparent, width: 2),
        ),
        child: ListTile(
          leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? cs.primary : cs.outline),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(sub),
          onTap: onTap,
        ),
      );
    }

    final durOptions = <int, String>{0: a.t('untilStop'), 1: a.t('min1'), 5: a.t('min5'), 10: a.t('min10')};

    return Scaffold(
      appBar: AppBar(title: Text(a.t('soundTitle'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          option(
            selected: a.soundMode == 'default',
            title: a.t('phoneDefault'),
            sub: a.t('phoneDefaultSub'),
            onTap: () => a.update(() => a.soundMode = 'default'),
          ),
          option(
            selected: a.soundMode == 'custom',
            title: a.t('pickFromPhone'),
            sub: a.toneTitle.isNotEmpty ? a.toneTitle : a.t('pickFromPhoneSub'),
            onTap: () async {
              if (a.toneUri.isEmpty) {
                await pickRingtone(a);
              } else {
                await a.update(() => a.soundMode = 'custom');
              }
            },
          ),
          if (a.soundMode == 'custom')
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton.icon(
                onPressed: () => pickRingtone(a),
                icon: const Icon(Icons.library_music_outlined),
                label: Text(a.toneTitle.isNotEmpty ? '${a.t('chooseTone')}: ${a.toneTitle}' : a.t('chooseTone')),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.t('continuous'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(a.t('continuousSub'), style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Switch(value: a.continuous, onChanged: (v) => a.update(() => a.continuous = v)),
                    ],
                  ),
                  if (a.continuous) ...[
                    const SizedBox(height: 10),
                    Text(a.t('repeatFor'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in durOptions.entries)
                          ChoiceChip(label: Text(e.value), selected: a.repeatMin == e.key, onSelected: (_) => a.update(() => a.repeatMin = e.key)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: Text(a.t('vibrate')),
              value: a.vibrate,
              onChanged: (v) => a.update(() => a.vibrate = v),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(onPressed: () => previewAlert(a), child: Text(a.t('preview'))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await rescheduleAll(a);
                      nav.pop();
                    },
                    child: Text(a.t('save')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── الإعدادات ─────────────────────────

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);

    Widget section(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: child),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(a.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          section(
            a.t('appearance'),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(a.t('light'))),
                ButtonSegment(value: ThemeMode.dark, label: Text(a.t('dark'))),
                ButtonSegment(value: ThemeMode.system, label: Text(a.t('system'))),
              ],
              selected: {a.themeMode},
              onSelectionChanged: (s) => a.update(() => a.themeMode = s.first),
            ),
          ),
          section(
            a.t('language'),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'ar', label: Text('العربية')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {a.lang},
              onSelectionChanged: (s) async {
                await a.update(() => a.lang = s.first);
                await rescheduleAll(a);
              },
            ),
          ),
          section(
            a.t('timeFormat'),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(a.t('h12'))),
                ButtonSegment(value: true, label: Text(a.t('h24'))),
              ],
              selected: {a.use24},
              onSelectionChanged: (s) async {
                await a.update(() => a.use24 = s.first);
                await rescheduleAll(a);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.volume_up_outlined),
              title: Text(a.t('soundRow')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SoundPage())),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── شاشة التنبيه الرنّان ─────────────────────────

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key, required this.id, required this.title, required this.sub});
  final int id;
  final String title;
  final String sub;

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    await plugin.cancel(widget.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    final a = AppScope.of(context);
    final nav = Navigator.of(context);
    await plugin.cancel(widget.id);
    await _schedule(widget.id, widget.title, widget.sub, DateTime.now().add(const Duration(minutes: 5)), a);
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    const bg = Color(0xFF062E27);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                child: Text(a.t('alarmBadge'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Text(a.fmtDateTime(now), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(a.longDate(now), style: const TextStyle(color: Color(0xFFB8D4CD))),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _c,
                      builder: (context, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          for (final shift in [0.0, 0.33, 0.66])
                            Builder(builder: (context) {
                              final t = (_c.value + shift) % 1.0;
                              return Opacity(
                                opacity: (1 - t) * 0.55,
                                child: Container(
                                  width: 200 * (0.55 + 0.95 * t),
                                  height: 200 * (0.55 + 0.95 * t),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
                                ),
                              );
                            }),
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
                            child: const Icon(Icons.notifications_active, size: 54, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text(widget.sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFFD5E8E3))),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: bg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _stop,
                  icon: const Icon(Icons.stop),
                  label: Text(a.t('stop'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _snooze,
                  child: Text(a.t('snooze'), style: const TextStyle(fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
