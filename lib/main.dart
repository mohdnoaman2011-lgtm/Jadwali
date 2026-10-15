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
    'skip': 'تخطي',
    'next': 'التالي',
    'back': 'رجوع',
    'ob1t': 'أسبوعك الجامعي في مكان واحد',
    'ob1d': 'أضف محاضراتك مرة واحدة ويتكرر جدولك كل أسبوع من السبت إلى الخميس.',
    'ob2t': 'تنبيه لا يفوتك',
    'ob2d': 'نغمة من هاتفك وتنبيه مستمر حتى تضغط إيقاف، حتى لا تفوتك محاضرة.',
    'ob3t': 'واجباتك واختباراتك تحت السيطرة',
    'ob3d': 'سجّل الواجبات والاختبارات ويذكّرك التطبيق قبل الموعد بالوقت الذي تختاره.',
    'getStarted': 'هيا نبدأ',
    'permT': 'اسمح بالتنبيهات',
    'permD': 'لكي يعمل التذكير بدقة حتى والتطبيق مغلق نحتاج هذه الأذونات.',
    'p1t': 'الإشعارات',
    'p1d': 'لإرسال تذكيرات المحاضرات والواجبات',
    'p2t': 'المنبّهات الدقيقة',
    'p2d': 'لتشغيل التنبيه في الدقيقة المحددة',
    'allow': 'السماح',
    'allowed': 'مسموح',
    'allowAll': 'السماح للكل',
    'later': 'لاحقًا',
    'home': 'اليوم',
    'schedule': 'الأسبوع',
    'reminders': 'التذكيرات',
    'settings': 'الإعدادات',
    'greet': 'صباح الخير',
    'todayTitle': 'اليوم',
    'nextLecture': 'المحاضرة القادمة',
    'details': 'التفاصيل',
    'alertOn': 'التنبيه مفعّل',
    'alertOff': 'التنبيه متوقف',
    'todayLec': 'محاضرات اليوم',
    'viewWeek': 'عرض الأسبوع',
    'lecCount': 'محاضرات اليوم',
    'remCount': 'تذكيرات معلّقة',
    'stDone': 'انتهت',
    'stNow': 'جارية',
    'stUp': 'قادمة',
    'allDone': 'أنهيت محاضرات اليوم',
    'allDoneD': 'استمتع ببقية يومك.',
    'noToday': 'لا محاضرات اليوم',
    'nextDue': 'أقرب موعد تسليم',
    'hall': 'قاعة',
    'emptyT': 'لا يوجد شيء هنا بعد',
    'emptyD': 'أضف أول محاضرة وسيذكّرك جدولي بها كل أسبوع.',
    'addFirst': 'إضافة أول محاضرة',
    'weekTitle': 'الجدول الأسبوعي',
    'addOnDay': 'إضافة محاضرة يوم',
    'noDay': 'لا محاضرات في هذا اليوم',
    'nowLbl': 'الآن',
    'remTitle': 'التذكيرات',
    'upcoming': 'القادمة',
    'completed': 'المكتملة',
    'fAll': 'الكل',
    'fAssign': 'الواجبات',
    'fExam': 'الاختبارات',
    'dueToday': 'يستحق اليوم',
    'noRem': 'لا توجد تذكيرات',
    'noRemD': 'ستظهر هنا الواجبات والاختبارات التي تضيفها.',
    'noneDone': 'لم تُكمل أي تذكير بعد',
    'markDone': 'تحديد كمكتمل',
    'markUndone': 'إعادة فتح التذكير',
    'today': 'اليوم',
    'tomorrow': 'غداً',
    'newT': 'إضافة جديدة',
    'editLecT': 'تعديل المحاضرة',
    'editRemT': 'تعديل التذكير',
    'lecture': 'محاضرة',
    'assignment': 'واجب',
    'exam': 'اختبار',
    'title': 'العنوان',
    'titleHint': 'مثال: تسليم التقرير',
    'subject': 'المادة',
    'pickSubject': 'اختر المادة',
    'addSubject': 'إضافة مادة جديدة',
    'room': 'القاعة',
    'roomHint': 'مثال: A12',
    'day': 'اليوم',
    'date': 'التاريخ',
    'time': 'الوقت',
    'startTime': 'البداية',
    'endTime': 'النهاية',
    'endAfter': 'وقت النهاية يجب أن يكون بعد البداية',
    'remindBefore': 'التذكير قبل',
    'soundRow': 'نغمة التنبيه',
    'save': 'حفظ',
    'saved': 'تم الحفظ',
    'deleted': 'تم الحذف',
    'required': 'مطلوب',
    'needTitle': 'اكتب عنوانًا أولًا',
    'delete': 'حذف',
    'edit': 'تعديل',
    'cancel': 'إلغاء',
    'keep': 'إبقاء',
    'yesDelete': 'نعم، احذف',
    'delLecQ': 'حذف هذه المحاضرة؟',
    'delRemQ': 'حذف هذا التذكير؟',
    'delD': 'لا يمكن التراجع عن هذا الإجراء.',
    'openDetails': 'فتح التفاصيل',
    'when': 'الموعد',
    'repeat': 'التكرار',
    'weekly': 'كل أسبوع',
    'type': 'النوع',
    'due': 'موعد التسليم',
    'alertEnabled': 'التنبيه مفعّل',
    'soundTitle': 'نغمة التنبيه',
    'phoneDefault': 'نغمة الهاتف الافتراضية',
    'phoneDefaultSub': 'تستخدم النغمة المحددة في إعدادات هاتفك',
    'pickFromPhone': 'اختيار نغمة من الهاتف',
    'pickFromPhoneSub': 'من نغمات جهازك',
    'chooseTone': 'استعراض',
    'continuous': 'تنبيه مستمر',
    'continuousSub': 'يتكرر الرنين حتى تضغط إيقاف',
    'repeatFor': 'مدة التكرار',
    'untilStop': 'حتى الإيقاف',
    'min1': 'دقيقة',
    'min5': '5 دقائق',
    'min10': '10 دقائق',
    'vibrate': 'الاهتزاز',
    'preview': 'تجربة التنبيه',
    'appearance': 'المظهر',
    'light': 'فاتح',
    'dark': 'داكن',
    'system': 'النظام',
    'language': 'اللغة',
    'timeFormat': 'نظام الوقت',
    'h12': '12 ساعة',
    'h24': '24 ساعة',
    'alerts': 'التنبيهات',
    'defBefore': 'التذكير الافتراضي قبل المحاضرة',
    'data': 'البيانات',
    'subjects': 'المواد الدراسية',
    'clearAll': 'مسح كل البيانات',
    'clearQ': 'مسح كل المحاضرات والتذكيرات؟',
    'clearD': 'ستبقى المواد والإعدادات كما هي.',
    'yesClear': 'نعم، امسح الكل',
    'cleared': 'تم مسح البيانات',
    'about': 'حول التطبيق',
    'version': 'الإصدار 1.0',
    'subjNew': 'اسم مادة جديدة',
    'subjAdd': 'إضافة',
    'subjUsed': 'لا يمكن حذف مادة لها محاضرات',
    'lecN': 'محاضرة',
    'alarmBadge': 'جدولي',
    'alarmIn': 'تبدأ المحاضرة قريبًا',
    'stop': 'إيقاف',
    'snooze': 'غفوة 5 دقائق',
    'previewBody': 'هذه معاينة لنغمة التنبيه',
    'min': 'د',
  },
  'en': {
    'app': 'Jadwali',
    'tagline': 'Your university schedule, with reminders for lectures, assignments and exams in one place',
    'start': 'Get started',
    'skip': 'Skip',
    'next': 'Next',
    'back': 'Back',
    'ob1t': 'Your whole week in one place',
    'ob1d': 'Add your lectures once and your timetable repeats every week, Saturday to Thursday.',
    'ob2t': 'Alerts you will not miss',
    'ob2d': 'Pick a tone from your phone and let it ring until you press stop, so no lecture slips by.',
    'ob3t': 'Assignments and exams under control',
    'ob3d': 'Log assignments and exams and get reminded ahead of time, as early as you choose.',
    'getStarted': "Let's go",
    'permT': 'Allow alerts',
    'permD': 'To remind you on time, even when the app is closed, Jadwali needs these permissions.',
    'p1t': 'Notifications',
    'p1d': 'To send lecture and assignment reminders',
    'p2t': 'Exact alarms',
    'p2d': 'To ring at the exact minute you set',
    'allow': 'Allow',
    'allowed': 'Allowed',
    'allowAll': 'Allow all',
    'later': 'Later',
    'home': 'Today',
    'schedule': 'Week',
    'reminders': 'Reminders',
    'settings': 'Settings',
    'greet': 'Good morning',
    'todayTitle': 'Today',
    'nextLecture': 'Next lecture',
    'details': 'Details',
    'alertOn': 'Alert on',
    'alertOff': 'Alert off',
    'todayLec': "Today's lectures",
    'viewWeek': 'View week',
    'lecCount': 'Lectures today',
    'remCount': 'Pending reminders',
    'stDone': 'Finished',
    'stNow': 'Now',
    'stUp': 'Upcoming',
    'allDone': "You're done for today",
    'allDoneD': 'Enjoy the rest of your day.',
    'noToday': 'No lectures today',
    'nextDue': 'Next due',
    'hall': 'Hall',
    'emptyT': 'Nothing here yet',
    'emptyD': 'Add your first lecture and Jadwali will remind you every week.',
    'addFirst': 'Add first lecture',
    'weekTitle': 'Weekly schedule',
    'addOnDay': 'Add lecture on',
    'noDay': 'No lectures on this day',
    'nowLbl': 'Now',
    'remTitle': 'Reminders',
    'upcoming': 'Upcoming',
    'completed': 'Completed',
    'fAll': 'All',
    'fAssign': 'Assignments',
    'fExam': 'Exams',
    'dueToday': 'Due today',
    'noRem': 'No reminders',
    'noRemD': 'Assignments and exams you add will show up here.',
    'noneDone': 'Nothing completed yet',
    'markDone': 'Mark as done',
    'markUndone': 'Reopen reminder',
    'today': 'Today',
    'tomorrow': 'Tomorrow',
    'newT': 'New',
    'editLecT': 'Edit lecture',
    'editRemT': 'Edit reminder',
    'lecture': 'Lecture',
    'assignment': 'Assignment',
    'exam': 'Exam',
    'title': 'Title',
    'titleHint': 'e.g. Report due',
    'subject': 'Subject',
    'pickSubject': 'Choose subject',
    'addSubject': 'Add new subject',
    'room': 'Hall',
    'roomHint': 'e.g. A12',
    'day': 'Day',
    'date': 'Date',
    'time': 'Time',
    'startTime': 'Starts',
    'endTime': 'Ends',
    'endAfter': 'End time must be after the start',
    'remindBefore': 'Remind me before',
    'soundRow': 'Alert sound',
    'save': 'Save',
    'saved': 'Saved',
    'deleted': 'Deleted',
    'required': 'Required',
    'needTitle': 'Enter a title first',
    'delete': 'Delete',
    'edit': 'Edit',
    'cancel': 'Cancel',
    'keep': 'Keep',
    'yesDelete': 'Yes, delete',
    'delLecQ': 'Delete this lecture?',
    'delRemQ': 'Delete this reminder?',
    'delD': 'This cannot be undone.',
    'openDetails': 'Open details',
    'when': 'When',
    'repeat': 'Repeats',
    'weekly': 'Every week',
    'type': 'Type',
    'due': 'Due',
    'alertEnabled': 'Alert enabled',
    'soundTitle': 'Alert sound',
    'phoneDefault': 'Phone default ringtone',
    'phoneDefaultSub': 'Uses the ringtone set in your phone settings',
    'pickFromPhone': 'Choose a tone from phone',
    'pickFromPhoneSub': 'From your device tones',
    'chooseTone': 'Browse',
    'continuous': 'Continuous alert',
    'continuousSub': 'Keeps ringing until you press stop',
    'repeatFor': 'Repeat for',
    'untilStop': 'Until stopped',
    'min1': '1 min',
    'min5': '5 min',
    'min10': '10 min',
    'vibrate': 'Vibration',
    'preview': 'Test alert',
    'appearance': 'Appearance',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'language': 'Language',
    'timeFormat': 'Time format',
    'h12': '12-hour',
    'h24': '24-hour',
    'alerts': 'Alerts',
    'defBefore': 'Default reminder before lecture',
    'data': 'Data',
    'subjects': 'Subjects',
    'clearAll': 'Clear all data',
    'clearQ': 'Clear all lectures and reminders?',
    'clearD': 'Subjects and settings stay as they are.',
    'yesClear': 'Yes, clear all',
    'cleared': 'Data cleared',
    'about': 'About',
    'version': 'Version 1.0',
    'subjNew': 'New subject name',
    'subjAdd': 'Add',
    'subjUsed': 'Cannot delete a subject that has lectures',
    'lecN': 'lectures',
    'alarmBadge': 'Jadwali',
    'alarmIn': 'Your lecture starts soon',
    'stop': 'Stop',
    'snooze': 'Snooze 5 min',
    'previewBody': 'This is a preview of your alert sound',
    'min': 'min',
  },
};

