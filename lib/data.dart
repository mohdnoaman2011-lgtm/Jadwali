part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Sample timetable
// ═══════════════════════════════════════════════════════════════════════
enum Kind { lecture, lab, exam, deadline }

class Slot {
  final int weekday; // DateTime.monday … DateTime.sunday
  final TimeOfDay start;
  final TimeOfDay? end;
  final Bi title;
  final Bi place;
  final Kind kind;
  final Color color;

  /// null = repeats every week on [weekday]; otherwise a one-off on this date.
  final DateTime? date;

  /// Minutes to alert before the start; null = use the app default.
  final int? lead;

  const Slot(this.weekday, this.start, this.end, this.title, this.place,
      this.kind, this.color,
      {this.date, this.lead});

  bool get weekly => date == null;

  Map<String, dynamic> toJson() => {
        'wd': weekday,
        'sh': start.hour,
        'sm': start.minute,
        'eh': end?.hour,
        'em': end?.minute,
        'ta': title.ar,
        'te': title.en,
        'pa': place.ar,
        'pe': place.en,
        'k': kind.index,
        'c': color.toARGB32(),
        'd': date?.toIso8601String(),
        'ld': lead,
      };

  factory Slot.fromJson(Map<String, dynamic> j) => Slot(
        j['wd'] as int,
        TimeOfDay(hour: j['sh'] as int, minute: j['sm'] as int),
        j['eh'] == null
            ? null
            : TimeOfDay(hour: j['eh'] as int, minute: j['em'] as int),
        Bi(j['ta'] as String, j['te'] as String),
        Bi(j['pa'] as String, j['pe'] as String),
        Kind.values[(j['k'] as int).clamp(0, 3).toInt()],
        Color(j['c'] as int),
        date: j['d'] == null ? null : DateTime.parse(j['d'] as String),
        lead: j['ld'] as int?,
      );
}

final timetable = <Slot>[
  const Slot(DateTime.sunday, TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 9, minute: 30), Bi('الخوارزميات', 'Algorithms'),
      Bi('قاعة C-301', 'Room C-301'), Kind.lecture, Brand.blue),
  const Slot(DateTime.monday, TimeOfDay(hour: 11, minute: 30),
      TimeOfDay(hour: 13, minute: 0),
      Bi('الإحصاء الهندسي', 'Engineering Statistics'),
      Bi('قاعة A-110', 'Room A-110'), Kind.lecture, Brand.green),
  const Slot(DateTime.tuesday, TimeOfDay(hour: 9, minute: 30),
      TimeOfDay(hour: 11, minute: 0), Bi('هياكل البيانات', 'Data Structures'),
      Bi('قاعة B-204', 'Room B-204'), Kind.lecture, Brand.blue),
  const Slot(DateTime.tuesday, TimeOfDay(hour: 11, minute: 30),
      TimeOfDay(hour: 13, minute: 0),
      Bi('الإحصاء الهندسي', 'Engineering Statistics'),
      Bi('قاعة A-110', 'Room A-110'), Kind.lecture, Brand.green),
  const Slot(DateTime.tuesday, TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 16, minute: 0), Bi('مختبر الفيزياء', 'Physics Lab'),
      Bi('المختبر ٣', 'Lab 3'), Kind.lab, Brand.amber),
  const Slot(DateTime.tuesday, TimeOfDay(hour: 23, minute: 59), null,
      Bi('تسليم واجب الخوارزميات', 'Algorithms assignment due'),
      Bi('موعد نهائي اليوم', 'Deadline today'), Kind.deadline, Brand.coral),
  const Slot(DateTime.wednesday, TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 16, minute: 0), Bi('مختبر الفيزياء', 'Physics Lab'),
      Bi('المختبر ٣', 'Lab 3'), Kind.lab, Brand.amber),
  const Slot(DateTime.thursday, TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 12, minute: 0), Bi('امتحان منتصف الفصل', 'Midterm exam'),
      Bi('القاعة الكبرى', 'Main Hall'), Kind.exam, Brand.coral),
];

/// Classes/exams/deadlines that happen on [d]: weekly ones for that weekday
/// plus one-offs dated exactly [d], sorted by start time.
List<Slot> slotsForDate(DateTime d) {
  final day = DateUtils.dateOnly(d);
  final list = timetable
      .where((s) => s.date == null
          ? s.weekday == day.weekday
          : DateUtils.isSameDay(s.date!, day))
      .toList()
    ..sort((a, b) => a.start.totalMinutes.compareTo(b.start.totalMinutes));
  return list;
}

/// First day of the week: Saturday in Arabic, Sunday in English.
int get weekStart => app.isAr ? DateTime.saturday : DateTime.sunday;
