part of 'main.dart';

// ───────────────────────── عناصر واجهة مشتركة ─────────────────────────

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Material(
      color: color ?? p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: p.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  const PillChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Material(
      color: selected ? p.pri : p.card,
      shape: StadiumBorder(side: BorderSide(color: selected ? p.pri : p.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            widthFactor: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(fontSize: 13.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? p.onPri : p.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Seg<T> extends StatelessWidget {
  const Seg({super.key, required this.items, required this.value, required this.onChanged});
  final Map<T, String> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          for (final e in items.entries)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.key == value ? p.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: e.key == value ? [const BoxShadow(color: Color(0x290F1B3D), blurRadius: 4, offset: Offset(0, 1))] : null,
                  ),
                  child: Text(e.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: e.key == value ? p.text : p.muted)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// مفتاح تبديل مدمج بين خيارين: [الأول] (مفتاح) [الثاني].
class SwitchRow extends StatelessWidget {
  const SwitchRow({super.key, required this.startLabel, required this.endLabel, required this.atEnd, required this.onChanged});
  final String startLabel;
  final String endLabel;
  final bool atEnd;
  final ValueChanged<bool> onChanged;

  Widget _lbl(Pal p, String s, bool on, bool value) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(value),
        child: Container(
          width: 60,
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
          child: Text(s, maxLines: 1, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? p.text : p.muted)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lbl(p, startLabel, !atEnd, false),
        const SizedBox(width: 2),
        MiniSwitch(on: atEnd, twoWay: true, onChanged: onChanged),
        const SizedBox(width: 2),
        _lbl(p, endLabel, atEnd, true),
      ],
    );
  }
}

/// مفتاح تشغيل/إيقاف صغير (كبسولة ودائرة بيضاء).
/// [twoWay]: مفتاح بين خيارين فيبقى المسار ملوّنًا في الحالتين.
class MiniSwitch extends StatelessWidget {
  const MiniSwitch({super.key, required this.on, required this.onChanged, this.twoWay = false});
  final bool on;
  final bool twoWay;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        alignment: on ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: (on || twoWay) ? p.pri : p.line,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x47000000), blurRadius: 3, offset: Offset(0, 1))]),
        ),
      ),
    );
  }
}

/// مفتاح الوضع الداكن: كبسولة فاتحة بإطار رمادي ودائرة رمادية (الدائرة يمينًا = مفعّل).
class DarkSwitch extends StatelessWidget {
  const DarkSwitch({super.key, required this.on, required this.onChanged});
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final edge = dark ? const Color(0xFF9DA9CB) : const Color(0xFF6B7977);
    final fill = dark ? const Color(0xFF222D50) : const Color(0xFFDDE3E1);
    return Semantics(
      toggled: on,
      child: GestureDetector(
        onTap: () => onChanged(!on),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 62,
          height: 36,
          padding: const EdgeInsets.all(5),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(20), border: Border.all(color: edge, width: 3)),
          child: Container(width: 18, height: 18, decoration: BoxDecoration(color: edge, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

/// أزرار اختيار مدمجة (قطعتان): المحدد بخلفية داكنة ونص أبيض.
class MiniSeg extends StatelessWidget {
  const MiniSeg({super.key, required this.labels, required this.index, required this.onChanged});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minWidth: 72),
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: i == index ? p.pri : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                child: Text(labels[i], maxLines: 1, style: TextStyle(fontSize: 14, fontWeight: i == index ? FontWeight.w700 : FontWeight.w500, color: i == index ? p.onPri : p.muted)),
              ),
            ),
        ],
      ),
    );
  }
}

enum BtnKind { primary, soft, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onTap, this.icon, this.kind = BtnKind.primary, this.height = 54});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final BtnKind kind;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    Color bg;
    Color fg;
    switch (kind) {
      case BtnKind.primary:
        bg = p.pri;
        fg = p.onPri;
        break;
      case BtnKind.soft:
        bg = p.soft;
        fg = p.text;
        break;
      case BtnKind.danger:
        bg = p.redSoft;
        fg = p.red;
        break;
      case BtnKind.ghost:
        bg = Colors.transparent;
        fg = p.muted;
        break;
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
              Flexible(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg))),
            ],
          ),
        ),
      ),
    );
  }
}