const _daysAr = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const _daysEn = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _monthsAr = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const _monthsEn = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

// أيام الأسبوع الدراسي: السبت إلى الخميس (DateTime.weekday: الإثنين=1 ... الأحد=7)
const List<int> kWeekdays = [6, 7, 1, 2, 3, 4];

const List<Color> kSubjectColors = [
  Color(0xFF2F6BFF),
  Color(0xFF17A673),
  Color(0xFFF08A24),
  Color(0xFF8B5CF6),
  Color(0xFFE0457B),
  Color(0xFF0EA5B7),
  Color(0xFFC99A12),
];

// ───────────────────────── النماذج / Models ─────────────────────────

class Subject {
  Subject({required this.name, required this.color});
  String name;
  int color; // فهرس في kSubjectColors

  Map<String, dynamic> toJson() => {'name': name, 'color': color};
  factory Subject.fromJson(Map<String, dynamic> j) => Subject(name: j['name'] as String, color: (j['color'] ?? 0) as int);
}

class Lecture {
  Lecture({
    required this.id,
    required this.subject,
    required this.weekday,
    required this.start,
    required this.end,
    this.room = '',
    this.before = 10,
    this.on = true,
  });

  int id;
  String subject;
  int weekday; // 1..7
  int start; // دقائق من منتصف الليل
  int end;
  String room;
  int before; // دقائق
  bool on;

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'weekday': weekday,
        'start': start,
        'end': end,
        'room': room,
        'before': before,
        'on': on,
      };

  factory Lecture.fromJson(Map<String, dynamic> j) => Lecture(
        id: j['id'] as int,
        subject: j['subject'] as String,
        weekday: j['weekday'] as int,
        start: j['start'] as int,
        end: j['end'] as int,
        room: (j['room'] ?? '') as String,
        before: (j['before'] ?? 10) as int,
        on: (j['on'] ?? true) as bool,
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
  int defBefore = 10;

  String soundMode = 'default'; // default | custom
  String toneUri = '';
  String toneTitle = '';
  bool continuous = true;
  int repeatMin = 0; // 0 = حتى أوقفه
  bool vibrate = true;

  List<Subject> subjects = [];
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
    defBefore = _p.getInt('defBefore') ?? 10;
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
      if (j['subjects'] != null) {
        subjects = (j['subjects'] as List).map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
      }
      _nextId = (j['nextId'] ?? 1) as int;
    }
    // مواد المحاضرات القديمة التي لا توجد في القائمة
    for (final l in lectures) {
      if (l.subject.isNotEmpty && !subjects.any((s) => s.name == l.subject)) {
        subjects.add(Subject(name: l.subject, color: subjects.length % kSubjectColors.length));
      }
    }
  }

  Future<void> save() async {
    await _p.setBool('onboarded', onboarded);
    await _p.setString('lang', lang);
    await _p.setString('theme', themeMode.name);
    await _p.setBool('use24', use24);
    await _p.setInt('defBefore', defBefore);
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
        'subjects': subjects.map((e) => e.toJson()).toList(),
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

  Color colorOf(String subject) {
    for (final s in subjects) {
      if (s.name == subject) return kSubjectColors[s.color % kSubjectColors.length];
    }
    return const Color(0xFF8A94AD);
  }

  String fmtMin(int m) {
    final h = (m ~/ 60) % 24;
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

  String shortDate(DateTime d) {
    final month = ar ? _monthsAr[d.month] : _monthsEn[d.month];
    return ar ? '${d.day} $month' : '$month ${d.day}';
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

  String minLabel(int m) {
    if (m % 1440 == 0) {
      final d = m ~/ 1440;
      if (ar) return d == 1 ? 'يوم' : (d == 2 ? 'يومان' : '$d أيام');
      return d == 1 ? '1 day' : '$d days';
    }
    if (m % 60 == 0) {
      final h = m ~/ 60;
      if (ar) return h == 1 ? 'ساعة' : (h == 2 ? 'ساعتان' : '$h ساعات');
      return '$h h';
    }
    if (ar) return m <= 10 ? '$m دقائق' : '$m دقيقة';
    return '$m min';
  }

  String inText(Duration d) {
    final m = d.inMinutes;
    if (m < 1) return ar ? 'الآن' : 'now';
    if (m < 60) return ar ? 'بعد ${minLabel(m)}' : 'in $m min';
    if (m < 1440) {
      final h = m ~/ 60;
      final r = m % 60;
      if (ar) return 'بعد ${minLabel(h * 60)}${r > 0 ? ' و${minLabel(r)}' : ''}';
      return 'in $h h${r > 0 ? ' $r min' : ''}';
    }
    final days = m ~/ 1440;
    return ar ? 'بعد ${minLabel(days * 1440)}' : 'in $days d';
  }

  String get toneName => soundMode == 'default' || toneTitle.isEmpty ? t('phoneDefault') : toneTitle;
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

/// تاريخ يوم الدراسة داخل الأسبوع الحالي (يبدأ السبت).
DateTime weekDate(int weekday) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final sinceSat = (now.weekday - 6) % 7;
  final sat = today.subtract(Duration(days: sinceSat));
  final idx = kWeekdays.indexOf(weekday);
  return DateTime(sat.year, sat.month, sat.day + (idx < 0 ? 0 : idx));
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

  final launch = await plugin.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp ?? false) {
    final payload = launch!.notificationResponse?.payload;
    WidgetsBinding.instance.addPostFrameCallback((_) => openAlarm(payload));
  }
}

AndroidFlutterLocalNotificationsPlugin? get _android =>
    plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

Future<bool> askNotificationsPermission() async {
  try {
    return (await _android?.requestNotificationsPermission()) ?? false;
  } catch (_) {
    return false;
  }
}

Future<bool> askExactAlarmsPermission() async {
  try {
    return (await _android?.requestExactAlarmsPermission()) ?? false;
  } catch (_) {
    return false;
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
  final kindLbl = a.t(r.kind == 'exam' ? 'exam' : 'assignment');
  final body = r.subject.isEmpty ? kindLbl : '${r.subject} · $kindLbl';
  await _schedule(r.id, r.title, body, at, a);
}

Future<void> scheduleLecture(AppState a, Lecture l) async {
  await plugin.cancel(l.id);
  if (!l.on) return;
  final now = DateTime.now();
  var start = nextOccurrence(l.weekday, l.start, now);
  var at = start.subtract(Duration(minutes: l.before));
  while (at.isBefore(now)) {
    start = DateTime(start.year, start.month, start.day + 7, l.start ~/ 60, l.start % 60);
    at = start.subtract(Duration(minutes: l.before));
  }
  final body = l.room.isEmpty ? a.fmtMin(l.start) : '${a.fmtMin(l.start)} · ${a.t('hall')} ${l.room}';
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

/// ألوان التصميم (مطابقة للمخطط) حسب السمة الحالية.
class Pal {
  const Pal({
    required this.bg,
    required this.card,
    required this.text,
    required this.muted,
    required this.line,
    required this.soft,
    required this.pri,
    required this.onPri,
    required this.grn,
    required this.grnSoft,
    required this.red,
    required this.redSoft,
    required this.amber,
    required this.amberText,
    required this.sw,
  });

  final Color bg, card, text, muted, line, soft, pri, onPri, grn, grnSoft, red, redSoft, amber, amberText, sw;

  static const light = Pal(
    bg: Color(0xFFF3F5FB),
    card: Color(0xFFFFFFFF),
    text: Color(0xFF0E1A3D),
    muted: Color(0xFF55627F),
    line: Color(0xFFE2E7F1),
    soft: Color(0xFFEAEEF8),
    pri: Color(0xFF0F2A6B),
    onPri: Color(0xFFFFFFFF),
    grn: Color(0xFF12805C),
    grnSoft: Color(0xFFDDF3EA),
    red: Color(0xFFC62F3E),
    redSoft: Color(0xFFFBE4E7),
    amber: Color(0xFFFFF1D6),
    amberText: Color(0xFF6B4300),
    sw: Color(0xFFC3CCE0),
  );

  static const dark = Pal(
    bg: Color(0xFF080D1E),
    card: Color(0xFF121A33),
    text: Color(0xFFEEF2FF),
    muted: Color(0xFF9DA9CB),
    line: Color(0xFF222D50),
    soft: Color(0xFF1A2444),
    pri: Color(0xFF7EA3FF),
    onPri: Color(0xFF08133A),
    grn: Color(0xFF34D399),
    grnSoft: Color(0xFF103A2E),
    red: Color(0xFFFF8A94),
    redSoft: Color(0xFF3C1A22),
    amber: Color(0xFF3A2E12),
    amberText: Color(0xFFFFD98A),
    sw: Color(0xFF34406A),
  );

  static Pal of(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? dark : light;
}

ThemeData _theme(Brightness b) {
  final p = b == Brightness.dark ? Pal.dark : Pal.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5BD8), brightness: b).copyWith(
      primary: p.pri,
      onPrimary: p.onPri,
      surface: p.bg,
      onSurface: p.text,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme).apply(bodyColor: p.text, displayColor: p.text),
    appBarTheme: AppBarTheme(backgroundColor: p.bg, foregroundColor: p.text, elevation: 0, scrolledUnderElevation: 0),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.grn : p.sw),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
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

// ───────────────────────── عناصر واجهة مشتركة ─────────────────────────

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Material(
      color: color ?? p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: p.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  const PillChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Material(
      color: selected ? p.pri : p.card,
      shape: StadiumBorder(side: BorderSide(color: selected ? p.pri : p.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(fontSize: 13.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? p.onPri : p.text),
          ),
        ),
      ),
    );
  }
}

