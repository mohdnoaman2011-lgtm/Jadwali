part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Settings
// ═══════════════════════════════════════════════════════════════════════
class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);

    Widget card(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SizedBox(
            width: double.infinity,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  child,
                ],
              ),
            ),
          ),
        );

    Widget row(String label, Widget trailing,
            {VoidCallback? onTap, bool first = false}) =>
        InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              border: first
                  ? null
                  : Border(top: BorderSide(color: p.soft, width: 1)),
            ),
            child: Row(children: [
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500))),
              trailing,
            ]),
          ),
        );

    Widget value(String s) =>
        Text(s, style: TextStyle(fontSize: 14, color: p.muted));

    Widget toggle(bool v, ValueChanged<bool> on) =>
        appSwitch(v, on);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        PageHeader(tr('settings')),
        const SizedBox(height: 14),
        card(
          tr('appearance'),
          Seg<ThemeMode>(
            items: [
              (ThemeMode.light, tr('light')),
              (ThemeMode.dark, tr('dark')),
              (ThemeMode.system, tr('auto')),
            ],
            value: app.themeMode,
            onChanged: (m) => app.update(() => app.themeMode = m),
          ),
        ),
        card(
          tr('language'),
          // Same style as the Vibration row: ON = English, OFF = Arabic.
          row(
            'English',
            toggle(
              !app.isAr,
              (v) => app.update(
                  () => app.locale = v ? const Locale('en') : const Locale('ar'),
                  reschedule: true),
            ),
            first: true,
          ),
        ),
        card(
          tr('timeFormat'),
          Seg<bool>(
            items: [(false, tr('h12')), (true, tr('h24'))],
            value: app.use24h,
            onChanged: (v) => app.update(() => app.use24h = v),
          ),
        ),
        card(
          tr('alertSettings'),
          Column(children: [
            row(tr('leadTime'), value(leadLong(app.leadMinutes)),
                first: true,
                onTap: () => _choose<int>(
                    context,
                    tr('leadTime'),
                    [for (final m in const [5, 10, 15, 30, 60]) (m, leadLong(m))],
                    app.leadMinutes,
                    (m) => app.update(() => app.leadMinutes = m,
                        reschedule: true))),
            row(
                tr('tone'),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(app.toneTitle ?? tr('toneDefault'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: p.muted)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: p.muted),
                ]),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TonePickerPage()))),
            row(tr('vibration'),
                toggle(app.vibrate,
                    (v) => app.update(() => app.vibrate = v, reschedule: true))),
            row(tr('snooze'),
                toggle(app.snooze, (v) => app.update(() => app.snooze = v))),
            row(
                tr('deadlineAlerts'),
                toggle(
                    app.deadlineAlerts,
                    (v) => app.update(() => app.deadlineAlerts = v,
                        reschedule: true))),
            row(tr('testAlert'),
                Icon(Icons.notifications_active_outlined, color: p.muted),
                onTap: () async {
              await Notifier.test();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(tr('testSent'))));
              }
            }),
          ]),
        ),
      ],
    );
  }

  void _choose<T>(BuildContext context, String title, List<(T, String)> options,
      T current, ValueChanged<T> onPick) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
            for (final o in options)
              ListTile(
                title: Text(o.$2),
                trailing: o.$1 == current
                    ? Icon(Icons.check_rounded, color: checkColor(ctx))
                    : null,
                onTap: () {
                  onPick(o.$1);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Alert screen (shown when a reminder fires)
// ═══════════════════════════════════════════════════════════════════════
class AlertPage extends StatelessWidget {
  final Slot slot;
  final int lead;
  const AlertPage({super.key, required this.slot, required this.lead});

  @override
  Widget build(BuildContext context) {
    const mutedOnNavy = Color(0xFFBFD3F0);
    final range = slot.end == null
        ? fmtTime(slot.start)
        : '${fmtTime(slot.start)} – ${fmtTime(slot.end!)}';

    Widget tag(String s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFE7ECF4),
              borderRadius: BorderRadius.circular(14)),
          child: Text(s,
              style: const TextStyle(fontSize: 13, color: Brand.navy)),
        );

    return Scaffold(
      backgroundColor: Brand.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('classAlert'),
                      style:
                          const TextStyle(fontSize: 14, color: mutedOnNavy)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Brand.cyan,
                        borderRadius: BorderRadius.circular(14)),
                    child: Text(tr('now'),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Brand.navy)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: 220,
                        height: 220,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0x125BC0E0))),
                    Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0x245BC0E0))),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Brand.cyan),
                      child: const Icon(Icons.notifications_none_rounded,
                          size: 44, color: Brand.navy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(inMinutes(lead),
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Brand.cyan)),
              const SizedBox(height: 6),
              Text(tr('getReady'),
                  style: const TextStyle(fontSize: 15, color: mutedOnNavy)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot.title.v,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Brand.navy)),
                    const SizedBox(height: 8),
                    Text([range, if (slot.place.v.isNotEmpty) slot.place.v].join(' · '),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF5B6B86))),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      tag(tr(switch (slot.kind) {
                        Kind.exam => 'exam',
                        Kind.deadline => 'assignment',
                        Kind.lab => 'lab',
                        _ => 'lecture',
                      })),
                    ]),
                  ],
                ),
              ),
              const Spacer(),
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFF4A6AA3), width: 1.5),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: app.snooze
                          ? () {
                              Notifier.snooze(slot);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text(tr('snoozeBtn'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Brand.cyan,
                          foregroundColor: Brand.navy,
                          shape: const StadiumBorder()),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(tr('gotIt'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: mutedOnNavy,
                    minimumSize: const Size.fromHeight(44)),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(tr('viewSchedule')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