class IconBox extends StatelessWidget {
  const IconBox({super.key, required this.icon, this.bg, this.fg, this.size = 40});
  final IconData icon;
  final Color? bg;
  final Color? fg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg ?? p.soft, borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, size: 22, color: fg ?? p.pri),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, required this.tooltip, this.color, this.badge});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: p.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 22, color: color ?? p.text)),
            ),
          ),
          if (badge != null && badge! > 0)
            PositionedDirectional(
              top: -4,
              end: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(color: p.red, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.actions = const []});
  final IconData icon;
  final String title;
  final String? body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(32)),
            child: Icon(icon, size: 44, color: p.pri),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          if (body != null && body!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(body!, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.7, color: p.muted)),
          ],
          for (final w in actions) ...[const SizedBox(height: 12), w],
        ],
      ),
    );
  }
}

void showToast(BuildContext context, String msg) {
  final m = msgKey.currentState;
  if (m == null) return;
  final p = Pal.of(context);
  m
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 20, color: p.bg),
          const SizedBox(width: 8),
          Flexible(child: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: p.bg, fontWeight: FontWeight.w600))),
        ],
      ),
      backgroundColor: p.text,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(milliseconds: 2200),
    ));
}

Future<T?> showAppSheet<T>(BuildContext context, Widget Function(BuildContext) builder) {
  final p = Pal.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (c) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: p.sw, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 14),
            builder(c),
          ],
        ),
      ),
    ),
  );
}

Future<bool> confirmSheet(BuildContext context, {required String title, required String sub, required String yes, required String no}) async {
  final p = Pal.of(context);
  final res = await showAppSheet<bool>(
    context,
    (c) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: IconBox(icon: Icons.delete_outline, bg: p.redSoft, fg: p.red, size: 60)),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(sub, textAlign: TextAlign.center, style: TextStyle(color: p.muted)),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(yes, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        AppButton(label: no, kind: BtnKind.soft, onTap: () => Navigator.of(c).pop(false)),
      ],
    ),
  );
  return res ?? false;
}

Future<void> deleteLecture(BuildContext context, Lecture l) async {
  final a = AppScope.of(context);
  final ok = await confirmSheet(context, title: a.t('delLecQ'), sub: '${l.subject} · ${a.t('delD')}', yes: a.t('yesDelete'), no: a.t('keep'));
  if (!ok) return;
  await a.update(() => a.lectures.removeWhere((x) => x.id == l.id));
  showToast(navKey.currentContext ?? context, a.t('deleted'));
  await safeCancel(l.id);
}

Future<void> deleteReminder(BuildContext context, Reminder r) async {
  final a = AppScope.of(context);
  final ok = await confirmSheet(context, title: a.t('delRemQ'), sub: '${r.title} · ${a.t('delD')}', yes: a.t('yesDelete'), no: a.t('keep'));
  if (!ok) return;
  await a.update(() => a.reminders.removeWhere((x) => x.id == r.id));
  showToast(navKey.currentContext ?? context, a.t('deleted'));
  await safeCancel(r.id);
}

