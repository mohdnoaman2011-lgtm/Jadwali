import 'package:flutter/material.dart';

const dayKeys = ['sun', 'mon', 'tue', 'wed', 'thu'];
const _weekdayOf = {
  'sun': DateTime.sunday,
  'mon': DateTime.monday,
  'tue': DateTime.tuesday,
  'wed': DateTime.wednesday,
  'thu': DateTime.thursday,
};

class Lecture {
  Lecture({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.day,
    required this.start,
    required this.end,
    required this.room,
    required this.prof,
    required this.color,
  });

  final int id;
  String code, nameAr, nameEn, day, start, end, room, prof;
  Color color;

  String name(bool ar) => ar ? nameAr : nameEn;

  /// Minutes since midnight, parsed from "10:00 AM" / "13:30".
  int get startMinutes {
    final m = RegExp(r'(\d{1,2}):(\d{2})\s*([AaPp][Mm])?').firstMatch(start.trim());
    if (m == null) return 0;
    var h = int.parse(m[1]!);
    final min = int.parse(m[2]!);
    final ap = m[3]?.toLowerCase();
    if (ap == 'pm' && h < 12) h += 12;
    if (ap == 'am' && h == 12) h = 0;
    return h * 60 + min;
  }

  DateTime nextStart(DateTime now) {
    final diff = (_weekdayOf[day]! - now.weekday) % 7;
    var d = DateTime(now.year, now.month, now.day + diff, 0, startMinutes);
    if (!d.isAfter(now)) d = d.add(const Duration(days: 7));
    return d;
  }
}

enum TaskType { assignment, exam, project }

class Task {
  Task({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.subAr,
    required this.subEn,
    required this.type,
    this.done = false,
  });

  final int id;
  String titleAr, titleEn, subAr, subEn;
  TaskType type;
  bool done;

  String title(bool ar) => ar ? titleAr : titleEn;
  String sub(bool ar) => ar ? subAr : subEn;
}

class Profile {
  Profile({required this.name, required this.university, required this.major, required this.studentId});
  String name, university, major, studentId;
}

class AppState extends ChangeNotifier {
  AppState() {
    reset(notify: false);
  }

  String lang = 'ar';
  bool dark = false;
  bool notifications = true;
  int tone = 0;
  late Profile profile;
  late List<Lecture> lectures;
  late List<Task> tasks;

  bool get ar => lang == 'ar';
  String t(String key) => _strings[lang]![key] ?? key;
  List<String> get tones => _tones[lang]!;
  String dayName(String key) => _days[lang]![key]!;
  String weekdayName(int weekday) => _weekdays[lang]![weekday - 1];
  String get todayKey {
    const m = {1: 'mon', 2: 'tue', 3: 'wed', 4: 'thu', 5: 'fri', 6: 'sat', 7: 'sun'};
    return m[DateTime.now().weekday]!;
  }

  void reset({bool notify = true}) {
    profile = Profile(
      name: 'أحمد المحمد',
      university: 'جامعة الملك سعود',
      major: 'هندسة الحاسوب',
      studentId: '441098234',
    );
    lectures = [
      Lecture(id: 1, code: 'NET201', nameAr: 'شبكات الحاسوب', nameEn: 'Computer Networks', day: 'sun', start: '08:00 AM', end: '09:30 AM', room: 'Hall 102', prof: 'Dr. Khaled', color: const Color(0xFFD97706)),
      Lecture(id: 2, code: 'AI401', nameAr: 'الذكاء الاصطناعي', nameEn: 'Artificial Intelligence', day: 'mon', start: '10:00 AM', end: '11:30 AM', room: 'Hall 405', prof: 'Dr. Ibrahim', color: const Color(0xFFE11D48)),
      Lecture(id: 3, code: 'SE302', nameAr: 'هندسة البرمجيات', nameEn: 'Software Engineering', day: 'wed', start: '10:00 AM', end: '11:30 AM', room: 'Hall 304', prof: 'Dr. Ahmed', color: const Color(0xFF4F46E5)),
      Lecture(id: 4, code: 'CS311', nameAr: 'قواعد البيانات المتقدمة', nameEn: 'Advanced Databases', day: 'wed', start: '12:00 PM', end: '01:30 PM', room: 'Lab 2', prof: 'Dr. Sarah', color: const Color(0xFF059669)),
    ];
    tasks = [
      Task(id: 1, titleAr: 'تسليم مشروع البرمجة الكائنية', titleEn: 'OOP Project Submission', subAr: 'هندسة البرمجيات • غداً، 12:00 م', subEn: 'Software Engineering • Tomorrow, 12:00 PM', type: TaskType.project),
      Task(id: 2, titleAr: 'اختبار قصير في شبكات الحاسوب', titleEn: 'Networks Quiz', subAr: 'شبكات الحاسوب • الأحد القادم', subEn: 'Computer Networks • Next Sunday', type: TaskType.exam),
      Task(id: 3, titleAr: 'حل واجب قواعد البيانات', titleEn: 'Database Assignment 1', subAr: 'قواعد البيانات • الخميس القادم', subEn: 'Databases • Next Thursday', type: TaskType.assignment, done: true),
    ];
    if (notify) notifyListeners();
  }

