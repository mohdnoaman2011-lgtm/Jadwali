import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// ───────────────────────── Constants & strings ─────────────────────────

const kAcc = Color(0xFF3B4BDB);
const kDeep = Color(0xFF2B37A8);
const kWarn = Color(0xFFB4430A);
const kTeal = Color(0xFF0B7A6B);

/// Shared look for icon buttons (44×44, 12px corners) — same as the mockup.
final kIconStyle = IconButton.styleFrom(
  fixedSize: const Size(44, 44),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

const Map<String, Map<String, String>> _s = {
  'ar': {
    'name': 'جدولي',
    'tag': 'لا تفوّت محاضرة أو موعد تسليم بعد اليوم',
    'f1': 'جدولك الجامعي في مكان واحد',
    'f2': 'تنبيهات ذكية قبل كل محاضرة',
    'f3': 'تذكير بالاختبارات والتسليمات',
    'go': 'ابدأ الآن',
    'next': 'المحاضرة القادمة',
    'inm': 'بعد {n} دقيقة',
    'nonext': 'لا محاضرات قادمة اليوم',
    'sch': 'جدول اليوم',
    'none': 'لا توجد مواعيد لهذا اليوم',
    'due': 'مستحقات قريبة',
    'rb': 'تذكير قبل {r}',
    'tHome': 'الرئيسية',
    'tSched': 'الجدول',
    'tNew': 'تذكير جديد',
    'wk': 'الجدول الأسبوعي',
    'details': 'التفاصيل',
    'when': 'الموعد',
    'alert': 'التنبيه',
    'course': 'اسم المقرر',
    'type': 'النوع',
    'lecture': 'محاضرة',
    'exam': 'اختبار',
    'dueT': 'تسليم',
    'day': 'اليوم',
    'from': 'من',
    'to': 'إلى',
    'remMe': 'ذكّرني قبل',
    'repW': 'تكرار أسبوعي',
    'save': 'حفظ التذكير',
    'req': 'أدخل اسم المقرر',
    'terr': 'تأكد من وقت البداية والنهاية',
    'saved': 'تم حفظ التذكير',
    'on': 'تم تفعيل التذكير',
    'off': 'تم إيقاف التذكير',
    'lang': 'English',
    'tSet': 'الضبط',
    'theme': 'المظهر',
    'light': 'فاتح',
    'darkT': 'داكن',
    'langT': 'اللغة',
    'notif': 'التنبيهات',
    'testN': 'إرسال تنبيه تجريبي',
    'testBody': 'هذا تنبيه تجريبي، التنبيهات تعمل',
    'notifAll': 'تفعيل كل التنبيهات',
    'defRem': 'وقت التنبيه الافتراضي',
    'firstD': 'أول يوم في الأسبوع',
    'sat': 'السبت',
    'sun': 'الأحد',
    'timeF': 'صيغة الوقت',
    'h12': '12 ساعة',
    'h24': '24 ساعة',
    'editT': 'تعديل التذكير',
    'saveE': 'حفظ التعديلات',
    'del': 'حذف التذكير',
    'deleted': 'تم حذف التذكير',
  },
  'en': {
    'name': 'Jadwali',
    'tag': 'Never miss a lecture or deadline again',
    'f1': 'Your university schedule in one place',
    'f2': 'Smart alerts before every lecture',
    'f3': 'Reminders for exams and deadlines',
    'go': 'Get started',
    'next': 'Next lecture',
    'inm': 'in {n} min',
    'nonext': 'No more lectures today',
    'sch': "Today's schedule",
    'none': 'Nothing scheduled for this day',
    'due': 'Upcoming deadlines',
    'rb': 'Remind {r} before',
    'tHome': 'Home',
    'tSched': 'Schedule',
    'tNew': 'New reminder',
    'wk': 'Weekly schedule',
    'details': 'Details',
    'when': 'Schedule',
    'alert': 'Alert',
    'course': 'Course name',
    'type': 'Type',
    'lecture': 'Lecture',
    'exam': 'Exam',
    'dueT': 'Deadline',
    'day': 'Day',
    'from': 'From',
    'to': 'To',
    'remMe': 'Remind me before',
    'repW': 'Repeat weekly',
    'save': 'Save reminder',
    'req': 'Enter a course name',
    'terr': 'Check the start and end times',
    'saved': 'Reminder saved',
    'on': 'Reminder on',
    'off': 'Reminder off',
    'lang': 'العربية',
    'tSet': 'Settings',
    'theme': 'Appearance',
    'light': 'Light',
    'darkT': 'Dark',
    'langT': 'Language',
    'notif': 'Notifications',
    'testN': 'Send a test alert',
    'testBody': 'This is a test alert. Notifications are working',
    'notifAll': 'All notifications',
    'defRem': 'Default reminder time',
    'firstD': 'First day of the week',
    'sat': 'Saturday',
    'sun': 'Sunday',
    'timeF': 'Time format',
    'h12': '12-hour',
    'h24': '24-hour',
    'editT': 'Edit reminder',
    'saveE': 'Save changes',
    'del': 'Delete reminder',
    'deleted': 'Reminder deleted',
  },
};

const Map<String, Map<int, String>> _rl = {
  'ar': {15: '15 د', 30: '30 د', 60: 'ساعة', 180: '3 ساعات', 1440: 'يوم'},
  'en': {15: '15 min', 30: '30 min', 60: '1 hour', 180: '3 hours', 1440: '1 day'},
};

// Index 0 = Sunday … 6 = Saturday (same as the web version).
const _arDays = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
const _enDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const _arMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const _enMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

String tr(String k) => _s[store.lang]![k]!;
String T(Map<String, String> m) => m[store.lang] ?? m.values.first;

String nd(String s) => store.ar
    ? s.replaceAllMapped(RegExp(r'\d'), (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)])
    : s;

