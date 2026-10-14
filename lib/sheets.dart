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

Widget _field(TextEditingController c, String label, {String? hint, String? Function(String?)? validator}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );

Widget _actions(BuildContext context, String cancel, String save, VoidCallback onSave) => Row(children: [
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: () => Navigator.pop(context),
          child: Text(cancel),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: brand,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: onSave,
          child: Text(save, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    ]);

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
  final _code = TextEditingController();
  final _room = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _prof = TextEditingController();
  String _day = 'sun';
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
      _code.text = e.code;
      _room.text = e.room;
      _start.text = e.start;
      _end.text = e.end;
      _prof.text = e.prof;
      _day = e.day;
      final i = _colors.indexWhere((c) => c.value == e.color.value);
      _color = i < 0 ? 0 : i;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _code, _room, _start, _end, _prof]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final s = AppScope.of(context);
    final e = widget.edit;
    final name = _name.text.trim();
    s.saveLecture(Lecture(
      id: e?.id ?? DateTime.now().millisecondsSinceEpoch,
      code: _code.text.trim(),
      nameAr: s.ar ? name : (e?.nameAr ?? name),
      nameEn: s.ar ? (e?.nameEn ?? name) : name,
      day: _day,
      start: _start.text.trim(),
      end: _end.text.trim(),
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
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: _field(_name, s.t('course_name'), hint: 'Software Engineering', validator: req)),
          const SizedBox(width: 12),
          Expanded(child: _field(_code, s.t('course_code'), hint: 'SE302')),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _day,
                decoration: InputDecoration(
                  labelText: s.t('day'),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: [for (final k in dayKeys) DropdownMenuItem(value: k, child: Text(s.dayName(k)))],
                onChanged: (v) => setState(() => _day = v ?? _day),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _field(_room, s.t('room'), hint: 'Hall 304', validator: req)),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _field(_start, s.t('start_time'), hint: '10:00 AM', validator: req)),
          const SizedBox(width: 12),
          Expanded(child: _field(_end, s.t('end_time'), hint: '11:30 AM', validator: req)),
        ]),
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
  final _deadline = TextEditingController();
  TaskType _type = TaskType.assignment;

  @override
  void dispose() {
    _title.dispose();
    _course.dispose();
    _deadline.dispose();
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final s = AppScope.of(context);
    final title = _title.text.trim();
    final sub = '${_course.text.trim()} • ${_deadline.text.trim()}';
    s.addTask(Task(
      id: DateTime.now().millisecondsSinceEpoch,
      titleAr: title,
      titleEn: title,
      subAr: sub,
      subEn: sub,
      type: _type,
    ));
    Navigator.pop(context);
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<TaskType>(
                value: _type,
                decoration: InputDecoration(
                  labelText: s.t('task_type'),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: [for (final e in labels.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _field(_course, s.t('course_name'), hint: 'Software Engineering', validator: req)),
        ]),
        _field(_deadline, s.t('deadline'), hint: 'Tomorrow, 11:59 PM', validator: req),
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
