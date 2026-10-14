part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Timetable editor (add / edit / delete a class)
// ═══════════════════════════════════════════════════════════════════════
/// Removes [slot], re-schedules alerts and offers an Undo snackbar.
void deleteSlotWithUndo(ScaffoldMessengerState messenger, Slot slot) {
  final index = timetable.indexOf(slot);
  if (index < 0) return;
  app.update(() => timetable.removeAt(index), reschedule: true);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(tr('deleted')),
      action: SnackBarAction(
        label: tr('undo'),
        onPressed: () => app.update(
            () => timetable.insert(index.clamp(0, timetable.length).toInt(), slot),
            reschedule: true),
      ),
    ));
}

void openTimetableEditor(BuildContext context, [Slot? slot]) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => TimetableEditPage(slot: slot)));
}

class TimetableEditPage extends StatefulWidget {
  final Slot? slot;
  const TimetableEditPage({super.key, this.slot});
  @override
  State<TimetableEditPage> createState() => _TimetableEditPageState();
}

class _TimetableEditPageState extends State<TimetableEditPage> {
  static const _palette = [
    Brand.blue,
    Brand.green,
    Brand.amber,
    Brand.coral,
    Brand.cyan,
  ];

  late final TextEditingController _name;
  late final TextEditingController _place;
  late int _day;
  late Kind _kind;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late Color _color;
  late bool _weekly;
  late DateTime _date;
  late int _lead;
  bool _weeklyTouched = false;

  @override
  void initState() {
    super.initState();
    final s = widget.slot;
    _name = TextEditingController(text: s?.title.v ?? '');
    _place = TextEditingController(text: s?.place.v ?? '');
    _day = s?.weekday ?? DateTime.now().weekday;
    _kind = s?.kind ?? Kind.lecture;
    _start = s?.start ?? const TimeOfDay(hour: 8, minute: 0);
    _end = s?.end ?? const TimeOfDay(hour: 9, minute: 30);
    _color = s?.color ?? Brand.blue;
    _weekly = s == null ? true : s.date == null;
    _date = s?.date ?? DateUtils.dateOnly(DateTime.now());
    _lead = s?.lead ?? app.leadMinutes;
  }

  @override
  void dispose() {
    _name.dispose();
    _place.dispose();
    super.dispose();
  }