String fm(int m) {
  final h = m ~/ 60;
  final mm = (m % 60).toString().padLeft(2, '0');
  if (store.h24) return nd('${h.toString().padLeft(2, '0')}:$mm');
  final p = store.ar ? (h < 12 ? 'ص' : 'م') : (h < 12 ? 'AM' : 'PM');
  return '${nd('${h % 12 == 0 ? 12 : h % 12}:$mm')} $p';
}

String dayName(int d) => store.ar ? _arDays[d] : _enDays[d].substring(0, 3);

String rb(int m) =>
    nd(tr('rb').replaceAll('{r}', _rl[store.lang]![m] ?? '$m'));

String dateStr(DateTime d) {
  final i = d.weekday % 7;
  return store.ar
      ? '${_arDays[i]} ${nd('${d.day}')} ${_arMonths[d.month - 1]}'
      : '${_enDays[i]}, ${_enMonths[d.month - 1]} ${d.day}';
}

// ───────────────────────── Model & state ─────────────────────────

enum Kind { lecture, exam, due }

Color kindColor(Kind k) => switch (k) {
      Kind.lecture => kAcc,
      Kind.exam => kWarn,
      Kind.due => kTeal,
    };

String kindLabel(Kind k) => tr(switch (k) {
      Kind.lecture => 'lecture',
      Kind.exam => 'exam',
      Kind.due => 'dueT',
    });

class Item {
  Item({
    required this.id,
    required this.title,
    required this.kind,
    required this.day,
    required this.start,
    required this.end,
    required this.remind,
    this.room,
    this.on = true,
    this.weekly = true,
  });

  final int id;
  final Map<String, String> title;
  final Kind kind;
  final int day; // 0 = Sunday … 6 = Saturday
  final int start; // minutes after midnight
  final int end;
  final int remind; // minutes before
  final Map<String, String>? room;
  bool on;
  final bool weekly;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind.name,
        'day': day,
        'start': start,
        'end': end,
        'remind': remind,
        'room': room,
        'on': on,
        'weekly': weekly,
      };

  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'] as int,
        title: Map<String, String>.from(j['title'] as Map),
        kind: Kind.values.byName(j['kind'] as String),
        day: j['day'] as int,
        start: j['start'] as int,
        end: j['end'] as int,
        remind: j['remind'] as int,
        room: j['room'] == null ? null : Map<String, String>.from(j['room'] as Map),
        on: j['on'] as bool? ?? true,
        weekly: j['weekly'] as bool? ?? true,
      );
}

class Next {
  Next(this.item, this.minutes);
  final Item item;
  final int? minutes;
}

class AppState extends ChangeNotifier {
  String lang = 'ar';
  List<Item> items = [];
  int tab = 0;
  ThemeMode mode = ThemeMode.system;
  bool notify = true; // master switch for all alerts
  int defRemind = 30; // default lead time for new reminders
  int firstDay = 6; // 6 = Saturday, 0 = Sunday
  bool h24 = false; // 24-hour clock
  late int sel = tdx;