/// قائمة خيارات (فتح / تعديل / حذف) لمحاضرة أو تذكير.
Future<void> showItemActions(
  BuildContext context, {
  required String title,
  required String sub,
  required Color color,
  required VoidCallback onOpen,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final a = AppScope.of(context);
  final p = Pal.of(context);
  return showAppSheet<void>(
    context,
    (c) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(sub, style: TextStyle(color: p.muted, fontSize: 13.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppButton(label: a.t('openDetails'), icon: Icons.info_outline, kind: BtnKind.soft, onTap: () {
          Navigator.of(c).pop();
          onOpen();
        }),
        const SizedBox(height: 10),
        AppButton(label: a.t('edit'), icon: Icons.edit_outlined, kind: BtnKind.soft, onTap: () {
          Navigator.of(c).pop();
          onEdit();
        }),
        const SizedBox(height: 10),
        AppButton(label: a.t('delete'), icon: Icons.delete_outline, kind: BtnKind.danger, onTap: () {
          Navigator.of(c).pop();
          onDelete();
        }),
      ],
    ),
  );
}

void openLectureDetail(BuildContext context, Lecture l) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailPage(lectureId: l.id)));
void openReminderDetail(BuildContext context, Reminder r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailPage(reminderId: r.id)));
void openEditLecture(BuildContext context, Lecture l) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddPage(editLecture: l)));
void openEditReminder(BuildContext context, Reminder r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddPage(editReminder: r)));

void lectureActions(BuildContext context, Lecture l) {
  final a = AppScope.of(context);
  showItemActions(
    context,
    title: l.subject,
    sub: '${a.dayName(l.weekday)} · ${a.fmtMin(l.start)} – ${a.fmtMin(l.end)}',
    color: a.colorOf(l.subject),
    onOpen: () => openLectureDetail(context, l),
    onEdit: () => openEditLecture(context, l),
    onDelete: () => deleteLecture(context, l),
  );
}

void reminderActions(BuildContext context, Reminder r) {
  final a = AppScope.of(context);
  showItemActions(
    context,
    title: r.title,
    sub: '${r.subject} · ${a.dayLabel(r.when)} ${a.fmtDateTime(r.when)}',
    color: a.colorOf(r.subject),
    onOpen: () => openReminderDetail(context, r),
    onEdit: () => openEditReminder(context, r),
    onDelete: () => deleteReminder(context, r),
  );
}