class Seg<T> extends StatelessWidget {
  const Seg({super.key, required this.items, required this.value, required this.onChanged});
  final Map<T, String> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          for (final e in items.entries)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.key == value ? p.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: e.key == value ? [const BoxShadow(color: Color(0x290F1B3D), blurRadius: 4, offset: Offset(0, 1))] : null,
                  ),
                  child: Text(e.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: e.key == value ? p.text : p.muted)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum BtnKind { primary, soft, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onTap, this.icon, this.kind = BtnKind.primary, this.height = 54});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final BtnKind kind;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    Color bg;
    Color fg;
    switch (kind) {
      case BtnKind.primary:
        bg = p.pri;
        fg = p.onPri;
        break;
      case BtnKind.soft:
        bg = p.soft;
        fg = p.text;
        break;
      case BtnKind.danger:
        bg = p.redSoft;
        fg = p.red;
        break;
      case BtnKind.ghost:
        bg = Colors.transparent;
        fg = p.muted;
        break;
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
              Flexible(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg))),
            ],
          ),
        ),
      ),
    );
  }
}

class IconBox extends StatelessWidget {
  const IconBox({super.key, required this.icon, this.bg, this.fg, this.size = 40});
  final IconData icon;
  final Color? bg;
  final Color? fg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg ?? p.soft, borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, size: 22, color: fg ?? p.pri),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, required this.tooltip, this.color, this.badge});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: p.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 22, color: color ?? p.text)),
            ),
          ),
          if (badge != null && badge! > 0)
            PositionedDirectional(
              top: -4,
              end: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(color: p.red, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.actions = const []});
  final IconData icon;
  final String title;
  final String? body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(32)),
            child: Icon(icon, size: 44, color: p.pri),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (body != null && body!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(body!, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.7, color: p.muted)),
          ],
          for (final w in actions) ...[const SizedBox(height: 12), w],
        ],
      ),
    );
  }
}

void showToast(BuildContext context, String msg) {
  final p = Pal.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: p.bg, fontWeight: FontWeight.w600)),
      backgroundColor: p.text,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(milliseconds: 2000),
    ));
}

Future<T?> showAppSheet<T>(BuildContext context, Widget Function(BuildContext) builder) {
  final p = Pal.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (c) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: p.sw, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 14),
            builder(c),
          ],
        ),
      ),
    ),
  );
}

Future<bool> confirmSheet(BuildContext context, {required String title, required String sub, required String yes, required String no}) async {
  final p = Pal.of(context);
  final res = await showAppSheet<bool>(
    context,
    (c) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: IconBox(icon: Icons.delete_outline, bg: p.redSoft, fg: p.red, size: 60)),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(sub, textAlign: TextAlign.center, style: TextStyle(color: p.muted)),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(yes, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        AppButton(label: no, kind: BtnKind.soft, onTap: () => Navigator.of(c).pop(false)),
      ],
    ),
  );
  return res ?? false;
}

Future<void> deleteLecture(BuildContext context, Lecture l) async {
  final a = AppScope.of(context);
  final ok = await confirmSheet(context, title: a.t('delLecQ'), sub: '${l.subject} · ${a.t('delD')}', yes: a.t('yesDelete'), no: a.t('keep'));
  if (!ok) return;
  await plugin.cancel(l.id);
  await a.update(() => a.lectures.removeWhere((x) => x.id == l.id));
  if (context.mounted) showToast(context, a.t('deleted'));
}

