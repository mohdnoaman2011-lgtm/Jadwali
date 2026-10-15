import 'package:flutter/material.dart';

import 'app_state.dart';
import 'main.dart';
import 'screens.dart';

Future<void> _openSheet(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, 20 + MediaQuery.of(c).viewInsets.bottom),
      child: SingleChildScrollView(child: builder(c)),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ]),
        const Divider(height: 1),
        const SizedBox(height: 14),
      ]);
}

Widget _labeled(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        child,
      ]),
    );

InputDecoration _dec(BuildContext c, {String? hint}) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(c).brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(c).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(c).dividerColor),
      ),
    );

Widget _field(TextEditingController c, String label, {String? hint, String? Function(String?)? validator}) =>
    Builder(builder: (ctx) => _labeled(label, TextFormField(controller: c, validator: validator, decoration: _dec(ctx, hint: hint))));

Widget _actions(BuildContext context, String cancel, String save, VoidCallback onSave) => Column(children: [
      SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          onPressed: onSave,
          child: Text(save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: double.infinity,
        height: 44,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancel, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    ]);

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.minutes, required this.onPicked});
  final String label;
  final int minutes;
  final ValueChanged<int> onPicked;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return _labeled(
      label,
      InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final t = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
            helpText: label,
          );
          if (t != null) onPicked(t.hour * 60 + t.minute);
        },
        child: InputDecorator(
          decoration: _dec(context),
          child: Row(children: [
            Expanded(child: Text(s.time(minutes), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            Icon(Icons.schedule, size: 18, color: Theme.of(context).hintColor),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── add chooser ─────────────────────────

void showAddChooser(BuildContext context) {
  _openSheet(context, (c) {
    final s = AppScope.of(c);
    Widget tile(IconData icon, Color color, String label, VoidCallback onTap) => Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(.35)),
              ),
              child: Column(children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 10),
                Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
              ]),
            ),
          ),
        );
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(s.t('ask_add'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      Row(children: [
        tile(Icons.menu_book_outlined, brand, s.t('new_lecture'), () {
          Navigator.pop(c);
          showLectureSheet(context);
        }),
        const SizedBox(width: 12),
        tile(Icons.check_box_outlined, const Color(0xFFD97706), s.t('new_task'), () {
          Navigator.pop(c);
          showTaskSheet(context);
        }),
      ]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(c), child: Text(s.t('cancel')))),
    ]);
  });
}

// ───────────────────────── lecture (add / edit) ─────────────────────────

void showLectureSheet(BuildContext context, {Lecture? edit}) =>
    _openSheet(context, (_) => _LectureForm(edit: edit));

class _LectureForm extends StatefulWidget {
  const _LectureForm({this.edit});
  final Lecture? edit;

  @override
  State<_LectureForm> createState() => _LectureFormState();
}

