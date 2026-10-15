import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'main.dart';
import 'notification_service.dart';
import 'sheets.dart';

const brand = Color(0xFF4F46E5);

// ───────────────────────── shared widgets ─────────────────────────

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (dark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.letter, this.size = 40, this.onTap});
  final String letter;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size * .3),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(size * .3)),
        child: Text(letter, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * .4)),
      ),
    );
  }
}

class PillBar extends StatelessWidget {
  const PillBar({super.key, required this.labels, required this.selected, required this.onSelect});
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 72,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final on = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? brand : (dark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(width: 2, color: on ? brand : (dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                boxShadow: on ? [BoxShadow(color: brand.withOpacity(.3), blurRadius: 14, offset: const Offset(0, 6))] : null,
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: on ? Colors.white : (dark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyCard extends StatelessWidget {
  const EmptyCard(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(28),
        child: Center(child: Text(text, style: TextStyle(color: Theme.of(context).hintColor))),
      );
}

class LectureCard extends StatelessWidget {
  const LectureCard({super.key, required this.lecture, required this.onEdit, required this.onDelete});
  final Lecture lecture;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sub = Theme.of(context).hintColor;
    final l = lecture;

    Widget info(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: brand),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11.5, color: sub, fontWeight: FontWeight.w600)),
        ]);

    Widget action(IconData icon, VoidCallback onTap) => IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          color: sub,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dark ? const Color(0xFF334155) : const Color(0xFFE0E7FF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Container(
          color: dark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
          child: IntrinsicHeight(
            child: Row(children: [
              Container(width: 4, color: l.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(s.dayName(l.day), style: const TextStyle(color: brand, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.name(s.ar),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                      action(Icons.edit_outlined, onEdit),
                      action(Icons.delete_outline, onDelete),
                    ]),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 4,
                        children: [
                          info(Icons.schedule, s.range(l)),
                          info(Icons.place_outlined, l.room),
                          info(Icons.how_to_reg_outlined, l.prof),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, this.showDelete = true});
  final Task task;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final sub = Theme.of(context).hintColor;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(children: [
        Checkbox(value: task.done, activeColor: brand, onChanged: (_) => s.toggleTask(task)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              task.title(s.ar),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                decoration: task.done ? TextDecoration.lineThrough : null,
                color: task.done ? sub : null,
              ),
            ),
            Text('${task.course(s.ar)} • ${s.dueLabel(task.due)}',
                style: TextStyle(fontSize: 11.5, color: task.overdue ? Theme.of(context).colorScheme.error : sub)),
          ]),
        ),
        if (showDelete)
          IconButton(onPressed: () => s.deleteTask(task.id), icon: const Icon(Icons.delete_outline, size: 20), color: sub),
      ]),
    );
  }
}

// ───────────────────────── shell ─────────────────────────

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final now = DateTime.now();
    final titles = [s.t('nav_home'), s.t('nav_schedule'), s.t('nav_tasks'), s.t('nav_settings')];
    final pages = <Widget>[
      DashboardPage(onSeeSchedule: () => setState(() => _i = 1)),
      const SchedulePage(),
      const TasksPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 16,
        title: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(titles[_i], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text('${s.weekdayName(now.weekday)}، ${now.day}/${now.month}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          ]),
        ]),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: pages[_i],
      floatingActionButton: _i == 3
          ? null
          : FloatingActionButton(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              elevation: 3,
              highlightElevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              onPressed: () => showAddChooser(context),
              child: const Icon(Icons.add_rounded, size: 30),
            ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard, color: brand), label: s.t('nav_home')),
          NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), selectedIcon: const Icon(Icons.calendar_month, color: brand), label: s.t('nav_schedule')),
          NavigationDestination(icon: const Icon(Icons.checklist), selectedIcon: const Icon(Icons.checklist, color: brand), label: s.t('nav_tasks')),
          NavigationDestination(icon: const Icon(Icons.tune), selectedIcon: const Icon(Icons.tune, color: brand), label: s.t('nav_settings')),
        ],
      ),
    );
  }
}