// ───────────────────────── شاشة البداية ─────────────────────────

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const _navy = Color(0xFF0F2A6B);

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.memory(
                      base64Decode(kLogoB64),
                      width: 220,
                      gaplessPlayback: true,
                      semanticLabel: a.t('app'),
                      errorBuilder: (context, error, stack) => Text(
                        a.t('app'),
                        style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: _navy),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      a.t('tagline'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, height: 1.7, color: Color(0xFF3D4A66)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const OnboardingPage())),
                  child: Text(a.t('start'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── التعريف بالتطبيق ─────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int i = 0;

  void _goPerm() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PermissionPage()));

  Widget _illus(int k, AppState a) {
    const rows = [Color(0xFF2F6BFF), Color(0xFF17A673), Color(0xFFF08A24), Color(0xFF8B5CF6)];
    if (k == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final c in rows)
            Container(
              width: 230,
              height: 52,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFD5DBEA), borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(width: 10),
                  Container(width: 34, height: 8, decoration: BoxDecoration(color: const Color(0xFFB9C3DD), borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
        ],
      );
    }
    if (k == 1) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: const Icon(Icons.notifications_active_outlined, size: 64, color: Color(0xFF0F2A6B)),
      );
    }
    return SizedBox(
      width: 290,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var n = 0; n < kWeekdays.length; n++)
            Container(
              width: 90,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: n == 2 ? Colors.white : Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                a.shortDay(kWeekdays[n]),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: n == 2 ? const Color(0xFF0F2A6B) : Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final titles = [a.t('ob1t'), a.t('ob2t'), a.t('ob3t')];
    final descs = [a.t('ob1d'), a.t('ob2d'), a.t('ob3d')];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Align(alignment: AlignmentDirectional.centerEnd, child: PillChip(label: a.t('skip'), selected: false, onTap: _goPerm)),
              const SizedBox(height: 12),
              Container(
                height: 300,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF0F2A6B), Color(0xFF1E5BD8), Color(0xFF17A673)], stops: [0, 0.6, 1]),
                ),
                child: _illus(i, a),
              ),
              const SizedBox(height: 26),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(titles[i], style: const TextStyle(fontSize: 26, height: 1.3, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(descs[i], style: TextStyle(fontSize: 15.5, height: 1.7, color: p.muted)),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var n = 0; n < 3; n++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: n == i ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: n == i ? p.pri : p.sw, borderRadius: BorderRadius.circular(4)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              AppButton(label: i == 2 ? a.t('getStarted') : a.t('next'), onTap: () => i == 2 ? _goPerm() : setState(() => i++)),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── الأذونات ─────────────────────────

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool notif = false;
  bool exact = false;

  bool _busy = false;

  Future<void> _finish() async {
    if (_busy) return;
    _busy = true;
    final a = AppScope.of(context);
    final nav = Navigator.of(context);
    // نحفظ الحالة دون انتظار طويل، ثم ننتقل دائمًا للشاشة الرئيسية
    try {
      await a.update(() => a.onboarded = true).timeout(const Duration(seconds: 3));
    } catch (_) {
      a.onboarded = true;
    }
    nav.pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const ShellPage()), (r) => false);
  }

  Future<void> _allowAll() async {
    final a0 = AppScope.of(context);
    try {
      final n = await askNotificationsPermission().timeout(const Duration(seconds: 20), onTimeout: () => false);
      if (mounted) setState(() => notif = n);
    } catch (_) {}
    try {
      final e = await askExactAlarmsPermission().timeout(const Duration(seconds: 3), onTimeout: () => false);
      if (mounted) setState(() => exact = e);
    } catch (_) {}
    try {
      a0.fsiAsked = true;
      await askFullScreenPermission().timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (_) {}
    await _finish();
  }

  Widget _row(AppState a, Pal p, IconData icon, String t, String d, bool on, VoidCallback onTap) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconBox(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(d, style: TextStyle(fontSize: 13.5, color: p.muted)),
              ],
            ),
          ),
          PillChip(label: on ? a.t('allowed') : a.t('allow'), selected: on, onTap: onTap),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(colors: [Color(0xFF1E5BD8), Color(0xFF0F2A6B)]),
                ),
                child: const Icon(Icons.notifications_active_outlined, size: 42, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(a.t('permT'), style: const TextStyle(fontSize: 28, height: 1.25, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(a.t('permD'), style: TextStyle(height: 1.7, color: p.muted)),
              const SizedBox(height: 20),
              _row(a, p, Icons.notifications_outlined, a.t('p1t'), a.t('p1d'), notif, () async {
                final ok = await askNotificationsPermission();
                if (mounted) setState(() => notif = ok);
              }),
              const SizedBox(height: 10),
              _row(a, p, Icons.alarm, a.t('p2t'), a.t('p2d'), exact, () async {
                final ok = await askExactAlarmsPermission();
                if (mounted) setState(() => exact = ok);
              }),
              const Spacer(),
              AppButton(label: a.t('allowAll'), onTap: _allowAll),
              const SizedBox(height: 8),
              AppButton(label: a.t('later'), kind: BtnKind.ghost, onTap: _finish),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── الهيكل الرئيسي ─────────────────────────

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;

  void _add() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddPage()));

  Widget _item(AppState a, Pal p, int i, IconData icon, IconData iconOn, String label) {
    final on = index == i;
    return Expanded(child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => index = i),
      child: Container(
        height: 56,
        decoration: BoxDecoration(color: on ? p.soft : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(on ? iconOn : icon, size: 22, color: on ? p.pri : p.muted),
            const SizedBox(height: 1),
            Text(label, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.1, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? p.pri : p.muted)),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final pages = <Widget>[
      HomePage(onOpenWeek: () => setState(() => index = 1), onOpenReminders: () => setState(() => index = 2)),
      const WeekPage(),
      const RemindersPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[index]),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72,
          margin: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: p.line),
            boxShadow: const [BoxShadow(color: Color(0x240F2A6B), blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(a, p, 0, Icons.calendar_today_outlined, Icons.calendar_today, a.t('home')),
              _item(a, p, 1, Icons.grid_view_outlined, Icons.grid_view_rounded, a.t('schedule')),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Tooltip(
                message: a.t('newT'),
                child: GestureDetector(
                  onTap: _add,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1E5BD8), Color(0xFF0F2A6B)]),
                      boxShadow: const [BoxShadow(color: Color(0x731E5BD8), blurRadius: 18, offset: Offset(0, 8))],
                    ),
                    child: const Icon(Icons.add, size: 28, color: Colors.white),
                  ),
                ),
              )),
              _item(a, p, 2, Icons.check_circle_outline, Icons.check_circle, a.t('reminders')),
              _item(a, p, 3, Icons.tune, Icons.tune, a.t('settings')),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── رأس الصفحة ─────────────────────────