Future<void> deleteReminder(BuildContext context, Reminder r) async {
  final a = AppScope.of(context);
  final ok = await confirmSheet(context, title: a.t('delRemQ'), sub: '${r.title} · ${a.t('delD')}', yes: a.t('yesDelete'), no: a.t('keep'));
  if (!ok) return;
  await plugin.cancel(r.id);
  await a.update(() => a.reminders.removeWhere((x) => x.id == r.id));
  if (context.mounted) showToast(context, a.t('deleted'));
}

/// قائمة خيارات (فتح / تعديل / حذف) لمحاضرة أو تذكير.
Future<void> showItemActions(
  BuildContext context, {
  required String title,
  required String sub,
  required Color color,
  required VoidCallback onOpen,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final a = AppScope.of(context);
  final p = Pal.of(context);
  return showAppSheet<void>(
    context,
    (c) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(sub, style: TextStyle(color: p.muted, fontSize: 13.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppButton(label: a.t('openDetails'), icon: Icons.info_outline, kind: BtnKind.soft, onTap: () {
          Navigator.of(c).pop();
          onOpen();
        }),
        const SizedBox(height: 10),
        AppButton(label: a.t('edit'), icon: Icons.edit_outlined, kind: BtnKind.soft, onTap: () {
          Navigator.of(c).pop();
          onEdit();
        }),
        const SizedBox(height: 10),
        AppButton(label: a.t('delete'), icon: Icons.delete_outline, kind: BtnKind.danger, onTap: () {
          Navigator.of(c).pop();
          onDelete();
        }),
      ],
    ),
  );
}

void openLectureDetail(BuildContext context, Lecture l) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailPage(lectureId: l.id)));
void openReminderDetail(BuildContext context, Reminder r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailPage(reminderId: r.id)));
void openEditLecture(BuildContext context, Lecture l) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddPage(editLecture: l)));
void openEditReminder(BuildContext context, Reminder r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddPage(editReminder: r)));

void lectureActions(BuildContext context, Lecture l) {
  final a = AppScope.of(context);
  showItemActions(
    context,
    title: l.subject,
    sub: '${a.dayName(l.weekday)} · ${a.fmtMin(l.start)} – ${a.fmtMin(l.end)}',
    color: a.colorOf(l.subject),
    onOpen: () => openLectureDetail(context, l),
    onEdit: () => openEditLecture(context, l),
    onDelete: () => deleteLecture(context, l),
  );
}

void reminderActions(BuildContext context, Reminder r) {
  final a = AppScope.of(context);
  showItemActions(
    context,
    title: r.title,
    sub: '${r.subject} · ${a.dayLabel(r.when)} ${a.fmtDateTime(r.when)}',
    color: a.colorOf(r.subject),
    onOpen: () => openReminderDetail(context, r),
    onEdit: () => openEditReminder(context, r),
    onDelete: () => deleteReminder(context, r),
  );
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
                    Image.asset(
                      'assets/logo.png',
                      width: 250,
                      semanticLabel: a.t('app'),
                      errorBuilder: (context, error, stack) => Text(
                        a.t('app'),
                        style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: _navy),
                      ),
                    ),
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
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const OnboardingPage())),
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

// ───────────────────────── التعريف بالتطبيق ─────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int i = 0;

  void _goPerm() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PermissionPage()));

  Widget _illus(int k, AppState a) {
    const rows = [Color(0xFF2F6BFF), Color(0xFF17A673), Color(0xFFF08A24), Color(0xFF8B5CF6)];
    if (k == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final c in rows)
            Container(
              width: 230,
              height: 52,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFD5DBEA), borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(width: 10),
                  Container(width: 34, height: 8, decoration: BoxDecoration(color: const Color(0xFFB9C3DD), borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
        ],
      );
    }
    if (k == 1) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: const Icon(Icons.notifications_active_outlined, size: 64, color: Color(0xFF0F2A6B)),
      );
    }
    return SizedBox(
      width: 290,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var n = 0; n < kWeekdays.length; n++)
            Container(
              width: 90,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: n == 2 ? Colors.white : Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                a.shortDay(kWeekdays[n]),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: n == 2 ? const Color(0xFF0F2A6B) : Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final titles = [a.t('ob1t'), a.t('ob2t'), a.t('ob3t')];
    final descs = [a.t('ob1d'), a.t('ob2d'), a.t('ob3d')];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Align(alignment: AlignmentDirectional.centerEnd, child: PillChip(label: a.t('skip'), selected: false, onTap: _goPerm)),
              const SizedBox(height: 12),
              Container(
                height: 300,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF0F2A6B), Color(0xFF1E5BD8), Color(0xFF17A673)], stops: [0, 0.6, 1]),
                ),
                child: _illus(i, a),
              ),
              const SizedBox(height: 26),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(titles[i], style: const TextStyle(fontSize: 26, height: 1.3, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(descs[i], style: TextStyle(fontSize: 15.5, height: 1.7, color: p.muted)),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var n = 0; n < 3; n++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: n == i ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: n == i ? p.pri : p.sw, borderRadius: BorderRadius.circular(4)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              AppButton(label: i == 2 ? a.t('getStarted') : a.t('next'), onTap: () => i == 2 ? _goPerm() : setState(() => i++)),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── الأذونات ─────────────────────────

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool notif = false;
  bool exact = false;

  Future<void> _finish() async {
    final a = AppScope.of(context);
    final nav = Navigator.of(context);
    await a.update(() => a.onboarded = true);
    nav.popUntil((r) => r.isFirst);
  }

  Future<void> _allowAll() async {
    final n = await askNotificationsPermission();
    final e = await askExactAlarmsPermission();
    if (mounted) setState(() {
      notif = n;
      exact = e;
    });
    await _finish();
  }

  Widget _row(AppState a, Pal p, IconData icon, String t, String d, bool on, VoidCallback onTap) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconBox(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(d, style: TextStyle(fontSize: 13.5, color: p.muted)),
              ],
            ),
          ),
          PillChip(label: on ? a.t('allowed') : a.t('allow'), selected: on, onTap: onTap),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(colors: [Color(0xFF1E5BD8), Color(0xFF0F2A6B)]),
                ),
                child: const Icon(Icons.notifications_active_outlined, size: 42, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(a.t('permT'), style: const TextStyle(fontSize: 28, height: 1.25, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(a.t('permD'), style: TextStyle(height: 1.7, color: p.muted)),
              const SizedBox(height: 20),
              _row(a, p, Icons.notifications_outlined, a.t('p1t'), a.t('p1d'), notif, () async {
                final ok = await askNotificationsPermission();
                if (mounted) setState(() => notif = ok);
              }),
              const SizedBox(height: 10),
              _row(a, p, Icons.alarm, a.t('p2t'), a.t('p2d'), exact, () async {
                final ok = await askExactAlarmsPermission();
                if (mounted) setState(() => exact = ok);
              }),
              const Spacer(),
              AppButton(label: a.t('allowAll'), onTap: _allowAll),
              const SizedBox(height: 8),
              AppButton(label: a.t('later'), kind: BtnKind.ghost, onTap: _finish),
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

  void _add() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddPage()));

  Widget _item(AppState a, Pal p, int i, IconData icon, IconData iconOn, String label) {
    final on = index == i;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => index = i),
      child: Container(
        width: 62,
        height: 56,
        decoration: BoxDecoration(color: on ? p.soft : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(on ? iconOn : icon, size: 22, color: on ? p.pri : p.muted),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? p.pri : p.muted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final pages = <Widget>[
      HomePage(onOpenWeek: () => setState(() => index = 1), onOpenReminders: () => setState(() => index = 2)),
      const WeekPage(),
      const RemindersPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[index]),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72,
          margin: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: p.line),
            boxShadow: const [BoxShadow(color: Color(0x240F2A6B), blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(a, p, 0, Icons.calendar_today_outlined, Icons.calendar_today, a.t('home')),
              _item(a, p, 1, Icons.grid_view_outlined, Icons.grid_view_rounded, a.t('schedule')),
              Tooltip(
                message: a.t('newT'),
                child: GestureDetector(
                  onTap: _add,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1E5BD8), Color(0xFF0F2A6B)]),
                      boxShadow: const [BoxShadow(color: Color(0x731E5BD8), blurRadius: 18, offset: Offset(0, 8))],
                    ),
                    child: const Icon(Icons.add, size: 28, color: Colors.white),
                  ),
                ),
              ),
              _item(a, p, 2, Icons.check_circle_outline, Icons.check_circle, a.t('reminders')),
              _item(a, p, 3, Icons.tune, Icons.tune, a.t('settings')),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── رأس الصفحة ─────────────────────────