class _LectureFormState extends State<_LectureForm> {
  static const _colors = [Color(0xFF4F46E5), Color(0xFF059669), Color(0xFFF59E0B), Color(0xFFE11D48)];

  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _room = TextEditingController();
  final _prof = TextEditingController();
  String _day = 'sun';
  int _startMin = 8 * 60;
  int _endMin = 9 * 60 + 30;
  String? _timeError;
  int _color = 0;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final e = widget.edit;
    if (e != null) {
      final s = AppScope.of(context);
      _name.text = e.name(s.ar);
      _room.text = e.room;
      _startMin = e.startMin;
      _endMin = e.endMin;
      _prof.text = e.prof;
      _day = e.day;
      final i = _colors.indexWhere((c) => c.value == e.color.value);
      _color = i < 0 ? 0 : i;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _room, _prof]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final s = AppScope.of(context);
    if (_endMin <= _startMin) {
      setState(() => _timeError = s.t('end_after_start'));
      return;
    }
    final e = widget.edit;
    final name = _name.text.trim();
    s.saveLecture(Lecture(
      id: e?.id ?? DateTime.now().millisecondsSinceEpoch,
      nameAr: s.ar ? name : (e?.nameAr ?? name),
      nameEn: s.ar ? (e?.nameEn ?? name) : name,
      day: _day,
      startMin: _startMin,
      endMin: _endMin,
      room: _room.text.trim(),
      prof: _prof.text.trim(),
      color: _colors[_color],
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    String? req(String? v) => (v == null || v.trim().isEmpty) ? s.t('required') : null;
    return Form(
      key: _key,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SheetHeader(widget.edit == null ? s.t('lecture_add') : s.t('lecture_edit')),
        _field(_name, s.t('course_name'), hint: 'Software Engineering', validator: req),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _labeled(
s.t('day'),
 DropdownButtonFormField<String>(
 isExpanded: true,
 value: _day,
 decoration: _dec(context),
                items: [for (final k in dayKeys) DropdownMenuItem(value: k, child: Text(s.dayName(k)))],
                onChanged: (v) => setState(() => _day = v ?? _day),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _field(_room, s.t('room'), hint: 'Hall 304', validator: req)),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _TimeField(
              label: s.t('start_time'),
              minutes: _startMin,
              onPicked: (v) => setState(() {
                _startMin = v;
                if (_endMin <= v) _endMin = (v + 90).clamp(0, 24 * 60 - 1).toInt();
                _timeError = null;
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TimeField(
              label: s.t('end_time'),
              minutes: _endMin,
              onPicked: (v) => setState(() {
                _endMin = v;
                _timeError = null;
              }),
            ),
          ),
        ]),
        if (_timeError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_timeError!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error)),
          ),
        _field(_prof, s.t('professor'), hint: 'Dr. Ahmed', validator: req),
        Text(s.t('color_tag'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(children: [
          for (var i = 0; i < _colors.length; i++)
            GestureDetector(
              onTap: () => setState(() => _color = i),
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsetsDirectional.only(end: 14),
                decoration: BoxDecoration(
                  color: _colors[i],
                  shape: BoxShape.circle,
                  boxShadow: i == _color ? [BoxShadow(color: _colors[i].withOpacity(.35), spreadRadius: 4)] : null,
                ),
              ),
            ),
        ]),
        const SizedBox(height: 18),
        _actions(context, s.t('cancel'), widget.edit == null ? s.t('save_lecture') : s.t('update_lecture'), _save),
      ]),
    );
  }
}

// ───────────────────────── task ─────────────────────────

void showTaskSheet(BuildContext context) => _openSheet(context, (_) => const _TaskForm());

class _TaskForm extends StatefulWidget {
  const _TaskForm();

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _course = TextEditingController();
  TaskType _type = TaskType.assignment;
  DateTime? _date;
  int _dueMin = 23 * 60 + 59; // default: end of day
  String? _dueError;

  @override
  void dispose() {
    _title.dispose();
    _course.dispose();
    super.dispose();
  }