  bool get ar => lang == 'ar';

  List<int> get weekOrder => firstDay == 6 ? [6, 0, 1, 2, 3, 4] : [0, 1, 2, 3, 4, 6];

  /// Today's day index; Friday falls back to Sunday (weekend).
  int get tdx {
    final i = DateTime.now().weekday % 7;
    return i == 5 ? 0 : i;
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    lang = p.getString('lang') ?? 'ar';
    try {
      mode = ThemeMode.values.byName(p.getString('theme') ?? 'system');
    } catch (_) {}
    notify = p.getBool('notify') ?? true;
    defRemind = p.getInt('defRemind') ?? 30;
    firstDay = p.getInt('firstDay') ?? 6;
    h24 = p.getBool('h24') ?? false;
    final raw = p.getString('items');
    try {
      items = raw == null
          ? _seed()
          : (jsonDecode(raw) as List)
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList();
    } catch (_) {
      items = _seed();
    }
    sel = tdx;
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', lang);
    await p.setString('theme', mode.name);
    await p.setBool('notify', notify);
    await p.setInt('defRemind', defRemind);
    await p.setInt('firstDay', firstDay);
    await p.setBool('h24', h24);
    await p.setString('items', jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  void setLang(String l) {
    lang = l;
    _persist();
    notifyListeners();
    Notifier.rescheduleAll(items);
  }

  void setMode(ThemeMode m) {
    mode = m;
    _persist();
    notifyListeners();
  }

  void update(Item n) {
    final i = items.indexWhere((x) => x.id == n.id);
    if (i < 0) return;
    items[i] = n;
    _persist();
    notifyListeners();
    Notifier.rescheduleAll(items);
  }

  void remove(int id) {
    items.removeWhere((x) => x.id == id);
    _persist();
    notifyListeners();
    Notifier.rescheduleAll(items);
  }

  void setNotify(bool v) {
    notify = v;
    _persist();
    notifyListeners();
    Notifier.rescheduleAll(items);
  }

  void setDefRemind(int m) {
    defRemind = m;
    _persist();
    notifyListeners();
  }

  void setFirstDay(int d) {
    firstDay = d;
    _persist();
    notifyListeners();
  }

  void setH24(bool v) {
    h24 = v;
    _persist();
    notifyListeners();
    Notifier.rescheduleAll(items);
  }

  void goTab(int i) {
    tab = i;
    notifyListeners();
  }

  void selectDay(int d) {
    sel = d;
    notifyListeners();
  }

  void toggle(Item i) {
    i.on = !i.on;
    _persist();
    notifyListeners();
    Notifier.rescheduleAll(items);
  }

  void add(Item i) {
    items.add(i);
    _persist();
    notifyListeners();
    Notifier.rescheduleAll(items);
  }

  List<Item> dayItems(int d) => items.where((i) => i.day == d && i.kind != Kind.due).toList()
    ..sort((a, b) => a.start.compareTo(b.start));

  List<Item> dues() => items.where((i) => i.kind == Kind.due).toList()
    ..sort((a, b) => a.day != b.day ? a.day.compareTo(b.day) : a.start.compareTo(b.start));

  Next? next() {
    final l = dayItems(tdx);
    final now = DateTime.now();
    if (now.weekday % 7 == tdx) {
      final nm = now.hour * 60 + now.minute;
      for (final i in l) {
        if (i.start > nm) return Next(i, i.start - nm);
      }
      return null;
    }
    return l.isEmpty ? null : Next(l.first, null);
  }
}

final store = AppState();

Map<String, String> _b(String ar, String en) => {'ar': ar, 'en': en};

List<Item> _seed() => [
      Item(id: 1, title: _b('هياكل البيانات', 'Data Structures'), kind: Kind.lecture, day: 1, start: 540, end: 630, remind: 30, room: _b('قاعة 214', 'Room 214')),
      Item(id: 2, title: _b('التفاضل والتكامل', 'Calculus'), kind: Kind.lecture, day: 1, start: 660, end: 750, remind: 15, room: _b('قاعة 103', 'Room 103')),
      Item(id: 3, title: _b('مختبر الفيزياء', 'Physics Lab'), kind: Kind.lecture, day: 1, start: 780, end: 870, remind: 60, room: _b('مبنى العلوم', 'Science Bldg')),
      Item(id: 4, title: _b('تسليم واجب الإحصاء', 'Statistics assignment due'), kind: Kind.due, day: 2, start: 1439, end: 1439, remind: 180),
      Item(id: 5, title: _b('التفاضل والتكامل', 'Calculus'), kind: Kind.lecture, day: 0, start: 540, end: 630, remind: 15, room: _b('قاعة 103', 'Room 103')),
      Item(id: 6, title: _b('هياكل البيانات', 'Data Structures'), kind: Kind.lecture, day: 2, start: 540, end: 630, remind: 30, room: _b('قاعة 214', 'Room 214')),
      Item(id: 7, title: _b('مختبر الفيزياء', 'Physics Lab'), kind: Kind.lecture, day: 2, start: 780, end: 870, remind: 60, room: _b('مبنى العلوم', 'Science Bldg')),
      Item(id: 8, title: _b('اختبار التفاضل النصفي', 'Calculus midterm'), kind: Kind.exam, day: 3, start: 840, end: 930, remind: 1440, room: _b('قاعة 103', 'Room 103')),
      Item(id: 9, title: _b('هياكل البيانات', 'Data Structures'), kind: Kind.lecture, day: 4, start: 540, end: 630, remind: 30, room: _b('قاعة 214', 'Room 214')),
    ];

// ───────────────────────── Notifications ─────────────────────────

class Notifier {
  static final _p = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'jadwali_reminders',
      'Reminders',
      channelDescription: 'Lecture, exam and deadline reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
      } catch (_) {}
      await _p.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ));
      await _p
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {}
  }

  /// First moment the reminder should fire (start time minus the lead time).
  static tz.TZDateTime _next(Item i) {
    final now = tz.TZDateTime.now(tz.local);
    final wd = i.day == 0 ? 7 : i.day; // DateTime: Mon=1 … Sun=7
    for (var add = 0; add < 15; add++) {
      final d = now.add(Duration(days: add));
      if (d.weekday != wd) continue;
      final t = tz.TZDateTime(tz.local, d.year, d.month, d.day).add(Duration(minutes: i.start - i.remind));
      if (t.isAfter(now)) return t;
    }
    return now.add(const Duration(minutes: 1));
  }

  static Future<void> rescheduleAll(List<Item> items) async {
    if (!_ready) return;
    try {
      await _p.cancelAll();
      if (!store.notify) return;
      for (final i in items) {
        if (!i.on) continue;
        await _p.zonedSchedule(
          i.id % 2147483647,
          T(i.title),
          '${kindLabel(i.kind)} · ${fm(i.start)}${i.room != null ? ' · ${T(i.room!)}' : ''}',
          _next(i),
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents:
              (i.weekly && i.kind != Kind.due) ? DateTimeComponents.dayOfWeekAndTime : null,
        );
      }
    } catch (_) {}
  }

  static Future<void> test() async {
    if (!_ready) return;
    await _p.show(1, tr('name'), tr('testBody'), _details);
  }
}

