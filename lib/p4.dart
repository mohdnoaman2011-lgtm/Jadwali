part of 'main.dart';

// ───────────────────────── نغمة التنبيه ─────────────────────────

class SoundPage extends StatelessWidget {
  const SoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);

    Widget radio(bool on) => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? p.pri : p.sw, width: 2)),
          child: on ? Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(color: p.pri, shape: BoxShape.circle))) : null,
        );

    Widget option({required bool selected, required String title, required String sub, required VoidCallback onTap, Widget? trailing}) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              radio(selected),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(sub, style: TextStyle(fontSize: 13.5, color: p.muted)),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      );
    }

    final durOptions = <int, String>{1: a.t('min1'), 5: a.t('min5'), 10: a.t('min10'), 0: a.t('untilStop')};

    return Scaffold(
      appBar: AppBar(title: Text(a.t('soundTitle'), style: const TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                option(
                  selected: a.soundMode == 'default',
                  title: a.t('phoneDefault'),
                  sub: a.t('phoneDefaultSub'),
                  onTap: () => a.update(() => a.soundMode = 'default'),
                ),
                Divider(height: 1, color: p.line),
                option(
                  selected: a.soundMode == 'custom',
                  title: a.t('pickFromPhone'),
                  sub: a.toneTitle.isNotEmpty ? a.toneTitle : a.t('pickFromPhoneSub'),
                  onTap: () async {
                    if (a.toneUri.isEmpty) {
                      await pickRingtone(a);
                    } else {
                      await a.update(() => a.soundMode = 'custom');
                    }
                  },
                  trailing: PillChip(label: a.t('chooseTone'), selected: false, onTap: () => pickRingtone(a)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBox(icon: Icons.repeat),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.t('continuous'), style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(a.t('continuousSub'), style: TextStyle(fontSize: 13.5, color: p.muted)),
                        ],
                      ),
                    ),
                    Switch(value: a.continuous, onChanged: (v) => a.update(() => a.continuous = v)),
                  ],
                ),
                if (a.continuous) ...[
                  const SizedBox(height: 14),
                  Text(a.t('repeatFor'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.muted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final e in durOptions.entries) PillChip(label: e.value, selected: a.repeatMin == e.key, onTap: () => a.update(() => a.repeatMin = e.key))],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Row(
              children: [
                const IconBox(icon: Icons.vibration),
                const SizedBox(width: 12),
                Expanded(child: Text(a.t('vibrate'), style: const TextStyle(fontWeight: FontWeight.w600))),
                Switch(value: a.vibrate, onChanged: (v) => a.update(() => a.vibrate = v)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            children: [
              Expanded(child: AppButton(label: a.t('preview'), icon: Icons.play_arrow_rounded, kind: BtnKind.soft, onTap: () => previewAlert(a))),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: a.t('save'),
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await rescheduleAll(a);
                    if (context.mounted) showToast(context, a.t('saved'));
                    nav.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── الإعدادات ─────────────────────────

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);

    Widget sec(String s) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
          child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.muted)),
        );

    Widget lbl(String s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.muted)),
        );

    Widget row(IconData icon, String title, {String? value, Color? color, Color? iconBg, VoidCallback? onTap, bool chevron = true}) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              IconBox(icon: icon, bg: iconBg, fg: color),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? p.text))),
              if (value != null) Text(value, style: TextStyle(color: p.muted, fontSize: 13.5)),
              if (chevron && onTap != null) ...[const SizedBox(width: 4), Icon(Icons.chevron_right, color: p.muted)],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTop(title: a.t('settings')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              sec(a.t('appearance')),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    lbl(a.t('appearance')),
                    Seg<ThemeMode>(
                      items: {ThemeMode.light: a.t('light'), ThemeMode.dark: a.t('dark'), ThemeMode.system: a.t('system')},
                      value: a.themeMode,
                      onChanged: (v) => a.update(() => a.themeMode = v),
                    ),
                    const SizedBox(height: 14),
                    lbl(a.t('language')),
                    Seg<String>(
                      items: const {'ar': 'العربية', 'en': 'English'},
                      value: a.lang,
                      onChanged: (v) async {
                        await a.update(() => a.lang = v);
                        await rescheduleAll(a);
                      },
                    ),
                    const SizedBox(height: 14),
                    lbl(a.t('timeFormat')),
                    Seg<bool>(
                      items: {false: a.t('h12'), true: a.t('h24')},
                      value: a.use24,
                      onChanged: (v) async {
                        await a.update(() => a.use24 = v);
                        await rescheduleAll(a);
                      },
                    ),
                  ],
                ),
              ),
              sec(a.t('alerts')),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    row(Icons.music_note_outlined, a.t('soundRow'), value: a.toneName, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SoundPage()))),
                    Divider(height: 24, color: p.line),
                    lbl(a.t('defBefore')),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final m in [5, 10, 15, 30]) PillChip(label: a.minLabel(m), selected: a.defBefore == m, onTap: () => a.update(() => a.defBefore = m))],
                    ),
                  ],
                ),
              ),
              sec(a.t('data')),
              AppCard(
                child: Column(
                  children: [
                    row(Icons.menu_book_outlined, a.t('subjects'), value: '${a.subjects.length}', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SubjectsPage()))),
                    Divider(height: 24, color: p.line),
                    row(Icons.delete_outline, a.t('clearAll'), color: p.red, iconBg: p.redSoft, chevron: false, onTap: () async {
                      final ok = await confirmSheet(context, title: a.t('clearQ'), sub: a.t('clearD'), yes: a.t('yesClear'), no: a.t('cancel'));
                      if (!ok) return;
                      await plugin.cancelAll();
                      await a.update(() {
                        a.lectures.clear();
                        a.reminders.clear();
                      });
                      if (context.mounted) showToast(context, a.t('cleared'));
                    }),
                  ],
                ),
              ),
              sec(a.t('about')),
              AppCard(child: row(Icons.info_outline, a.t('app'), value: a.t('version'), chevron: false)),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── المواد الدراسية ─────────────────────────

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final ctl = TextEditingController();

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  Future<void> _add(AppState a) async {
    final name = ctl.text.trim();
    if (name.isEmpty) {
      showToast(context, a.t('required'));
      return;
    }
    if (a.subjects.any((s) => s.name == name)) {
      ctl.clear();
      return;
    }
    await a.update(() => a.subjects.add(Subject(name: name, color: a.subjects.length % kSubjectColors.length)));
    ctl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(a.t('subjects'), style: const TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(a),
                  decoration: InputDecoration(
                    hintText: a.t('subjNew'),
                    filled: true,
                    fillColor: p.card,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: p.line)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(width: 96, child: AppButton(label: a.t('subjAdd'), onTap: () => _add(a))),
            ],
          ),
          const SizedBox(height: 14),
          for (final s in a.subjects.toList())
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
                child: Row(
                  children: [
                    SubjectDot(color: kSubjectColors[s.color % kSubjectColors.length], size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${a.lectures.where((l) => l.subject == s.name).length} ${a.t('lecN')}', style: TextStyle(fontSize: 13, color: p.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: a.t('delete'),
                      icon: Icon(Icons.delete_outline, color: p.red),
                      onPressed: () async {
                        if (a.lectures.any((l) => l.subject == s.name)) {
                          showToast(context, a.t('subjUsed'));
                          return;
                        }
                        await a.update(() => a.subjects.remove(s));
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── شاشة التنبيه الرنّان ─────────────────────────

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key, required this.id, required this.title, required this.sub});
  final int id;
  final String title;
  final String sub;

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    await plugin.cancel(widget.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    final a = AppScope.of(context);
    final nav = Navigator.of(context);
    await plugin.cancel(widget.id);
    await _schedule(widget.id, widget.title, widget.sub, DateTime.now().add(const Duration(minutes: 5)), a);
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final now = DateTime.now();
    const navy = Color(0xFF0A1230);
    const blue = Color(0xFF1E5BD8);
    return Scaffold(
      backgroundColor: navy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -1), radius: 1.3, colors: [Color(0xFF1E3A8A), navy], stops: [0, 0.62]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
                  child: Text(a.t('alarmBadge'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                Text(a.fmtDateTime(now), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(a.longDate(now), style: const TextStyle(color: Color(0xFFC3D2F5))),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: AnimatedBuilder(
                        animation: _c,
                        builder: (context, _) => Stack(
                          alignment: Alignment.center,
                          children: [
                            for (final shift in [0.0, 0.33, 0.66])
                              Builder(builder: (context) {
                                final t = (_c.value + shift) % 1.0;
                                return Opacity(
                                  opacity: (1 - t) * 0.55,
                                  child: Container(
                                    width: 200 * (0.55 + 0.95 * t),
                                    height: 200 * (0.55 + 0.95 * t),
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: blue),
                                  ),
                                );
                              }),
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(38)),
                              child: const Icon(Icons.notifications_active, size: 56, color: Color(0xFF0F2A6B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text(widget.sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFFD5E0F7))),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F2A6B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _stop,
                    icon: const Icon(Icons.stop),
                    label: Text(a.t('stop'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: _snooze,
                    child: Text(a.t('snooze'), style: const TextStyle(fontSize: 17)),
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

// END OF FILE