  String _kindLabel(Kind k) => tr(switch (k) {
        Kind.lecture => 'lecture',
        Kind.lab => 'lab',
        Kind.exam => 'exam',
        Kind.deadline => 'deadlineKind',
      });

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<TimeOfDay?> _pick(TimeOfDay initial) => showTimePicker(
        context: context,
        initialTime: initial,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: app.use24h),
          child: child!,
        ),
      );

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _snack(tr('enterName'));
      return;
    }
    final isDeadline = _kind == Kind.deadline;
    if (!isDeadline && _end.totalMinutes <= _start.totalMinutes) {
      _snack(tr('invalidTime'));
      return;
    }
    final place = _place.text.trim();
    final slot = Slot(_weekly ? _day : _date.weekday, _start,
        isDeadline ? null : _end, Bi(name, name), Bi(place, place), _kind, _color,
        date: _weekly ? null : DateUtils.dateOnly(_date), lead: _lead);
    final old = widget.slot;
    app.update(() {
      final i = old == null ? -1 : timetable.indexOf(old);
      if (i >= 0) {
        timetable[i] = slot;
      } else {
        timetable.add(slot);
      }
    }, reschedule: true);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final old = widget.slot;
    if (old == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('delete_${old.kind.name}')),
        content: Text(tr('deleteBody').replaceAll('%s', old.title.v)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('delete'),
                  style: const TextStyle(color: Brand.coral))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    deleteSlotWithUndo(messenger, old);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final editing = widget.slot != null;
    final isDeadline = _kind == Kind.deadline;

    Widget label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));

    InputDecoration deco() {
      final b = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none);
      return InputDecoration(
        filled: true,
        fillColor: p.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: b,
        enabledBorder: b,
        focusedBorder: b,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            SizedBox(
              height: 48,
              child: Row(children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                      editing
                          ? tr('edit_${_kind.name}')
                          : tr('add_${_kind.name}'),
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w700)),
                ),
                if (editing)
                  IconButton(
                    tooltip: tr('delete'),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Brand.coral),
                    onPressed: _delete,
                  ),
              ]),
            ),
            const SizedBox(height: 14),
            label(_kind == Kind.deadline ? tr('title') : tr('className')),
            TextField(
                controller: _name,
                style: const TextStyle(fontSize: 16),
                decoration: deco()),
            const SizedBox(height: 16),
            label(tr('type')),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final k in Kind.values)
                PillChip(_kindLabel(k),
                    selected: _kind == k,
                    onTap: () => setState(() {
                          _kind = k;
                          // Lectures/labs usually repeat; exams/deadlines
                          // are usually one-off (until the user decides).
                          if (!_weeklyTouched && widget.slot == null) {
                            _weekly = k == Kind.lecture || k == Kind.lab;
                          }
                        })),
            ]),
            const SizedBox(height: 16),
            AppCard(
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(children: [
                Expanded(
                    child: Text(tr('repeatWeekly'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500))),
                appSwitch(
                    _weekly,
                    (v) => setState(() {
                          _weekly = v;
                          _weeklyTouched = true;
                        })),
              ]),
            ),
            const SizedBox(height: 16),
            if (_weekly) ...[
              label(tr('day')),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < 7; i++)
                  PillChip(dayName(((weekStart - 1 + i) % 7) + 1),
                      selected: _day == ((weekStart - 1 + i) % 7) + 1,
                      onTap: () => setState(
                          () => _day = ((weekStart - 1 + i) % 7) + 1)),
              ]),
            ] else
              _PickerTile(
                label: tr('date'),
                value:
                    '${nm(_date.day)} ${monthName(_date.month)} ${nm(_date.year)}',
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035));
                  if (d != null) setState(() => _date = d);
                },
              ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _PickerTile(
                    label: tr('startTime'),
                    value: fmtTime(_start),
                    onTap: () async {
                      final t = await _pick(_start);
                      if (t != null) setState(() => _start = t);
                    }),
              ),
              if (!isDeadline) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerTile(
                      label: tr('endTime'),
                      value: fmtTime(_end),
                      onTap: () async {
                        final t = await _pick(_end);
                        if (t != null) setState(() => _end = t);
                      }),
                ),
              ],
            ]),
            const SizedBox(height: 16),
            label(tr('remindBefore')),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in const [5, 15, 30, 60])
                PillChip(leadShort(m),
                    selected: _lead == m,
                    onTap: () => setState(() => _lead = m)),
            ]),
            const SizedBox(height: 16),
            label(tr('place')),
            TextField(
                controller: _place,
                style: const TextStyle(fontSize: 16),
                decoration: deco()),
            const SizedBox(height: 16),
            label(tr('color')),
            Wrap(spacing: 12, runSpacing: 12, children: [
              for (final c in _palette)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    child: _color == c
                        ? const Icon(Icons.check_rounded, color: Colors.white)
                        : null,
                  ),
                ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder()),
                onPressed: _save,
                child: Text(tr('save_${_kind.name}'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(tr('delete'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Brand.coral,
                    side: const BorderSide(color: Brand.coral, width: 1.5),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Alert-tone picker (the phone's own notification / alarm / ringtones)
// ═══════════════════════════════════════════════════════════════════════
class TonePickerPage extends StatefulWidget {
  TonePickerPage({super.key});
  @override
  State<TonePickerPage> createState() => _TonePickerPageState();
}

class _TonePickerPageState extends State<TonePickerPage> {
  final Map<int, List<Ringtone>> _sounds = {};
  int _cat = 0;
  bool _loading = true;
  String? _playing;

  bool get _supported => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_supported) {
      try {
        _sounds[0] = await FlutterSystemRingtones.getNotificationSounds();
        _sounds[1] = await FlutterSystemRingtones.getAlarmSounds();
        _sounds[2] = await FlutterSystemRingtones.getRingtoneSounds();
      } catch (e) {
        debugPrint('Could not load system sounds: $e');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _stop() async {
    try {
      await FlutterSystemRingtones.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_supported) _stop();
    super.dispose();
  }

  Future<void> _togglePreview(Ringtone r) async {
    final id = r.uri.toString();
    try {
      if (_playing == id) {
        await _stop();
        if (mounted) setState(() => _playing = null);
      } else {
        await FlutterSystemRingtones.play(r);
        if (mounted) setState(() => _playing = id);
      }
    } catch (e) {
      debugPrint('Preview failed: $e');
    }
  }

  void _select(String? uri, String? title) {
    _stop();
    setState(() => _playing = null);
    app.update(() {
      app.toneUri = uri;
      app.toneTitle = title;
    }, reschedule: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final list = _sounds[_cat] ?? const <Ringtone>[];

    Widget tile({
      required String title,
      required bool selected,
      required VoidCallback onTap,
      Widget? leading,
    }) =>
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              color: p.surface, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: leading,
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: selected
                ? Icon(Icons.check_circle_rounded, color: checkColor(context))
                : null,
            onTap: onTap,
          ),
        );

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          tile(
            title: tr('toneDefault'),
            selected: app.toneUri == null,
            leading: Icon(Icons.notifications_active_outlined, color: p.muted),
            onTap: () => _select(null, null),
          ),
          if (!_supported)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(tr('toneIosNote'),
                  style: TextStyle(fontSize: 13, height: 1.5, color: p.muted)),
            )
          else if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                  child: Text(tr('noSounds'),
                      style: TextStyle(color: p.muted))),
            )
          else
            for (final r in list)
              tile(
                title: r.title,
                selected: app.toneUri == r.uri.toString(),
                leading: IconButton(
                  icon: Icon(_playing == r.uri.toString()
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline_rounded),
                  onPressed: () => _togglePreview(r),
                ),
                onTap: () => _select(r.uri.toString(), r.title),
              ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: SizedBox(
                height: 48,
                child: Row(children: [
                  IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(tr('tone'),
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            if (_supported)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Seg<int>(
                  items: [
                    (0, tr('toneNotif')),
                    (1, tr('toneAlarm')),
                    (2, tr('toneRing')),
                  ],
                  value: _cat,
                  onChanged: (v) {
                    _stop();
                    setState(() {
                      _cat = v;
                      _playing = null;
                    });
                  },
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