// ───────────────────────── App & theme ─────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  await Notifier.init();
  Notifier.rescheduleAll(store.items);
  runApp(const JadwaliApp());
}

ThemeData _theme(Brightness b) {
  final dark = b == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: ColorScheme.fromSeed(seedColor: kAcc, brightness: b),
  );
  return base.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
    scaffoldBackgroundColor: dark ? const Color(0xFF0E1220) : const Color(0xFFF4F6FB),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF181E33) : Colors.white,
      indicatorColor: dark ? const Color(0xFF262E52) : const Color(0xFFE8EBFB),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black26,
    ),
  );
}

bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color cardColor(BuildContext c) => _dark(c) ? const Color(0xFF181E33) : Colors.white;
Color lineColor(BuildContext c) => _dark(c) ? const Color(0xFF343D5E) : const Color(0xFFC9D0E2);
Color mutColor(BuildContext c) => _dark(c) ? const Color(0xFFA7B0C8) : const Color(0xFF4A5368);

BoxDecoration cardDeco(BuildContext c, {double r = 16}) => BoxDecoration(
      color: cardColor(c),
      borderRadius: BorderRadius.circular(r),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(16), blurRadius: 14, offset: const Offset(0, 4))],
    );

class JadwaliApp extends StatelessWidget {
  const JadwaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: tr('name'),
        locale: Locale(store.lang),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: store.mode,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const SplashScreen(),
      ),
    );
  }
}

