part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Today
// ═══════════════════════════════════════════════════════════════════════
class TodayPage extends StatefulWidget {
  TodayPage({super.key});
  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  DateTime _selected = DateUtils.dateOnly(DateTime.now());

  List<DateTime> _weekDays() {
    final today = DateUtils.dateOnly(DateTime.now());
    final diff = (today.weekday - weekStart) % 7;
    final first = today.subtract(Duration(days: diff));
    return List.generate(7, (i) => first.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final isToday = _selected == today;
    final nowMin = TimeOfDay.now().totalMinutes;

    final all = slotsForDate(_selected);
    final upcoming =
        isToday ? all.where((s) => s.start.totalMinutes > nowMin).toList() : all;
    Slot? next;
    for (final s in upcoming) {
      if (s.kind != Kind.deadline) {
        next = s;
        break;
      }
    }
    final nextSlot = next;
    final rest = all.where((s) => s != nextSlot).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        PageHeader(dateLabel(_selected)),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final d in _weekDays())
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 64,
                      decoration: BoxDecoration(
                        color: d == _selected ? p.primary : p.surface,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(dayName(d.weekday),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: d == _selected
                                        ? Colors.white
                                        : p.muted)),
                          ),
                          const SizedBox(height: 4),
                          Text(nm(d.day),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: d == _selected
                                      ? Colors.white
                                      : p.text)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (nextSlot != null)
          _NextClassCard(
              slot: nextSlot,
              minutesAway: isToday ? nextSlot.start.totalMinutes - nowMin : null)
        else
          AppCard(
            radius: 28,
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(all.isEmpty ? tr('noClasses') : tr('doneToday'),
                    style: TextStyle(color: p.muted, fontSize: 15))),
          ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(nextSlot != null ? tr('restOfDay') : tr('daySchedule'),
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          for (final s in rest) ...[
            Opacity(
              opacity: (isToday && s.start.totalMinutes <= nowMin) ? 0.5 : 1,
              child: GestureDetector(
                  onTap: () => openTimetableEditor(context, s),
                  child: TimelineRow(label: fmtTime(s.start), slot: s)),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _NextClassCard extends StatelessWidget {
  final Slot slot;
  final int? minutesAway;
  const _NextClassCard({required this.slot, this.minutesAway});

  @override
  Widget build(BuildContext context) {
    final chip = minutesAway == null
        ? tr('nextClass')
        : '${tr('nextClass')} · ${inMinutes(minutesAway!)}';
    final range = slot.end == null
        ? fmtTime(slot.start)
        : '${fmtTime(slot.start)} – ${fmtTime(slot.end!)}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Brand.blue, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Brand.cyan, borderRadius: BorderRadius.circular(14)),
            child: Text(chip,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Brand.navy)),
          ),
          const SizedBox(height: 10),
          Text(slot.title.v,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text([if (slot.place.v.isNotEmpty) slot.place.v, range].join(' · '),
              style: const TextStyle(fontSize: 14, color: Color(0xE6FFFFFF))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Brand.navy,
                  shape: const StadiumBorder()),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      AlertPage(slot: slot, lead: app.leadMinutes))),
              child: Text(
                  app.isAr
                      ? 'ذكّرني قبل ${nm(app.leadMinutes)} دقيقة'
                      : 'Remind me ${app.leadMinutes} min before',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Weekly schedule (week list + month grid)
// ═══════════════════════════════════════════════════════════════════════
class SchedulePage extends StatefulWidget {
  SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _month = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        PageHeader(
          tr('schedule'),
          trailing: SizedBox(
            width: 140,
            child: Seg<bool>(
              items: [(false, tr('week')), (true, tr('month'))],
              value: _month,
              onChanged: (v) => setState(() => _month = v),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => openTimetableEditor(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(tr('addClass')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Pal.of(context).text,
              side: BorderSide(color: Pal.of(context).soft, width: 1.5),
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_month) const _MonthGrid() else ..._weekRows(),
      ],
    );
  }

  List<Widget> _weekRows() {
    final today = DateUtils.dateOnly(DateTime.now());
    final first = today.subtract(Duration(days: (today.weekday - weekStart) % 7));
    final dates = List.generate(7, (i) => first.add(Duration(days: i)));
    return [
      if (timetable.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Center(child: Text(tr('noClasses'))),
        ),
      for (final d in dates)
        if (slotsForDate(d).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 68,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text('${dayName(d.weekday)}\n${nm(d.day)}',
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: Pal.of(context).muted)),
                  ),
                ),
                Expanded(
                  child: Column(children: [
                    for (final s in slotsForDate(d))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SlotCard(slot: s),
                      ),
                  ]),
                ),
              ],
            ),
          ),
    ];
  }
}

class _SlotCard extends StatelessWidget {
  final Slot slot;
  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final sub = [
      if (slot.date != null)
        '${nm(slot.date!.day)} ${monthName(slot.date!.month)}',
      fmtTime(slot.start),
      if (slot.place.v.isNotEmpty) slot.place.v,
    ].join(' · ');
    final messenger = ScaffoldMessenger.of(context);
    Widget swipeBg(AlignmentGeometry align) => Container(
          alignment: align,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
              color: Brand.coral, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        );
    return Dismissible(
      key: ObjectKey(slot),
      direction: DismissDirection.horizontal,
      background: swipeBg(AlignmentDirectional.centerStart),
      secondaryBackground: swipeBg(AlignmentDirectional.centerEnd),
      onDismissed: (_) => deleteSlotWithUndo(messenger, slot),
      child: GestureDetector(
      onTap: () => openTimetableEditor(context, slot),
      child: SizedBox(
      width: double.infinity,
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: slot.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slot.title.v,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(fontSize: 13, color: p.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}

class _MonthGrid extends StatefulWidget {
  const _MonthGrid();
  @override
  State<_MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<_MonthGrid> {
  DateTime _sel = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final offset = (first.weekday - weekStart) % 7;
    final days = DateUtils.getDaysInMonth(now.year, now.month);
    final headers = List.generate(7, (i) => ((weekStart - 1 + i) % 7) + 1);
    final selected = slotsForDate(_sel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            children: [
              Text('${monthName(now.month)} ${nm(now.year)}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                for (final h in headers)
                  Expanded(
                      child: Center(
                          child: Text(dayShort(h),
                              style:
                                  TextStyle(fontSize: 11, color: p.muted)))),
              ]),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9,
                children: [
                  for (var i = 0; i < offset; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= days; d++)
                    _dayCell(DateTime(now.year, now.month, d), now),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(dateLabel(_sel),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (selected.isEmpty)
          Text(tr('noClasses'), style: TextStyle(color: p.muted, fontSize: 14))
        else
          for (final s in selected)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SlotCard(slot: s),
            ),
      ],
    );
  }

  Widget _dayCell(DateTime date, DateTime now) {
    final p = Pal.of(context);
    final isToday = DateUtils.isSameDay(date, now);
    final isSel = DateUtils.isSameDay(date, _sel);
    final hasSlots = slotsForDate(date).isNotEmpty;
    return GestureDetector(
      onTap: () => setState(() => _sel = date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? p.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSel && !isToday
              ? Border.all(color: p.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(nm(date.day),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isToday ? Colors.white : p.text)),
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasSlots
                    ? (isToday ? Brand.cyan : Brand.green)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Shared picker tile
// ═══════════════════════════════════════════════════════════════════════
class _PickerTile extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  const _PickerTile(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: p.muted)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
