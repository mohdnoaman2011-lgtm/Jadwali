part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Localisation helpers (Arabic / English, RTL handled by MaterialApp)
// ═══════════════════════════════════════════════════════════════════════
const _strings = <String, Map<String, String>>{
  'ar': {
    'headline': 'جدولك الجامعي،\nدائمًا في الوقت.',
    'sub': 'محاضرات وواجبات وامتحانات في مكان واحد، مع تنبيه ذكي قبل كل موعد.',
    'start': 'ابدأ الآن',
    'langBtn': 'EN',
    'nav0': 'اليوم',
    'nav1': 'الجدول',
    'nav2': 'إضافة',
    'nav3': 'حسابي',
    'nextClass': 'المحاضرة التالية',
    'restOfDay': 'بقية يومك',
    'noClasses': 'لا توجد محاضرات في هذا اليوم',
    'schedule': 'جدول الأسبوع',
    'week': 'أسبوع',
    'month': 'شهر',
    'newReminder': 'تذكير جديد',
    'title': 'العنوان',
    'type': 'النوع',
    'lecture': 'محاضرة',
    'assignment': 'واجب',
    'exam': 'امتحان',
    'date': 'التاريخ',
    'time': 'الوقت',
    'remindBefore': 'نبّهني قبل',
    'repeatWeekly': 'تكرار أسبوعي',
    'save': 'حفظ التذكير',
    'saved': 'تم حفظ التذكير',
    'enterTitle': 'أدخل عنوان التذكير',
    'yourReminders': 'تذكيراتك',
    'settings': 'الإعدادات',
    'appearance': 'المظهر',
    'light': 'فاتح',
    'dark': 'داكن',
    'auto': 'تلقائي (النظام)',
    'language': 'اللغة',
    'timeFormat': 'نظام الوقت',
    'h12': '١٢ ساعة',
    'h24': '٢٤ ساعة',
    'alertSettings': 'ضبط التنبيه',
    'leadTime': 'التنبيه قبل الموعد',
    'tone': 'نغمة التنبيه',
    'vibration': 'الاهتزاز',
    'snooze': 'غفوة التنبيه',
    'deadlineAlerts': 'تنبيه المواعيد النهائية',
    'toneCalm': 'هادئ',
    'toneBell': 'جرس',
    'toneClassic': 'كلاسيكي',
    'classAlert': 'تنبيه المحاضرة',
    'now': 'الآن',
    'getReady': 'استعد، محاضرتك على وشك البدء',
    'snoozeBtn': 'غفوة ٥ دقائق',
    'gotIt': 'تم، شكرًا',
    'viewSchedule': 'عرض الجدول الكامل',
    'testAlert': 'تجربة التنبيه (بعد ٥ ثوانٍ)',
    'testSent': 'سيصلك التنبيه بعد ٥ ثوانٍ',
    'notifDenied': 'الإشعارات غير مفعّلة، فعّلها من إعدادات الجهاز',
    'toneDefault': 'الافتراضي (نغمة النظام)',
    'toneNotif': 'الإشعارات',
    'toneAlarm': 'المنبهات',
    'toneRing': 'النغمات',
    'toneIosNote': 'نظام iOS لا يسمح للتطبيقات باستخدام نغمات الهاتف في الإشعارات، لذلك يُستخدم صوت الإشعار الافتراضي.',
    'noSounds': 'لم يتم العثور على نغمات',
    'addClass': 'إضافة محاضرة',
    'saveClass': 'حفظ المحاضرة',
    'editClass': 'تعديل المحاضرة',
    'className': 'اسم المادة',
    'lab': 'مختبر',
    'deadlineKind': 'موعد نهائي',
    'day': 'اليوم',
    'startTime': 'وقت البداية',
    'endTime': 'وقت النهاية',
    'place': 'القاعة / المكان',
    'color': 'اللون',
    'delete': 'حذف',
    'deleteConfirm': 'هل تريد حذف هذه المحاضرة؟',
    'cancel': 'إلغاء',
    'invalidTime': 'يجب أن يكون وقت النهاية بعد وقت البداية',
    'enterName': 'أدخل اسم المادة',
    'add_lecture': 'إضافة محاضرة',
    'add_lab': 'إضافة مختبر',
    'add_exam': 'إضافة امتحان',
    'add_deadline': 'إضافة موعد نهائي',
    'edit_lecture': 'تعديل المحاضرة',
    'edit_lab': 'تعديل المختبر',
    'edit_exam': 'تعديل الامتحان',
    'edit_deadline': 'تعديل الموعد النهائي',
    'save_lecture': 'حفظ المحاضرة',
    'save_lab': 'حفظ المختبر',
    'save_exam': 'حفظ الامتحان',
    'save_deadline': 'حفظ الموعد النهائي',
    'delete_lecture': 'حذف المحاضرة؟',
    'delete_lab': 'حذف المختبر؟',
    'delete_exam': 'حذف الامتحان؟',
    'delete_deadline': 'حذف الموعد النهائي؟',
    'deleteBody': 'سيتم حذف «%s» وإلغاء التنبيهات المرتبطة.',
    'deleted': 'تم الحذف',
    'undo': 'تراجع',
    'feat1': 'جدول منظّم',
    'feat2': 'تنبيهات ذكية',
    'feat3': 'نغمات مخصصة',
    'daySchedule': 'جدول اليوم',
    'doneToday': 'انتهت محاضرات اليوم',
    'am': 'ص',
    'pm': 'م',
  },
  'en': {
    'headline': 'Your university schedule,\nalways on time.',
    'sub':
        'Lectures, assignments and exams in one place, with a smart alert before every event.',
    'start': 'Get started',
    'langBtn': 'AR',
    'nav0': 'Today',
    'nav1': 'Schedule',
    'nav2': 'Add',
    'nav3': 'Profile',
    'nextClass': 'Next class',
    'restOfDay': 'Rest of your day',
    'noClasses': 'No classes on this day',
    'schedule': 'Weekly schedule',
    'week': 'Week',
    'month': 'Month',
    'newReminder': 'New reminder',
    'title': 'Title',
    'type': 'Type',
    'lecture': 'Lecture',
    'assignment': 'Assignment',
    'exam': 'Exam',
    'date': 'Date',
    'time': 'Time',
    'remindBefore': 'Remind me before',
    'repeatWeekly': 'Repeat weekly',
    'save': 'Save reminder',
    'saved': 'Reminder saved',
    'enterTitle': 'Enter a title',
    'yourReminders': 'Your reminders',
    'settings': 'Settings',
    'appearance': 'Appearance',
    'light': 'Light',
    'dark': 'Dark',
    'auto': 'Auto (System)',
    'language': 'Language',
    'timeFormat': 'Time format',
    'h12': '12-hour',
    'h24': '24-hour',
    'alertSettings': 'Alert settings',
    'leadTime': 'Alert before event',
    'tone': 'Alert tone',
    'vibration': 'Vibration',
    'snooze': 'Snooze',
    'deadlineAlerts': 'Deadline alerts',
    'toneCalm': 'Calm',
    'toneBell': 'Bell',
    'toneClassic': 'Classic',
    'classAlert': 'Class alert',
    'now': 'Now',
    'getReady': 'Get ready, your class is about to start',
    'snoozeBtn': 'Snooze 5 min',
    'gotIt': 'Got it',
    'viewSchedule': 'View full schedule',
    'testAlert': 'Test alert (in 5 sec)',
    'testSent': 'The alert will arrive in 5 seconds',
    'notifDenied': 'Notifications are off. Enable them in device settings.',
    'toneDefault': 'Default (system sound)',
    'toneNotif': 'Notifications',
    'toneAlarm': 'Alarms',
    'toneRing': 'Ringtones',
    'toneIosNote': 'iOS does not let apps use the phone\'s ringtones for notifications, so the default notification sound is used.',
    'noSounds': 'No sounds found',
    'addClass': 'Add class',
    'saveClass': 'Save class',
    'editClass': 'Edit class',
    'className': 'Course name',
    'lab': 'Lab',
    'deadlineKind': 'Deadline',
    'day': 'Day',
    'startTime': 'Start time',
    'endTime': 'End time',
    'place': 'Room / Place',
    'color': 'Color',
    'delete': 'Delete',
    'deleteConfirm': 'Delete this class?',
    'cancel': 'Cancel',
    'invalidTime': 'End time must be after start time',
    'enterName': 'Enter the course name',
    'add_lecture': 'Add lecture',
    'add_lab': 'Add lab',
    'add_exam': 'Add exam',
    'add_deadline': 'Add deadline',
    'edit_lecture': 'Edit lecture',
    'edit_lab': 'Edit lab',
    'edit_exam': 'Edit exam',
    'edit_deadline': 'Edit deadline',
    'save_lecture': 'Save lecture',
    'save_lab': 'Save lab',
    'save_exam': 'Save exam',
    'save_deadline': 'Save deadline',
    'delete_lecture': 'Delete this lecture?',
    'delete_lab': 'Delete this lab?',
    'delete_exam': 'Delete this exam?',
    'delete_deadline': 'Delete this deadline?',
    'deleteBody': '“%s” and its alerts will be removed.',
    'deleted': 'Deleted',
    'undo': 'Undo',
    'feat1': 'Organized schedule',
    'feat2': 'Smart alerts',
    'feat3': 'Custom tones',
    'daySchedule': "Day's schedule",
    'doneToday': 'All done for today',
    'am': 'AM',
    'pm': 'PM',
  },
};