class LangButton extends StatelessWidget {
  const LangButton({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tr('lang'),
      icon: const Icon(Icons.language),
      style: light
          ? IconButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              fixedSize: const Size(44, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )
          : kIconStyle,
      onPressed: () => store.setLang(store.ar ? 'en' : 'ar'),
    );
  }
}

// ───────────────────────── Splash ─────────────────────────

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Widget _feature(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withAlpha(41), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Align(alignment: AlignmentDirectional.centerEnd, child: LangButton(light: true)),
            const SizedBox(height: 40),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
              child: const Icon(Icons.edit_calendar_rounded, size: 48, color: kDeep),
            ),
            const SizedBox(height: 24),
            Text(tr('name'), style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(tr('tag'), style: const TextStyle(color: Color(0xFFE3E6FF), fontSize: 18, height: 1.6)),
            const SizedBox(height: 36),
            _feature(Icons.calendar_month_outlined, tr('f1')),
            _feature(Icons.notifications_none, tr('f2')),
            _feature(Icons.check, tr('f3')),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final w in [24.0, 6.0, 6.0])
                Container(
                  width: w,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(w > 6 ? 255 : 100),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kDeep,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const Shell()),
                ),
                child: Text(tr('go')),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── Shell (tabs) ─────────────────────────

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [const TodayPage(), const WeekPage(), const AddPage(), const SettingsPage()];
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        body: SafeArea(child: pages[store.tab]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: store.tab,
          onDestinationSelected: store.goTab,
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr('tHome')),
            NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), selectedIcon: const Icon(Icons.calendar_month), label: tr('tSched')),
            NavigationDestination(icon: const Icon(Icons.add_circle_outline), selectedIcon: const Icon(Icons.add_circle), label: tr('tNew')),
            NavigationDestination(icon: const Icon(Icons.tune), selectedIcon: const Icon(Icons.tune), label: tr('tSet')),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Shared widgets ─────────────────────────

class ScreenHeader extends StatelessWidget {
  const ScreenHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        child: Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      );
}

/// Single-choice chips (day / type / reminder).
class Seg<T> extends StatelessWidget {
  const Seg({super.key, required this.items, required this.value, required this.onChanged, this.fontSize = 14});
  final Map<T, String> items;
  final T value;
  final ValueChanged<T> onChanged;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final e in items.entries)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Semantics(
              button: true,
              selected: e.key == value,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(e.key),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.key == value ? kAcc : cardColor(context),
                    border: Border.all(color: e.key == value ? kAcc : lineColor(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    e.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: e.key == value ? FontWeight.w700 : FontWeight.w400,
                      color: e.key == value ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

Map<int, String> dayChips() => {for (final d in store.weekOrder) d: dayName(d)};

class ItemCard extends StatelessWidget {
  const ItemCard(this.item, {super.key});
  final Item item;

  @override
  Widget build(BuildContext context) {
    final due = item.kind == Kind.due;
    final sub = [
      if (item.room != null) T(item.room!),
      rb(item.remind),
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      padding: const EdgeInsets.all(14),
      decoration: cardDeco(context),
      child: Row(children: [
        Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: kAcc.withAlpha(30), borderRadius: BorderRadius.circular(10)),
          child: Text(
            due ? '${dayName(item.day)}\n${fm(item.start)}' : '${fm(item.start)}\n${fm(item.end)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.5, color: due ? kWarn : kAcc),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(T(item.title), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 12, color: mutColor(context))),
          ]),
        ),
        IconButton.filledTonal(
          tooltip: tr(item.on ? 'off' : 'on'),
          style: kIconStyle,
          icon: Icon(item.on ? Icons.notifications_active : Icons.notifications_none),
          onPressed: () {
            store.toggle(item);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(tr(item.on ? 'on' : 'off')), duration: const Duration(seconds: 2)));
          },
        ),
      ]),
    );
  }
}