  void setLang(String l) { lang = l; notifyListeners(); }
  void toggleDark() { dark = !dark; notifyListeners(); }
  void toggleNotifications() { notifications = !notifications; notifyListeners(); }
  void setTone(int i) { tone = i; notifyListeners(); }
  void updateProfile(Profile p) { profile = p; notifyListeners(); }

  void saveLecture(Lecture l) {
    final i = lectures.indexWhere((x) => x.id == l.id);
    if (i >= 0) {
      lectures[i] = l;
    } else {
      lectures.add(l);
    }
    notifyListeners();
  }

  void deleteLecture(int id) { lectures.removeWhere((l) => l.id == id); notifyListeners(); }
  void addTask(Task task) { tasks.add(task); notifyListeners(); }
  void toggleTask(Task task) { task.done = !task.done; notifyListeners(); }
  void deleteTask(int id) { tasks.removeWhere((t) => t.id == id); notifyListeners(); }
}

const _days = {
  'ar': {'sun': 'الأحد', 'mon': 'الإثنين', 'tue': 'الثلاثاء', 'wed': 'الأربعاء', 'thu': 'الخميس'},
  'en': {'sun': 'Sunday', 'mon': 'Monday', 'tue': 'Tuesday', 'wed': 'Wednesday', 'thu': 'Thursday'},
};

const _weekdays = {
  'ar': ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'],
  'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
};

const _tones = {
  'ar': ['جرس كلاسيكي', 'نغمة هادئة', 'تنبيه حاد', 'اهتزاز فقط'],
  'en': ['Classic bell', 'Calm chime', 'Sharp alert', 'Vibrate only'],
};

