part of 'main.dart';

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

// END OF FILE