// ───────────────────────── Today ─────────────────────────

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = store.dayItems(store.tdx);
    final dues = store.dues();
    final nx = store.next();
    return ListView(padding: const EdgeInsets.only(bottom: 16), children: [
      ScreenHeader(dateStr(DateTime.now())),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kAcc,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: kAcc.withAlpha(72), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: nx == null
            ? Text(tr('nonext'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  tr('next') + (nx.minutes != null ? ' · ${nd(tr('inm').replaceAll('{n}', '${nx.minutes}'))}' : ''),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(T(nx.item.title), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${fm(nx.item.start)} – ${fm(nx.item.end)}${nx.item.room != null ? ' · ${T(nx.item.room!)}' : ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (nx.minutes != null) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (1 - nx.minutes! / 120).clamp(0.0, 1.0).toDouble(),
                      minHeight: 6,
                      backgroundColor: Colors.white.withAlpha(70),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ]),
      ),
      SectionTitle(tr('sch')),
      if (list.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(tr('none'), style: TextStyle(color: mutColor(context))),
        )
      else
        ...list.map(ItemCard.new),
      if (dues.isNotEmpty) ...[SectionTitle(tr('due')), ...dues.map(ItemCard.new)],
    ]);
  }
}

// ───────────────────────── Weekly (square tiles) ─────────────────────────

class WeekPage extends StatelessWidget {
  const WeekPage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = [
      ...store.dayItems(store.sel),
      ...store.dues().where((i) => i.day == store.sel),
    ];
    return ListView(padding: const EdgeInsets.only(bottom: 16), children: [
      ScreenHeader(tr('wk')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Seg<int>(items: dayChips(), value: store.sel, onChanged: store.selectDay, fontSize: 12),
      ),
      if (list.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Text(tr('none'), style: TextStyle(color: mutColor(context))),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final i in list) _Tile(i),
            _AddTile(),
          ],
        ),
      ),
    ]);
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item);
  final Item item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => Scaffold(body: SafeArea(child: AddPage(edit: item))),
      )),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kindColor(item.kind), borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(color: Colors.white.withAlpha(56), borderRadius: BorderRadius.circular(8)),
            child: Text(kindLabel(item.kind), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(T(item.title), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.4)),
          const SizedBox(height: 4),
          Text(
            item.kind == Kind.due ? fm(item.start) : '${fm(item.start)} – ${fm(item.end)}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (item.room != null) Text(T(item.room!), style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      ]),
    ));
  }
}

class _AddTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => store.goTab(2),
      child: _Dashed(
        color: lineColor(context),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_circle_outline, size: 32, color: kAcc),
          const SizedBox(height: 6),
          Text(tr('tNew'), style: const TextStyle(color: kAcc, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ───────────────────────── Settings ─────────────────────────

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _card(BuildContext c, String title, List<Widget> kids) => Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: cardDeco(c, r: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kAcc)),
          const SizedBox(height: 10),
          ...kids,
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final platformDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = store.mode == ThemeMode.dark || (store.mode == ThemeMode.system && platformDark);
    return ListView(padding: const EdgeInsets.only(bottom: 16), children: [
      ScreenHeader(tr('tSet')),
      _card(context, tr('theme'), [
        Seg<ThemeMode>(
          items: {ThemeMode.light: tr('light'), ThemeMode.dark: tr('darkT')},
          value: isDark ? ThemeMode.dark : ThemeMode.light,
          onChanged: store.setMode,
        ),
      ]),
      _card(context, tr('langT'), [
        Seg<String>(
          items: const {'ar': 'العربية', 'en': 'English'},
          value: store.lang,
          onChanged: store.setLang,
        ),
      ]),
      _card(context, tr('notif'), [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr('notifAll'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          value: store.notify,
          onChanged: store.setNotify,
        ),
        const SizedBox(height: 4),
        Text(tr('defRem'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutColor(context))),
        const SizedBox(height: 4),
        Seg<int>(
          items: {for (final m in [15, 30, 60]) m: nd(_rl[store.lang]![m]!)},
          value: store.defRemind,
          onChanged: store.setDefRemind,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: Notifier.test,
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(tr('testN')),
          ),
        ),
      ]),
      _card(context, tr('tSched'), [
        Text(tr('firstD'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutColor(context))),
        const SizedBox(height: 4),
        Seg<int>(
          items: {6: tr('sat'), 0: tr('sun')},
          value: store.firstDay,
          onChanged: store.setFirstDay,
        ),
        const SizedBox(height: 12),
        Text(tr('timeF'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutColor(context))),
        const SizedBox(height: 4),
        Seg<bool>(
          items: {false: tr('h12'), true: tr('h24')},
          value: store.h24,
          onChanged: store.setH24,
        ),
      ]),
      Center(child: Text('${tr('name')} · 1.0', style: TextStyle(color: mutColor(context)))),
    ]);
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DashedBorder(color), child: SizedBox.expand(child: child));
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)));
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}