const _strings = {
  'ar': {
    'nav_home': 'الرئيسية', 'nav_schedule': 'الجدول الأسبوعي', 'nav_tasks': 'المهام والتذكيرات', 'nav_settings': 'الإعدادات',
    'tagline': 'نظّم جدولك الجامعي بسهولة',
    'welcome': 'مرحباً بك', 'next_lecture': 'المحاضرة القادمة', 'hrs': 'ساعة', 'mins': 'دقيقة', 'secs': 'ثانية',
    'today_lectures': 'محاضرات اليوم', 'full_schedule': 'الجدول الكامل', 'upcoming_tasks': 'المهام والتسليمات القادمة',
    'all': 'الكل', 'assignments': 'واجبات', 'exams': 'اختبارات', 'projects': 'مشاريع',
    'no_lectures_day': 'لا توجد محاضرات في هذا اليوم', 'no_lectures_today': 'لا توجد محاضرات اليوم', 'no_tasks': 'لا توجد مهام حالياً',
    'reminder': 'تذكير',
    'student_details': 'بيانات الطالب', 'edit': 'تعديل', 'university': 'الجامعة', 'student_id': 'الرقم الجامعي',
    'preferences': 'تفضيلات التطبيق', 'language': 'لغة التطبيق', 'language_desc': 'اختر لغة واجهة التطبيق',
    'dark_mode': 'الوضع الليلي', 'notifications': 'التنبيهات', 'notifications_desc': 'تنبيه قبل بدء المحاضرة بـ 15 دقيقة',
    'tone': 'نغمة التنبيه', 'off': 'متوقفة', 'clear_data': 'مسح كافة البيانات المخزنة', 'clear': 'مسح', 'cleared': 'تمت إعادة ضبط البيانات',
    'ask_add': 'ماذا تريد أن تضيف؟', 'new_lecture': 'محاضرة جديدة', 'new_task': 'مهمة / واجب', 'cancel': 'إلغاء', 'done': 'تم',
    'task_sheet': 'إضافة مهمة أو واجب', 'task_title': 'عنوان المهمة', 'task_type': 'نوع المهمة', 'course_name': 'اسم المادة',
    'deadline': 'موعد التسليم', 'save_task': 'حفظ المهمة',
    'lecture_add': 'إضافة محاضرة جديدة', 'lecture_edit': 'تعديل بيانات المحاضرة', 'course_code': 'رمز المادة', 'day': 'اليوم',
    'room': 'القاعة / المبنى', 'start_time': 'وقت البداية', 'end_time': 'وقت النهاية', 'professor': 'أستاذ المادة', 'color_tag': 'لون التمييز',
    'save_lecture': 'حفظ المحاضرة', 'update_lecture': 'تحديث المحاضرة',
    'edit_profile': 'تعديل ملف الطالب', 'full_name': 'اسم الطالب الكامل', 'uni_college': 'الجامعة / الكلية', 'major': 'التخصص', 'save_profile': 'حفظ البيانات',
    'delete_lecture_q': 'هل تريد حذف هذه المحاضرة؟', 'delete': 'حذف', 'required': 'هذا الحقل مطلوب',
  },
  'en': {
    'nav_home': 'Dashboard', 'nav_schedule': 'Timetable', 'nav_tasks': 'Tasks', 'nav_settings': 'Settings',
    'tagline': 'Organize your university schedule with ease',
    'welcome': 'Welcome back', 'next_lecture': 'Next Lecture', 'hrs': 'hrs', 'mins': 'mins', 'secs': 'secs',
    'today_lectures': "Today's Lectures", 'full_schedule': 'Full Timetable', 'upcoming_tasks': 'Upcoming Tasks',
    'all': 'All', 'assignments': 'Assignments', 'exams': 'Exams', 'projects': 'Projects',
    'no_lectures_day': 'No lectures for this day', 'no_lectures_today': 'No lectures today', 'no_tasks': 'No tasks found',
    'reminder': 'Reminder',
    'student_details': 'Student Details', 'edit': 'Edit', 'university': 'University', 'student_id': 'Student ID',
    'preferences': 'App Preferences', 'language': 'Language', 'language_desc': 'Select UI language',
    'dark_mode': 'Dark Mode', 'notifications': 'Notifications', 'notifications_desc': 'Alert 15 minutes before lectures',
    'tone': 'Notification Tone', 'off': 'Off', 'clear_data': 'Clear stored data', 'clear': 'Clear', 'cleared': 'Data reset successfully',
    'ask_add': 'What do you want to add?', 'new_lecture': 'New Lecture', 'new_task': 'Task / Assignment', 'cancel': 'Cancel', 'done': 'Done',
    'task_sheet': 'Add Task or Assignment', 'task_title': 'Task Title', 'task_type': 'Task Type', 'course_name': 'Course Name',
    'deadline': 'Deadline', 'save_task': 'Save Task',
    'lecture_add': 'Add New Lecture', 'lecture_edit': 'Edit Lecture Details', 'course_code': 'Course Code', 'day': 'Day',
    'room': 'Room / Building', 'start_time': 'Start Time', 'end_time': 'End Time', 'professor': 'Professor', 'color_tag': 'Color Tag',
    'save_lecture': 'Save Lecture', 'update_lecture': 'Update Lecture',
    'edit_profile': 'Edit Student Profile', 'full_name': 'Full Name', 'uni_college': 'University / College', 'major': 'Major', 'save_profile': 'Save Profile',
    'delete_lecture_q': 'Delete this lecture?', 'delete': 'Delete', 'required': 'This field is required',
  },
};
