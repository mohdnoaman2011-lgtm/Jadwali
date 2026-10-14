part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  App root
// ═══════════════════════════════════════════════════════════════════════
class JadwaliApp extends StatelessWidget {
  const JadwaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jadwali',
        navigatorKey: navigatorKey,
        locale: app.locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: app.themeMode,
        theme: buildTheme(Brightness.light, app.isAr),
        darkTheme: buildTheme(Brightness.dark, app.isAr),
        builder: (context, child) {
          final dark = Theme.of(context).brightness == Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                .copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Colors.transparent),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: app.onboarded ? const Shell() : const StartScreen(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Shared widgets
// ═══════════════════════════════════════════════════════════════════════
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.radius = 22});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: Pal.of(context).surface,
            borderRadius: BorderRadius.circular(radius)),
        child: child,
      );
}

class PageHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const PageHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: trailing == null ? 44 : 48,
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700))),
          if (trailing != null) trailing!,
        ]),
      );
}

class Seg<T> extends StatelessWidget {
  final List<(T, String)> items;
  final T value;
  final ValueChanged<T> onChanged;
  const Seg(
      {super.key,
      required this.items,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: p.soft, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          for (final e in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(e.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.$1 == value ? p.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    e.$2,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          e.$1 == value ? FontWeight.w600 : FontWeight.w400,
                      color: e.$1 == value ? Colors.white : p.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const PillChip(this.label,
      {super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? p.primary : p.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : p.muted)),
      ),
    );
  }
}

class TimelineRow extends StatelessWidget {
  final String label;
  final Slot slot;
  final bool withTime;
  const TimelineRow(
      {super.key,
      required this.label,
      required this.slot,
      this.withTime = false});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final sub = [
      if (withTime && slot.kind != Kind.deadline) fmtTime(slot.start),
      if (slot.place.v.isNotEmpty) slot.place.v,
    ].join(' · ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 68,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: p.muted)),
          ),
        ),
        Expanded(
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
                      Text(sub,
                          style: TextStyle(fontSize: 13, color: p.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