class PageTop extends StatelessWidget {
  const PageTop({super.key, required this.title, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 13.5, color: p.muted)),
                Text(title, style: const TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SubjectDot extends StatelessWidget {
  const SubjectDot({super.key, required this.color, this.size = 12});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

// ───────────────────────── الرئيسية (اليوم) ─────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenWeek, required this.onOpenReminders});
  final VoidCallback onOpenWeek;
  final VoidCallback onOpenReminders;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    final today = a.lectures.where((l) => l.weekday == now.weekday).toList()..sort((x, y) => x.start.compareTo(y.start));
    final pending = a.reminders.where((r) => !r.done).toList()..sort((x, y) => x.when.compareTo(y.when));

    Lecture? next;
    DateTime? nextAt;
    for (final l in a.lectures) {
      final at = nextOccurrence(l.weekday, l.start, now);
      if (nextAt == null || at.isBefore(nextAt)) {
        next = l;
        nextAt = at;
      }
    }

    final children = <Widget>[];

    if (a.lectures.isEmpty) {
      children.add(EmptyState(
        icon: Icons.calendar_today_outlined,
        title: a.t('emptyT'),
        body: a.t('emptyD'),
        actions: [AppButton(label: a.t('addFirst'), icon: Icons.add, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddPage())))],
      ));
    } else {
      if (next != null && nextAt != null) {
        final nl = next;
        children.add(Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1E5BD8), Color(0xFF0F2A6B)]),
            boxShadow: const [BoxShadow(color: Color(0x401E5BD8), blurRadius: 24, offset: Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _whitePill(a.t('nextLecture')),
                  _whitePill(a.inText(nextAt.difference(now))),
                ],
              ),
              const SizedBox(height: 16),
              Text(nl.subject, style: const TextStyle(fontSize: 27, height: 1.25, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 18,
                runSpacing: 6,
                children: [
                  _heroInfo(Icons.schedule, '${a.fmtMin(nl.start)} – ${a.fmtMin(nl.end)}'),
                  if (nl.room.isNotEmpty) _heroInfo(Icons.place_outlined, '${a.t('hall')} ${nl.room}'),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _heroBtn(a.t('details'), null, false, () => openLectureDetail(context, nl))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroBtn(nl.on ? a.t('alertOn') : a.t('alertOff'), nl.on ? Icons.notifications_active_outlined : Icons.notifications_off_outlined, true, () async {
                      await a.update(() => nl.on = !nl.on);
                      await scheduleLecture(a, nl);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ));
        children.add(const SizedBox(height: 16));
      }

      children.add(Row(
        children: [
          Expanded(child: _tile(p, a.t('lecCount'), '${today.length}', onOpenWeek)),
          const SizedBox(width: 12),
          Expanded(child: _tile(p, a.t('remCount'), '${pending.length}', onOpenReminders)),
        ],
      ));
      children.add(const SizedBox(height: 16));

      if (today.isEmpty) {
        children.add(AppCard(child: Center(child: Text(a.t('noToday'), style: TextStyle(color: p.muted)))));
      } else {
        if (next == null || nextAt == null || !today.any((l) => l.start > nowMin)) {
          children.add(AppCard(
            child: Row(
              children: [
                IconBox(icon: Icons.check, bg: p.grnSoft, fg: p.grn),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.t('allDone'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(a.t('allDoneD'), style: TextStyle(fontSize: 13.5, color: p.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ));
          children.add(const SizedBox(height: 16));
        }
        children.add(Row(
          children: [
            Expanded(child: Text(a.t('todayLec'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            PillChip(label: a.t('viewWeek'), selected: false, onTap: onOpenWeek),
          ],
        ));
        children.add(const SizedBox(height: 10));
        for (final l in today) {
          children.add(Padding(padding: const EdgeInsets.only(bottom: 10), child: LectureRow(lecture: l, nowMin: nowMin)));
        }
      }

      if (pending.isNotEmpty) {
        final r = pending.first;
        children.add(const SizedBox(height: 6));
        children.add(Material(
          color: p.amber,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => openReminderDetail(context, r),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.assignment_outlined, color: p.amberText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.t('nextDue'), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.amberText)),
                        Text(r.title, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: p.amberText)),
                        Text('${r.subject} · ${a.dayLabel(r.when)} ${a.fmtDateTime(r.when)}', style: TextStyle(fontSize: 13, color: p.amberText)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: p.amberText),
                ],
              ),
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTop(
          subtitle: '${a.t('greet')} · ${a.longDate(now)}',
          title: a.t('todayTitle'),
          trailing: RoundIconButton(icon: Icons.notifications_outlined, tooltip: a.t('reminders'), badge: pending.length, onTap: onOpenReminders),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _whitePill(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
        child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _heroInfo(IconData i, String s) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 17, color: Colors.white),
          const SizedBox(width: 6),
          Text(s, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
        ],
      );

  Widget _heroBtn(String label, IconData? icon, bool ghost, VoidCallback onTap) => Material(
        color: ghost ? Colors.white.withValues(alpha: 0.16) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
                Flexible(
                  child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: ghost ? Colors.white : const Color(0xFF0F2A6B))),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _tile(Pal p, String label, String value, VoidCallback onTap) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          height: 64,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 13.5, color: p.muted)),
              Text(value, style: const TextStyle(fontSize: 26, height: 1.1, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}

class LectureRow extends StatelessWidget {
  const LectureRow({super.key, required this.lecture, required this.nowMin});
  final Lecture lecture;
  final int nowMin;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final l = lecture;
    final state = l.end <= nowMin ? 0 : (l.start <= nowMin ? 1 : 2);
    final stLabel = [a.t('stDone'), a.t('stNow'), a.t('stUp')][state];
    final stBg = [p.soft, p.grnSoft, p.soft][state];
    final stFg = [p.muted, p.grn, p.pri][state];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.fmtMin(l.start), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
              Text(a.fmtMin(l.end), style: TextStyle(fontSize: 12.5, color: p.muted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Material(
            color: p.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: p.line)),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => openLectureDetail(context, l),
              child: Padding(
                padding: const EdgeInsets.only(left: 14, right: 4, top: 4, bottom: 4),
                child: Row(
                  children: [
                    SubjectDot(color: a.colorOf(l.subject)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(l.room.isEmpty ? '—' : '${a.t('hall')} ${l.room}', style: TextStyle(fontSize: 13, color: p.muted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: stBg, borderRadius: BorderRadius.circular(20)),
                      child: Text(stLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: stFg)),
                    ),
                    IconButton(
                      tooltip: a.t('edit'),
                      icon: Icon(Icons.more_vert, color: p.muted),
                      onPressed: () => lectureActions(context, l),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── الجدول الأسبوعي ─────────────────────────

class WeekPage extends StatefulWidget {
  const WeekPage({super.key});

  @override
  State<WeekPage> createState() => _WeekPageState();
}

class _WeekPageState extends State<WeekPage> {
  late int day = kWeekdays.contains(DateTime.now().weekday) ? DateTime.now().weekday : 6;

  static const double hr = 64;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final lecs = a.lectures.where((l) => l.weekday == day).toList()..sort((x, y) => x.start.compareTo(y.start));

    var startH = 7;
    var endH = 15;
    for (final l in lecs) {
      if (l.start ~/ 60 < startH) startH = l.start ~/ 60;
      final e = (l.end + 59) ~/ 60;
      if (e > endH) endH = e;
    }
    final height = (endH - startH) * hr + 24;
    final sel = weekDate(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTop(
          subtitle: '${a.shortDate(weekDate(6))} – ${a.shortDate(weekDate(4))}',
          title: a.t('weekTitle'),
          trailing: RoundIconButton(
            icon: Icons.add,
            tooltip: a.t('newT'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddPage(initialWeekday: day))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              for (final wd in kWeekdays)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _pill(a, p, wd),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text('${a.dayName(day)} · ${a.shortDate(sel)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              SizedBox(
                height: height,
                child: Stack(
                  children: [
                    for (var h = startH; h <= endH; h++)
                      PositionedDirectional(
                        top: (h - startH) * hr,
                        start: 0,
                        end: 0,
                        child: Row(
                          children: [
                            SizedBox(width: 56, child: Text(a.fmtMin(h * 60), style: TextStyle(fontSize: 11, color: p.muted))),
                            Expanded(child: Divider(height: 1, thickness: 1, color: p.line)),
                          ],
                        ),
                      ),
                    for (final l in lecs)
                      PositionedDirectional(
                        top: (l.start - startH * 60) / 60 * hr + 1,
                        start: 60,
                        end: 0,
                        height: (l.end - l.start) / 60 * hr - 3,
                        child: Material(
                          color: a.colorOf(l.subject).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => openLectureDetail(context, l),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SubjectDot(color: a.colorOf(l.subject), size: 10),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(l.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700))),
                                      if (!l.on) Icon(Icons.notifications_off_outlined, size: 16, color: p.muted),
                                    ],
                                  ),
                                  Text('${a.fmtMin(l.start)} – ${a.fmtMin(l.end)}${l.room.isEmpty ? '' : ' · ${a.t('hall')} ${l.room}'}',
                                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: p.text.withValues(alpha: 0.8))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (day == now.weekday && nowMin >= startH * 60 && nowMin <= endH * 60)
                      PositionedDirectional(
                        top: (nowMin - startH * 60) / 60 * hr,
                        start: 0,
                        end: 0,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: p.red, borderRadius: BorderRadius.circular(6)),
                              child: Text(a.t('nowLbl'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                            Expanded(child: Container(height: 2, color: p.red)),
                          ],
                        ),
                      ),
                    if (lecs.isEmpty)
                      PositionedDirectional(
                        top: 60,
                        start: 0,
                        end: 0,
                        child: EmptyState(icon: Icons.calendar_today_outlined, title: a.t('noDay')),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: '${a.t('addOnDay')} ${a.dayName(day)}',
                icon: Icons.add,
                kind: BtnKind.soft,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddPage(initialWeekday: day))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(AppState a, Pal p, int wd) {
    final on = wd == day;
    final isToday = wd == DateTime.now().weekday;
    return GestureDetector(
      onTap: () => setState(() => day = wd),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 9),
        decoration: BoxDecoration(
          color: on ? p.pri : p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? p.pri : p.line),
        ),
        child: Column(
          children: [
            Text(a.shortDay(wd), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: on ? p.onPri : p.muted)),
            const SizedBox(height: 2),
            Text('${weekDate(wd).day}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: on ? p.onPri : p.text)),
            const SizedBox(height: 2),
            Container(width: 5, height: 5, decoration: BoxDecoration(color: isToday ? p.grn : Colors.transparent, shape: BoxShape.circle)),
          ],
        ),
      ),
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
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final upN = a.reminders.where((r) => !r.done).length;
    final doneN = a.reminders.where((r) => r.done).length;
    final list = a.reminders.where((r) => r.done == showDone && (filter == 'all' || r.kind == filter)).toList()
      ..sort((x, y) => x.when.compareTo(y.when));

    final children = <Widget>[];
    String? last;
    for (final r in list) {
      if (!showDone) {
        final label = '${a.dayLabel(r.when)} · ${a.shortDate(r.when)}';
        if (label != last) {
          last = label;
          children.add(Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.muted)),
          ));
        }
      }
      children.add(ReminderTile(reminder: r));
    }
    if (list.isEmpty) {
      children.add(EmptyState(
        icon: Icons.assignment_outlined,
        title: showDone ? a.t('noneDone') : a.t('noRem'),
        body: showDone ? null : a.t('noRemD'),
        actions: showDone ? const [] : [AppButton(label: a.t('newT'), icon: Icons.add, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddPage())))],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTop(
          title: a.t('remTitle'),
          trailing: RoundIconButton(icon: Icons.add, tooltip: a.t('newT'), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddPage()))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            children: [
              Seg<bool>(
                items: {false: '${a.t('upcoming')} $upN', true: '${a.t('completed')} $doneN'},
                value: showDone,
                onChanged: (v) => setState(() => showDone = v),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PillChip(label: a.t('fAll'), selected: filter == 'all', onTap: () => setState(() => filter = 'all')),
                    PillChip(label: a.t('fAssign'), selected: filter == 'assignment', onTap: () => setState(() => filter = 'assignment')),
                    PillChip(label: a.t('fExam'), selected: filter == 'exam', onTap: () => setState(() => filter = 'exam')),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => children[i],
          ),
        ),
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
    final p = Pal.of(context);
    final r = reminder;
    final now = DateTime.now();
    final dueToday = !r.done && r.when.year == now.year && r.when.month == now.month && r.when.day == now.day;
    return Material(
      color: p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: p.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => openReminderDetail(context, r),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  await a.update(() => r.done = !r.done);
                  await scheduleReminder(a, r);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: r.done ? p.grn : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: r.done ? p.grn : p.sw, width: 2),
                    ),
                    child: r.done ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: r.done ? p.muted : p.text,
                        decoration: r.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        SubjectDot(color: a.colorOf(r.subject), size: 9),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${r.subject.isEmpty ? '' : '${r.subject} · '}${a.t(r.kind == 'exam' ? 'exam' : 'assignment')} · ${a.fmtDateTime(r.when)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: p.muted),
                          ),
                        ),
                      ],
                    ),
                    if (dueToday)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(color: p.amber, borderRadius: BorderRadius.circular(20)),
                          child: Text(a.t('dueToday'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.amberText)),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.more_vert, color: p.muted), tooltip: a.t('edit'), onPressed: () => reminderActions(context, r)),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── التفاصيل ─────────────────────────

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, this.lectureId, this.reminderId});
  final int? lectureId;
  final int? reminderId;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);

    final Lecture? lec = a.lectures.where((l) => l.id == lectureId).firstOrNull;
    final Reminder? rem = a.reminders.where((r) => r.id == reminderId).firstOrNull;
    if (lec == null && rem == null) return const Scaffold();

    final String title = lec != null ? lec.subject : rem!.title;
    final Color color = a.colorOf(lec != null ? lec.subject : rem!.subject);
    final String kind = lec != null ? a.t('lecture') : a.t(rem!.kind == 'exam' ? 'exam' : 'assignment');
    final String sub = lec != null
        ? '${a.dayName(lec.weekday)} · ${a.fmtMin(lec.start)} – ${a.fmtMin(lec.end)}'
        : '${a.longDate(rem!.when)} · ${a.fmtDateTime(rem.when)}';

    final rows = <List<String>>[
      if (lec != null) ...[
        [a.t('room'), lec.room.isEmpty ? '—' : '${a.t('hall')} ${lec.room}'],
        [a.t('repeat'), a.t('weekly')],
        [a.t('remindBefore'), a.minLabel(lec.before)],
        [a.t('soundRow'), a.toneName],
      ] else ...[
        [a.t('type'), kind],
        [a.t('subject'), rem!.subject.isEmpty ? '—' : rem.subject],
        [a.t('due'), '${a.longDate(rem.when)} · ${a.fmtDateTime(rem.when)}'],
        [a.t('remindBefore'), a.minLabel(rem.before)],
        [a.t('soundRow'), a.toneName],
      ],
    ];

    Future<void> onDelete() async {
      final nav = Navigator.of(context);
      if (lec != null) {
        await deleteLecture(context, lec);
        if (!a.lectures.any((x) => x.id == lec!.id)) nav.pop();
      } else {
        await deleteReminder(context, rem!);
        if (!a.reminders.any((x) => x.id == rem!.id)) nav.pop();
      }
    }

    void onEdit() {
      if (lec != null) {
        openEditLecture(context, lec);
      } else {
        openEditReminder(context, rem!);
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(tooltip: a.t('edit'), icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(tooltip: a.t('delete'), icon: Icon(Icons.delete_outline, color: p.red), onPressed: onDelete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SubjectDot(color: color, size: 9),
                      const SizedBox(width: 6),
                      Text(kind, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontSize: 26, height: 1.3, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(sub, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(border: i == rows.length - 1 ? null : Border(bottom: BorderSide(color: p.line))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rows[i][0], style: TextStyle(color: p.muted)),
                        const SizedBox(width: 12),
                        Flexible(child: Text(rows[i][1], textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (lec != null)
            AppCard(
              child: Row(
                children: [
                  const IconBox(icon: Icons.notifications_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text(a.t('alertEnabled'), style: const TextStyle(fontWeight: FontWeight.w600))),
                  Switch(
                    value: lec.on,
                    onChanged: (v) async {
                      await a.update(() => lec!.on = v);
                      await scheduleLecture(a, lec!);
                    },
                  ),
                ],
              ),
            )
          else
            AppButton(
              label: rem!.done ? a.t('markUndone') : a.t('markDone'),
              icon: Icons.check,
              onTap: () async {
                await a.update(() => rem!.done = !rem!.done);
                await scheduleReminder(a, rem!);
              },
            ),
          const SizedBox(height: 12),
          AppButton(label: a.t('edit'), icon: Icons.edit_outlined, kind: BtnKind.soft, onTap: onEdit),
          const SizedBox(height: 12),
          AppButton(label: a.t('delete'), icon: Icons.delete_outline, kind: BtnKind.danger, onTap: onDelete),
        ],
      ),
    );
  }
}

// ───────────────────────── إضافة / تعديل ─────────────────────────

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.editLecture, this.editReminder, this.initialWeekday});
  final Lecture? editLecture;
  final Reminder? editReminder;
  final int? initialWeekday;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  bool _init = false;
  String type = 'lecture'; // lecture | assignment | exam
  String subject = '';
  int weekday = 6;
  int start = 540;
  int end = 630;
  int before = 10;
  int rBefore = 1440;
  late DateTime date;
  int timeMin = 1020;
  final roomCtl = TextEditingController();
  final titleCtl = TextEditingController();

  bool get isEdit => widget.editLecture != null || widget.editReminder != null;
  bool get isLec => type == 'lecture';

  @override
  void dispose() {
    roomCtl.dispose();
    titleCtl.dispose();
    super.dispose();
  }

  void _setup(AppState a) {
    _init = true;
    final now = DateTime.now();
    date = DateTime(now.year, now.month, now.day);
    subject = a.subjects.isNotEmpty ? a.subjects.first.name : '';
    before = a.defBefore;
    weekday = widget.initialWeekday ?? (kWeekdays.contains(now.weekday) ? now.weekday : 6);
    final l = widget.editLecture;
    final r = widget.editReminder;
    if (l != null) {
      type = 'lecture';
      subject = l.subject;
      weekday = l.weekday;
      start = l.start;
      end = l.end;
      before = l.before;
      roomCtl.text = l.room;
    } else if (r != null) {
      type = r.kind == 'exam' ? 'exam' : 'assignment';
      subject = r.subject;
      titleCtl.text = r.title;
      date = DateTime(r.when.year, r.when.month, r.when.day);
      timeMin = r.when.hour * 60 + r.when.minute;
      rBefore = r.before;
    }
  }

  Future<int?> _pickTime(AppState a, int current) async {
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (current ~/ 60) % 24, minute: current % 60),
      builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: a.use24), child: w!),
    );
    if (res == null) return null;
    return res.hour * 60 + res.minute;
  }

  Future<void> _pickSubject(AppState a) async {
    final p = Pal.of(context);
    await showAppSheet<void>(
      context,
      (c) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(a.t('pickSubject'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final s in a.subjects)
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() => subject = s.name);
                      Navigator.of(c).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      child: Row(
                        children: [
                          SubjectDot(color: kSubjectColors[s.color % kSubjectColors.length]),
                          const SizedBox(width: 12),
                          Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          Icon(subject == s.name ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: subject == s.name ? p.pri : p.sw),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: a.t('addSubject'),
            icon: Icons.add,
            kind: BtnKind.soft,
            onTap: () async {
              final nav = Navigator.of(c);
              nav.pop();
              await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SubjectsPage()));
              if (mounted && a.subjects.isNotEmpty && !a.subjects.any((s) => s.name == subject)) {
                setState(() => subject = a.subjects.first.name);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _save(AppState a) async {
    final nav = Navigator.of(context);
    if (isLec) {
      if (subject.isEmpty) {
        showToast(context, a.t('pickSubject'));
        return;
      }
      if (end <= start) {
        showToast(context, a.t('endAfter'));
        return;
      }
      final room = roomCtl.text.trim();
      Lecture target;
      final e = widget.editLecture;
      if (e != null) {
        target = e;
        await a.update(() {
          e.subject = subject;
          e.weekday = weekday;
          e.start = start;
          e.end = end;
          e.room = room;
          e.before = before;
        });
      } else {
        target = Lecture(id: a.newId(), subject: subject, weekday: weekday, start: start, end: end, room: room, before: before);
        await a.update(() => a.lectures.add(target));
      }
      await scheduleLecture(a, target);
    } else {
      final title = titleCtl.text.trim();
      if (title.isEmpty) {
        showToast(context, a.t('needTitle'));
        return;
      }
      final when = DateTime(date.year, date.month, date.day, timeMin ~/ 60, timeMin % 60);
      Reminder target;
      final e = widget.editReminder;
      if (e != null) {
        target = e;
        await a.update(() {
          e.title = title;
          e.kind = type;
          e.subject = subject;
          e.when = when;
          e.before = rBefore;
        });
      } else {
        target = Reminder(id: a.newId(), title: title, kind: type, subject: subject, when: when, before: rBefore);
        await a.update(() => a.reminders.add(target));
      }
      await scheduleReminder(a, target);
    }
    if (mounted) showToast(context, a.t('saved'));
    nav.pop();
  }

  Widget _label(Pal p, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.muted)),
      );

  Widget _field(Pal p, {required Widget child, required VoidCallback onTap}) => Material(
        color: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: p.line)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(constraints: const BoxConstraints(minHeight: 54), padding: const EdgeInsets.symmetric(horizontal: 16), alignment: AlignmentDirectional.centerStart, child: child),
        ),
      );

  InputDecoration _dec(Pal p, String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: p.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.pri, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    if (!_init) _setup(a);

    final title = isEdit ? (widget.editLecture != null ? a.t('editLecT') : a.t('editRemT')) : a.t('newT');
    final befores = isLec ? <int>[5, 10, 15, 30, 60] : <int>[60, 180, 1440, 2880];
    final selBefore = isLec ? before : rBefore;
    final subjColor = a.colorOf(subject);

    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (!isEdit) ...[
            Seg<String>(
              items: {'lecture': a.t('lecture'), 'assignment': a.t('assignment'), 'exam': a.t('exam')},
              value: type,
              onChanged: (v) => setState(() => type = v),
            ),
            const SizedBox(height: 18),
          ],
          if (!isLec) ...[
            _label(p, a.t('title')),
            TextField(controller: titleCtl, decoration: _dec(p, a.t('titleHint'))),
            const SizedBox(height: 18),
          ],
          _label(p, a.t('subject')),
          _field(
            p,
            onTap: () => _pickSubject(a),
            child: Row(
              children: [
                SubjectDot(color: subjColor),
                const SizedBox(width: 12),
                Expanded(child: Text(subject.isEmpty ? a.t('pickSubject') : subject, style: const TextStyle(fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right, color: p.muted),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (isLec) ...[
            _label(p, a.t('day')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final wd in kWeekdays) PillChip(label: a.shortDay(wd), selected: weekday == wd, onTap: () => setState(() => weekday = wd))],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(p, a.t('startTime')),
                      _field(p, onTap: () async {
                        final v = await _pickTime(a, start);
                        if (v != null) {
                          setState(() {
                            start = v;
                            if (end <= start) end = (start + 90).clamp(0, 1439).toInt();
                          });
                        }
                      }, child: Row(children: [Icon(Icons.schedule, size: 18, color: p.muted), const SizedBox(width: 8), Text(a.fmtMin(start), style: const TextStyle(fontWeight: FontWeight.w600))])),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(p, a.t('endTime')),
                      _field(p, onTap: () async {
                        final v = await _pickTime(a, end);
                        if (v == null) return;
                        if (v <= start) {
                          if (mounted) showToast(context, a.t('endAfter'));
                        } else {
                          setState(() => end = v);
                        }
                      }, child: Row(children: [Icon(Icons.schedule, size: 18, color: p.muted), const SizedBox(width: 8), Text(a.fmtMin(end), style: const TextStyle(fontWeight: FontWeight.w600))])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _label(p, a.t('room')),
            TextField(controller: roomCtl, decoration: _dec(p, a.t('roomHint'))),
            const SizedBox(height: 18),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(p, a.t('date')),
                      _field(p, onTap: () async {
                        final now = DateTime.now();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: date.isBefore(DateTime(now.year, now.month, now.day)) ? DateTime(now.year, now.month, now.day) : date,
                          firstDate: DateTime(now.year, now.month, now.day),
                          lastDate: DateTime(now.year + 2, now.month, now.day),
                        );
                        if (d != null) setState(() => date = d);
                      }, child: Row(children: [Icon(Icons.event, size: 18, color: p.muted), const SizedBox(width: 8), Flexible(child: Text(a.shortDate(date), overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)))])),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(p, a.t('time')),
                      _field(p, onTap: () async {
                        final v = await _pickTime(a, timeMin);
                        if (v != null) setState(() => timeMin = v);
                      }, child: Row(children: [Icon(Icons.schedule, size: 18, color: p.muted), const SizedBox(width: 8), Text(a.fmtMin(timeMin), style: const TextStyle(fontWeight: FontWeight.w600))])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          _label(p, a.t('remindBefore')),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in befores)
                PillChip(label: a.minLabel(m), selected: selBefore == m, onTap: () => setState(() => isLec ? before = m : rBefore = m)),
            ],
          ),
          const SizedBox(height: 18),
          _label(p, a.t('soundRow')),
          _field(
            p,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SoundPage()));
              if (mounted) setState(() {});
            },
            child: Row(
              children: [
                Icon(Icons.music_note_outlined, size: 20, color: p.muted),
                const SizedBox(width: 10),
                Expanded(child: Text(a.toneName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right, color: p.muted),
              ],
            ),
          ),
          if (isEdit) ...[
            const SizedBox(height: 18),
            AppButton(
              label: a.t('delete'),
              icon: Icons.delete_outline,
              kind: BtnKind.danger,
              onTap: () async {
                final nav = Navigator.of(context);
                final l = widget.editLecture;
                final r = widget.editReminder;
                if (l != null) {
                  await deleteLecture(context, l);
                  if (!a.lectures.any((x) => x.id == l.id)) nav.pop();
                } else if (r != null) {
                  await deleteReminder(context, r);
                  if (!a.reminders.any((x) => x.id == r.id)) nav.pop();
                }
              },
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            children: [
              Expanded(child: AppButton(label: a.t('cancel'), kind: BtnKind.soft, onTap: () => Navigator.of(context).pop())),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: AppButton(label: a.t('save'), onTap: () => _save(a))),
            ],
          ),
        ),
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
    final p = Pal.of(context);

    Widget radio(bool on) => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? p.pri : p.sw, width: 2)),
          child: on ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(color: p.pri, shape: BoxShape.circle))) : null,
        );

    Widget option({required bool selected, required String title, required String sub, required VoidCallback onTap, Widget? trailing}) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              radio(selected),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(sub, style: TextStyle(fontSize: 13.5, color: p.muted)),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      );
    }

    final durOptions = <int, String>{1: a.t('min1'), 5: a.t('min5'), 10: a.t('min10'), 0: a.t('untilStop')};

    return Scaffold(
      appBar: AppBar(title: Text(a.t('soundTitle'), style: const TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                option(
                  selected: a.soundMode == 'default',
                  title: a.t('phoneDefault'),
                  sub: a.t('phoneDefaultSub'),
                  onTap: () => a.update(() => a.soundMode = 'default'),
                ),
                Divider(height: 1, color: p.line),
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
                  trailing: PillChip(label: a.t('chooseTone'), selected: false, onTap: () => pickRingtone(a)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBox(icon: Icons.repeat),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.t('continuous'), style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(a.t('continuousSub'), style: TextStyle(fontSize: 13.5, color: p.muted)),
                        ],
                      ),
                    ),
                    Switch(value: a.continuous, onChanged: (v) => a.update(() => a.continuous = v)),
                  ],
                ),
                if (a.continuous) ...[
                  const SizedBox(height: 14),
                  Text(a.t('repeatFor'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.muted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final e in durOptions.entries) PillChip(label: e.value, selected: a.repeatMin == e.key, onTap: () => a.update(() => a.repeatMin = e.key))],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Row(
              children: [
                const IconBox(icon: Icons.vibration),
                const SizedBox(width: 12),
                Expanded(child: Text(a.t('vibrate'), style: const TextStyle(fontWeight: FontWeight.w600))),
                Switch(value: a.vibrate, onChanged: (v) => a.update(() => a.vibrate = v)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            children: [
              Expanded(child: AppButton(label: a.t('preview'), icon: Icons.play_arrow_rounded, kind: BtnKind.soft, onTap: () => previewAlert(a))),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: a.t('save'),
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await rescheduleAll(a);
                    if (context.mounted) showToast(context, a.t('saved'));
                    nav.pop();
                  },
                ),
              ),
            ],
          ),
        ),
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
    final p = Pal.of(context);

    Widget sec(String s) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
          child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.muted)),
        );

    Widget lbl(String s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.muted)),
        );

    Widget row(IconData icon, String title, {String? value, Color? color, Color? iconBg, VoidCallback? onTap, bool chevron = true}) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              IconBox(icon: icon, bg: iconBg, fg: color),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? p.text))),
              if (value != null) Text(value, style: TextStyle(color: p.muted, fontSize: 13.5)),
              if (chevron && onTap != null) ...[const SizedBox(width: 4), Icon(Icons.chevron_right, color: p.muted)],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTop(title: a.t('settings')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              sec(a.t('appearance')),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    lbl(a.t('appearance')),
                    Seg<ThemeMode>(
                      items: {ThemeMode.light: a.t('light'), ThemeMode.dark: a.t('dark'), ThemeMode.system: a.t('system')},
                      value: a.themeMode,
                      onChanged: (v) => a.update(() => a.themeMode = v),
                    ),
                    const SizedBox(height: 14),
                    lbl(a.t('language')),
                    Seg<String>(
                      items: const {'ar': 'العربية', 'en': 'English'},
                      value: a.lang,
                      onChanged: (v) async {
                        await a.update(() => a.lang = v);
                        await rescheduleAll(a);
                      },
                    ),
                    const SizedBox(height: 14),
                    lbl(a.t('timeFormat')),
                    Seg<bool>(
                      items: {false: a.t('h12'), true: a.t('h24')},
                      value: a.use24,
                      onChanged: (v) async {
                        await a.update(() => a.use24 = v);
                        await rescheduleAll(a);
                      },
                    ),
                  ],
                ),
              ),
              sec(a.t('alerts')),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    row(Icons.music_note_outlined, a.t('soundRow'), value: a.toneName, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SoundPage()))),
                    Divider(height: 24, color: p.line),
                    lbl(a.t('defBefore')),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final m in [5, 10, 15, 30]) PillChip(label: a.minLabel(m), selected: a.defBefore == m, onTap: () => a.update(() => a.defBefore = m))],
                    ),
                  ],
                ),
              ),
              sec(a.t('data')),
              AppCard(
                child: Column(
                  children: [
                    row(Icons.menu_book_outlined, a.t('subjects'), value: '${a.subjects.length}', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SubjectsPage()))),
                    Divider(height: 24, color: p.line),
                    row(Icons.delete_outline, a.t('clearAll'), color: p.red, iconBg: p.redSoft, chevron: false, onTap: () async {
                      final ok = await confirmSheet(context, title: a.t('clearQ'), sub: a.t('clearD'), yes: a.t('yesClear'), no: a.t('cancel'));
                      if (!ok) return;
                      await plugin.cancelAll();
                      await a.update(() {
                        a.lectures.clear();
                        a.reminders.clear();
                      });
                      if (context.mounted) showToast(context, a.t('cleared'));
                    }),
                  ],
                ),
              ),
              sec(a.t('about')),
              AppCard(child: row(Icons.info_outline, a.t('app'), value: a.t('version'), chevron: false)),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── المواد الدراسية ─────────────────────────

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final ctl = TextEditingController();

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  Future<void> _add(AppState a) async {
    final name = ctl.text.trim();
    if (name.isEmpty) {
      showToast(context, a.t('required'));
      return;
    }
    if (a.subjects.any((s) => s.name == name)) {
      ctl.clear();
      return;
    }
    await a.update(() => a.subjects.add(Subject(name: name, color: a.subjects.length % kSubjectColors.length)));
    ctl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(a.t('subjects'), style: const TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(a),
                  decoration: InputDecoration(
                    hintText: a.t('subjNew'),
                    filled: true,
                    fillColor: p.card,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.line)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(width: 96, child: AppButton(label: a.t('subjAdd'), onTap: () => _add(a))),
            ],
          ),
          const SizedBox(height: 14),
          for (final s in a.subjects.toList())
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
                child: Row(
                  children: [
                    SubjectDot(color: kSubjectColors[s.color % kSubjectColors.length], size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${a.lectures.where((l) => l.subject == s.name).length} ${a.t('lecN')}', style: TextStyle(fontSize: 13, color: p.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: a.t('delete'),
                      icon: Icon(Icons.delete_outline, color: p.red),
                      onPressed: () async {
                        if (a.lectures.any((l) => l.subject == s.name)) {
                          showToast(context, a.t('subjUsed'));
                          return;
                        }
                        await a.update(() => a.subjects.remove(s));
                      },
                    ),
                  ],
                ),
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
    final now = DateTime.now();
    const navy = Color(0xFF0A1230);
    const blue = Color(0xFF1E5BD8);
    return Scaffold(
      backgroundColor: navy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -1), radius: 1.3, colors: [Color(0xFF1E3A8A), navy], stops: [0, 0.62]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
                  child: Text(a.t('alarmBadge'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                Text(a.fmtDateTime(now), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(a.longDate(now), style: const TextStyle(color: Color(0xFFC3D2F5))),
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
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: blue),
                                  ),
                                );
                              }),
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(38)),
                              ch