  void _save() {
    final valid = _key.currentState!.validate();
    final msg = AppScope.of(context);
    if (_date == null) {
      setState(() => _dueError = msg.t('required'));
      return;
    }
    final due = DateTime(_date!.year, _date!.month, _date!.day, _dueMin ~/ 60, _dueMin % 60);
    if (due.isBefore(DateTime.now())) {
      setState(() => _dueError = msg.t('past_deadline'));
      return;
    }
    if (!valid) return;
    final s = AppScope.of(context);
    final title = _title.text.trim();
    final course = _course.text.trim();
    s.addTask(Task(
      id: DateTime.now().millisecondsSinceEpoch,
      titleAr: title,
      titleEn: title,
      courseAr: course,
      courseEn: course,
      due: due,
      type: _type,
    ));
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) setState(() {
      _date = d;
      _dueError = null;
    });
  }

  void _quick(int days) {
    final n = DateTime.now();
    setState(() {
      _date = DateTime(n.year, n.month, n.day + days);
      _dueError = null;
    });
  }

  bool _isInDays(int days) {
    if (_date == null) return false;
    final n = DateTime.now();
    final t = DateTime(n.year, n.month, n.day + days);
    return _date!.year == t.year && _date!.month == t.month && _date!.day == t.day;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    String? req(String? v) => (v == null || v.trim().isEmpty) ? s.t('required') : null;
    final labels = {
      TaskType.assignment: s.t('assignments'),
      TaskType.exam: s.t('exams'),
      TaskType.project: s.t('projects'),
    };
    return Form(
      key: _key,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SheetHeader(s.t('task_sheet')),
        _field(_title, s.t('task_title'), hint: 'Submit Project', validator: req),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _labeled(
s.t('task_type'),
 DropdownButtonFormField<TaskType>(
 isExpanded: true,
 value: _type,
 decoration: _dec(context),
                items: [for (final e in labels.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _field(_course, s.t('course_name'), hint: 'Software Engineering', validator: req)),
        ]),
        Text(s.t('deadline'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final q in [(s.t('today'), 0), (s.t('tomorrow'), 1), (s.t('in_week'), 7)])
            ChoiceChip(
              label: Text(q.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              selected: _isInDays(q.$2),
              selectedColor: brand.withOpacity(.15),
              onSelected: (_) => _quick(q.$2),
            ),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 3,
            child: _labeled(
              s.t('date'),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _dec(context).copyWith(errorText: _dueError, errorMaxLines: 2),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        _date == null ? s.t('pick_date') : s.dayLabel(_date!),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _date == null ? Theme.of(context).hintColor : null,
                        ),
                      ),
                    ),
                    Icon(Icons.event, size: 18, color: Theme.of(context).hintColor),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _TimeField(
              label: s.t('time'),
              minutes: _dueMin,
              onPicked: (v) => setState(() {
                _dueMin = v;
                _dueError = null;
              }),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        _actions(context, s.t('cancel'), s.t('save_task'), _save),
      ]),
    );
  }
}

// ───────────────────────── profile ─────────────────────────

void showProfileSheet(BuildContext context) => _openSheet(context, (_) => const _ProfileForm());

class _ProfileForm extends StatefulWidget {
  const _ProfileForm();

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _uni = TextEditingController();
  final _major = TextEditingController();
  final _id = TextEditingController();
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final p = AppScope.of(context).profile;
    _name.text = p.name;
    _uni.text = p.university;
    _major.text = p.major;
    _id.text = p.studentId;
  }

  @override
  void dispose() {
    for (final c in [_name, _uni, _major, _id]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    AppScope.of(context).updateProfile(Profile(
      name: _name.text.trim(),
      university: _uni.text.trim(),
      major: _major.text.trim(),
      studentId: _id.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    String? req(String? v) => (v == null || v.trim().isEmpty) ? s.t('required') : null;
    return Form(
      key: _key,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SheetHeader(s.t('edit_profile')),
        _field(_name, s.t('full_name'), validator: req),
        _field(_uni, s.t('uni_college'), validator: req),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _field(_major, s.t('major'), validator: req)),
          const SizedBox(width: 12),
          Expanded(child: _field(_id, s.t('student_id'), validator: req)),
        ]),
        const SizedBox(height: 6),
        _actions(context, s.t('cancel'), s.t('save_profile'), _save),
      ]),
    );
  }
}

// ───────────────────────── notification tone ─────────────────────────

void showToneSheet(BuildContext context) {
  _openSheet(context, (c) {
    final s = AppScope.of(c);
    return ListenableBuilder(
      listenable: s,
      builder: (_, __) => Column(mainAxisSize: MainAxisSize.min, children: [
        _SheetHeader(s.t('tone')),
        for (var i = 0; i < s.tones.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => s.setTone(i),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: i == s.tone ? brand.withOpacity(.12) : null,
                  border: Border.all(width: 2, color: i == s.tone ? brand : Theme.of(c).dividerColor),
                ),
                child: Row(children: [
                  Expanded(child: Text(s.tones[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                  Icon(i == s.tone ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: i == s.tone ? brand : Theme.of(c).hintColor),
                ]),
              ),
            ),
          ),
        const SizedBox(height: 8),
        _actions(c, s.t('cancel'), s.t('done'), () => Navigator.pop(c)),
      ]),
    );
  });
}