// ───────────────────────── Add reminder ─────────────────────────

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.edit});
  final Item? edit; // when set, the page edits this reminder

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _ctrl = TextEditingController();
  Kind _kind = Kind.lecture;
  int _day = store.tdx;
  int _from = 540;
  int _to = 630;
  int _remind = store.defRemind;
  bool _weekly = true;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      _ctrl.text = T(e.title);
      _kind = e.kind;
      _day = e.day;
      _from = e.start;
      _to = e.end > e.start ? e.end : e.start + 60;
      _remind = e.remind;
      _weekly = e.weekly;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isFrom) async {
    final cur = isFrom ? _from : _to;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: cur ~/ 60, minute: cur % 60),
    );
    if (t == null) return;
    setState(() {
      if (isFrom) {
        _from = t.hour * 60 + t.minute;
      } else {
        _to = t.hour * 60 + t.minute;
      }
    });
  }

  void _save() {
    final messenger = ScaffoldMessenger.of(context);
    final title = _ctrl.text.trim();
    if (title.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(tr('req'))));
      return;
    }
    if (_kind != Kind.due && _to <= _from) {
      messenger.showSnackBar(SnackBar(content: Text(tr('terr'))));
      return;
    }
    final e = widget.edit;
    final item = Item(
      id: e?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: (e != null && title == T(e.title)) ? e.title : {'ar': title, 'en': title},
      room: e?.room,
      on: e?.on ?? true,
      kind: _kind,
      day: _day,
      start: _from,
      end: _kind == Kind.due ? _from : _to,
      remind: _remind,
      weekly: _weekly,
    );
    if (e != null) {
      store.update(item);
    } else {
      store.add(item);
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr('saved'))));
    store.sel = _day;
    if (e != null) {
      Navigator.of(context).pop();
    } else {
      store.goTab(1);
    }
  }

  void _delete() {
    final messenger = ScaffoldMessenger.of(context);
    store.remove(widget.edit!.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(tr('deleted'))));
    Navigator.of(context).pop();
  }

  Widget _section(String title, List<Widget> kids) => Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: cardDeco(context, r: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kAcc)),
          const SizedBox(height: 10),
          ...kids,
        ]),
      );

  Widget _field(String label, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutColor(context))),
          const SizedBox(height: 4),
          child,
        ]),
      );

  Widget _timeBox(int minutes, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            border: Border.all(color: lineColor(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(fm(minutes), style: const TextStyle(fontSize: 15)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.only(bottom: 16), children: [
      widget.edit == null
          ? ScreenHeader(tr('tNew'))
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 24, 12),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const BackButtonIcon(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                Text(tr('editT'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ]),
            ),
      _section(tr('details'), [
        _field(
          tr('course'),
          TextField(
            controller: _ctrl,
            maxLength: 40,
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        _field(
          tr('type'),
          Seg<Kind>(
            items: {for (final k in Kind.values) k: kindLabel(k)},
            value: _kind,
            onChanged: (k) => setState(() => _kind = k),
          ),
        ),
      ]),
      _section(tr('when'), [
        _field(tr('day'), Seg<int>(items: dayChips(), value: _day, onChanged: (d) => setState(() => _day = d), fontSize: 12)),
        Row(children: [
          Expanded(child: _field(tr('from'), _timeBox(_from, () => _pick(true)))),
          const SizedBox(width: 10),
          Expanded(child: _field(tr('to'), _timeBox(_to, () => _pick(false)))),
        ]),
      ]),
      _section(tr('alert'), [
        _field(
          tr('remMe'),
          Seg<int>(
            items: {for (final m in [15, 30, 60, 1440]) m: nd(_rl[store.lang]![m]!)},
            value: _remind,
            onChanged: (m) => setState(() => _remind = m),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr('repW'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          value: _weekly,
          onChanged: (v) => setState(() => _weekly = v),
        ),
      ]),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: kAcc.withAlpha(82), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: kAcc,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(tr(widget.edit == null ? 'save' : 'saveE')),
          ),
        ),
      ),
      if (widget.edit != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: kWarn,
                side: const BorderSide(color: kWarn, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(tr('del')),
            ),
          ),
        ),
    ]);
  }
}