String tr(String key) => _strings[app.locale.languageCode]![key] ?? key;

/// Arabic-Indic digits when the UI language is Arabic.
String nm(Object v) {
  final s = v.toString();
  if (!app.isAr) return s;
  const d = '٠١٢٣٤٥٦٧٨٩';
  return s.replaceAllMapped(RegExp(r'\d'), (m) => d[int.parse(m[0]!)]);
}

class Bi {
  final String ar, en;
  const Bi(this.ar, this.en);
  String get v => app.isAr ? ar : en;
}

const _daysAr = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const _daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _shortAr = ['اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت', 'أحد'];
const _shortEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
];
const _monthsEn = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

String dayName(int weekday) => (app.isAr ? _daysAr : _daysEn)[weekday - 1];
String dayShort(int weekday) => (app.isAr ? _shortAr : _shortEn)[weekday - 1];
String monthName(int month) => (app.isAr ? _monthsAr : _monthsEn)[month - 1];

String dateLabel(DateTime d) =>
    '${dayName(d.weekday)}${app.isAr ? '،' : ','} ${nm(d.day)} ${monthName(d.month)}';

String fmtTime(TimeOfDay t) {
  final mm = t.minute.toString().padLeft(2, '0');
  if (app.use24h) return nm('${t.hour.toString().padLeft(2, '0')}:$mm');
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final suffix = t.period == DayPeriod.am ? tr('am') : tr('pm');
  return '${nm('$h:$mm')} $suffix';
}

String inMinutes(int m) {
  if (m >= 60) {
    final h = m ~/ 60;
    return app.isAr ? 'بعد ${nm(h)} ساعة' : 'in $h h';
  }
  return app.isAr ? 'بعد ${nm(m)} دقيقة' : 'in $m min';
}

String leadShort(int m) => m == 60
    ? (app.isAr ? 'ساعة' : '1 hr')
    : (app.isAr ? '${nm(m)} د' : '$m min');

String leadLong(int m) => m == 60
    ? (app.isAr ? 'ساعة' : '1 hour')
    : (app.isAr ? '${nm(m)} دقيقة' : '$m min');

extension TimeMinutes on TimeOfDay {
  int get totalMinutes => hour * 60 + minute;
}