// ───────────────────────── dashboard ─────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onSeeSchedule});
  final VoidCallback onSeeSchedule;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final sub = Theme.of(context).hintColor;
    final now = DateTime.now();

    Lecture? next;
    DateTime? at;
    for (final l in s.lectures) {
      final d = l.nextStart(now);
      if (at == null || d.isBefore(at)) {
        next = l;
        at = d;
      }
    }
    final today = s.lectures.where((l) => l.day == s.todayKey).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final pending = (s.tasks.where((t) => !t.done).toList()..sort((a, b) => a.due.compareTo(b.due))).take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      children: [
        if (next != null && at != null) _NextLectureCard(lecture: next, at: at, now: now),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.t('today_lectures'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          TextButton(onPressed: widget.onSeeSchedule, child: Text(s.t('full_schedule'))),
        ]),
        if (today.isEmpty) EmptyCard(s.t('no_lectures_today')),
        for (final l in today) ...[
          AppCard(
            child: Row(children: [
              Container(width: 4, height: 38, decoration: BoxDecoration(color: l.color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.name(s.ar), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  Text('${s.range(l)} • ${l.room}', style: TextStyle(fontSize: 11.5, color: sub)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        Text(s.t('upcoming_tasks'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (pending.isEmpty) EmptyCard(s.t('no_tasks')),
        for (final t in pending) ...[TaskTile(task: t, showDelete: false), const SizedBox(height: 10)],
      ],
    );
  }
}

class _NextLectureCard extends StatelessWidget {
  const _NextLectureCard({required this.lecture, required this.at, required this.now});
  final Lecture lecture;
  final DateTime at, now;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final diff = at.difference(now);
    String two(int n) => n.toString().padLeft(2, '0');
    Widget unit(int v, String label) => Column(children: [
          Text(two(v), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 10, fontWeight: FontWeight.w600)),
        ]);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF5B21B6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.t('next_lecture'), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(lecture.name(s.ar), style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(.15), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s.range(lecture), style: const TextStyle(color: Colors.white, fontSize: 12.5)),
            Text(lecture.room, textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
          ]),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            unit(diff.inHours, s.t('hrs')),
            unit(diff.inMinutes % 60, s.t('mins')),
            unit(diff.inSeconds % 60, s.t('secs')),
          ]),
        ),
      ]),
    );
  }
}

// ───────────────────────── schedule ─────────────────────────

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _day = 0; // 0 = all

  Future<void> _confirmDelete(Lecture l) async {
    final s = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(s.t('delete_lecture_q')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.t('cancel'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(s.t('delete'))),
        ],
      ),
    );
    if (ok == true) s.deleteLecture(l.id);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final rows = s.lectures.where((l) => _day == 0 || l.day == dayKeys[_day - 1]).toList()
      ..sort((a, b) {
        final c = dayKeys.indexOf(a.day).compareTo(dayKeys.indexOf(b.day));
        return c != 0 ? c : a.startMinutes.compareTo(b.startMinutes);
      });
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
      children: [
        PillBar(labels: [s.t('all'), ...dayKeys.map(s.dayName)], selected: _day, onSelect: (i) => setState(() => _day = i)),
        if (rows.isEmpty) EmptyCard(s.t('no_lectures_day')),
        for (final l in rows) ...[
          LectureCard(lecture: l, onEdit: () => showLectureSheet(context, edit: l), onDelete: () => _confirmDelete(l)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ───────────────────────── tasks ─────────────────────────

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int _f = 0; // 0 = all

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final types = [null, TaskType.assignment, TaskType.exam, TaskType.project];
    final rows = s.tasks.where((t) => types[_f] == null || t.type == types[_f]).toList()
      ..sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        return a.due.compareTo(b.due);
      });
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
      children: [
        PillBar(
          labels: [s.t('all'), s.t('assignments'), s.t('exams'), s.t('projects')],
          selected: _f,
          onSelect: (i) => setState(() => _f = i),
        ),
        if (rows.isEmpty) EmptyCard(s.t('no_tasks')),
        for (final t in rows) ...[TaskTile(task: t), const SizedBox(height: 10)],
      ],
    );
  }
}

// ───────────────────────── settings ─────────────────────────

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final sub = Theme.of(context).hintColor;

    Widget row(String title, {String? desc, required Widget trailing, VoidCallback? onTap, Color? color}) => AppCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                    if (desc != null) Text(desc, style: TextStyle(fontSize: 11.5, color: sub)),
                  ]),
                ),
                trailing,
              ]),
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        Text(s.t('preferences'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: sub)),
        const SizedBox(height: 8),
        row(
          s.t('language'),
          desc: s.t('language_desc'),
          trailing: SegmentedButton<String>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(value: 'ar', label: Text('العربية')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {s.lang},
            onSelectionChanged: (v) => s.setLang(v.first),
          ),
        ),
        const SizedBox(height: 10),
        row(s.t('dark_mode'), trailing: Switch(value: s.dark, onChanged: (_) => s.toggleDark())),
        const SizedBox(height: 10),
        row(s.t('notifications'), desc: s.t('notifications_desc'), trailing: Switch(value: s.notifications, onChanged: (_) => s.toggleNotifications())),
        const SizedBox(height: 10),
        Opacity(
          opacity: s.notifications ? 1 : .6,
          child: row(
            s.t('tone'),
            desc: s.notifications ? s.tones[s.tone] : s.t('off'),
            trailing: const Icon(Icons.chevron_right),
            onTap: s.notifications ? () => showToneSheet(context) : null,
          ),
        ),
        const SizedBox(height: 10),
        row(
          s.t('test_title'),
          desc: s.t('test_desc'),
          trailing: FilledButton.tonal(
            onPressed: () => NotificationService.instance.showTest(s),
            child: Text(s.t('send')),
          ),
        ),
        const SizedBox(height: 10),
        row(
          s.t('clear_data'),
          color: Theme.of(context).colorScheme.error,
          trailing: FilledButton.tonal(
            onPressed: () {
              s.reset();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('cleared'))));
            },
            child: Text(s.t('clear')),
          ),
        ),
      ],
    );
  }
}