class PageTop extends StatelessWidget {
  const PageTop({super.key, required this.title, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 13.5, color: p.muted)),
                Text(title, style: const TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SubjectDot extends StatelessWidget {
  const SubjectDot({super.key, required this.color, this.size = 12});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

// ───────────────────────── الرئيسية (اليوم) ─────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenWeek, required this.onOpenReminders});
  final VoidCallback onOpenWeek;
  final VoidCallback onOpenReminders;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final p = Pal.of(context);
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    final today = a.lectures.where((l) => l.weekday == now.weekday).toList()..sort((x, y) => x.start.compareTo(y.start));
    final pending = a.reminders.where((r) => !r.done).toList()..sort((x, y) => x.when.compareTo(y.when));

    Lecture? next;
    DateTime? nextAt;
    for (final l in a.lectures) {
      final at = nextOccurrence(l.weekday, l.start, now);
      if (nextAt == null || at.isBefore(nextAt)) {
        next = l;
        nextAt = at;
      }
    }

    final children = <Widget>[];

    if (a.lectures.isEmpty) {
      children.add(EmptyState(
        icon: Icons.calendar_today_outlined,
        title: a.t('emptyT'),
        body: a.t('emptyD'),
        actions: [AppButton(label: a.t('addFirst'), icon: Icons.add, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddPage())))],
      ));
    } else {
      if (next != null && nextAt != null) {
        final nl = next;
        children.add(Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1E5BD8), Color(0xFF0F2A6B)]),
            boxShadow: const [BoxShadow(color: Color(0x401E5BD8), blurRadius: 24, offset: Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _whitePill(a.t('nextLecture')),
                  _whitePill(a.inText(nextAt.difference(now))),
                ],
              ),
              const SizedBox(height: 16),
              Text(nl.subject, style: const TextStyle(fontSize: 27, height: 1.25, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 18,
                runSpacing: 6,
                children: [
                  _heroInfo(Icons.schedule, '${a.fmtMin(nl.start)} – ${a.fmtMin(nl.end)}'),
                  if (nl.room.isNotEmpty) _heroInfo(Icons.place_outlined, '${a.t('hall')} ${nl.room}'),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _heroBtn(a.t('details'), null, false, () => openLectureDetail(context, nl))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroBtn(nl.on ? a.t('alertOn') : a.t('alertOff'), nl.on ? Icons.notifications_active_outlined : Icons.notifications_off_outlined, true, () async {
                      await a.update(() => nl.on = !nl.on);
                      await scheduleLecture(a, nl);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ));
        children.add(const SizedBox(height: 16));
      }

      children.add(Row(
        children: [
          Expanded(child: _tile(p, Icons.menu_book_outlined, p.pri, a.t('lecCount'), '${today.length}', onOpenWeek)),
          const SizedBox(width: 12),
          Expanded(child: _tile(p, Icons.assignment_outlined, p.amberText, a.t('remCount'), '${pending.length}', onOpenReminders)),
        ],
      ));
      children.add(const SizedBox(height: 16));

      if (today.isEmpty) {
        children.add(AppCard(
          child: Row(
            children: [
              IconBox(icon: Icons.wb_sunny_outlined, bg: p.amber, fg: p.amberText),
              const SizedBox(width: 14),
              Expanded(child: Text(a.t('noToday'), style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700))),
            ],
          ),
        ));
        children.add(const SizedBox(height: 16));
      } else {
        if (next == null || nextAt == null || !today.any((l) => l.start > nowMin)) {
          children.add(AppCard(
            child: Row(
              children: [
                IconBox(icon: Icons.check, bg: p.grnSoft, fg: p.grn),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.t('allDone'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(a.t('allDoneD'), style: TextStyle(fontSize: 13.5, color: p.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ));
          children.add(const SizedBox(height: 16));
        }
        children.add(_sectionTitle(a.t('todayLec'), '${today.length}', p));
        children.add(const SizedBox(height: 12));
        for (final l in today) {
          children.add(Padding(padding: const EdgeInsets.only(bottom: 10), child: LectureRow(lecture: l, nowMin: nowMin)));
        }
        children.add(const SizedBox(height: 6));
      }

      // محاضرات الأيام القادمة (بقية الأسبوع)
      final upcoming = <MapEntry<DateTime, List<Lecture>>>[];
      for (var d = 1; d <= 6; d++) {
        final dt = DateTime(now.year, now.month, now.day + d);
        if (!kWeekdays.contains(dt.weekday)) continue;
        final ls = a.lectures.where((l) => l.weekday == dt.weekday).toList()..sort((x, y) => x.start.compareTo(y.start));
        if (ls.isNotEmpty) upcoming.add(MapEntry(dt, ls));
      }
      if (upcoming.isNotEmpty) {
        children.add(Row(
          children: [
            Expanded(child: Text(a.t('upcomingLec'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            PillChip(label: a.t('viewWeek'), selected: false, onTap: onOpenWeek),
          ],
        ));
        children.add(const SizedBox(height: 12));
        for (final e in upcoming) {
          children.add(Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Row(
              children: [
                Text('${a.dayLabel(e.key)} · ${a.shortDate(e.key)}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.muted)),
                const SizedBox(width: 8),
                Expanded(child: Divider(height: 1, color: p.line)),
              ],
            ),
          ));
          for (final l in e.value) {
            children.add(Padding(padding: const EdgeInsets.only(bottom: 10), child: LectureRow(lecture: l, nowMin: -1)));
          }
        }
        children.add(const SizedBox(height: 6));
      }

      if (pending.isNotEmpty) {
        final r = pending.first;
        children.add(const SizedBox(height: 6));
        children.add(Material(
          color: p.amber,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => openReminderDetail(context, r),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.assignment_outlined, color: p.amberText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.t('nextDue'), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.amberText)),
                        Text(r.title, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: p.amberText)),
                        Text('${r.subject} · ${a.dayLabel(r.when)} ${a.fmtDateTime(r.when)}', style: TextStyle(fontSize: 13, color: p.amberText)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: p.amberText),
                ],
              ),
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTop(
          subtitle: '${a.t('greet')} · ${a.longDate(now)}',
          title: a.t('todayTitle'),
          trailing: RoundIconButton(icon: Icons.notifications_outlined, tooltip: a.t('reminders'), badge: pending.length, onTap: onOpenReminders),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _whitePill(String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
        child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _heroInfo(IconData i, String s) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 17, color: Colors.white),
          const SizedBox(width: 6),
          Text(s, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
        ],
      );

  Widget _heroBtn(String label, IconData? icon, bool ghost, VoidCallback onTap) => Material(
        color: ghost ? Colors.white.withValues(alpha: 0.16) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
                Flexible(
                  child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: ghost ? Colors.white : const Color(0xFF0F2A6B))),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _sectionTitle(String t, String count, Pal p) => Row(
        children: [
          Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(12)),
            child: Text(count, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.pri)),
          ),
        ],
      );

  Widget _tile(Pal p, IconData icon, Color c, String label, String value, VoidCallback onTap) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, size: 22, color: c),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 24, height: 1.1, fontWeight: FontWeight.w700)),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: p.muted)),
                ],
              ),
            ),
          ],
        ),
      );
}

// END OF FILE
