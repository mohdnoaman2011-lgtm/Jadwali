part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Start screen
// ═══════════════════════════════════════════════════════════════════════
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final p = Pal.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final size = MediaQuery.sizeOf(context);
        final logoSize = (size.height * 0.30).clamp(160.0, 280.0).toDouble();

        // The logo PNG has a white background: show it as-is on the white
        // page, or on a white rounded tile in dark mode.
        Widget logo = Image.asset('assets/logo.png',
            width: logoSize, height: logoSize, fit: BoxFit.contain);
        if (isDark) {
          logo = Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
            child: logo,
          );
        }

        return Scaffold(
          backgroundColor: isDark ? p.bg : Colors.white,
          body: Stack(
            children: [
              // Soft brand-tinted shapes
              Positioned(
                  top: -80, right: -90, child: _decorCircle(280, const Color(0x245BC0E0))),
              Positioned(
                  top: size.height * 0.34,
                  left: -90,
                  child: _decorCircle(200, const Color(0x142B5BA8))),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Column(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(56, 44),
                            foregroundColor: p.text,
                            side: BorderSide(color: p.soft, width: 1.5),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => app.update(() => app.locale =
                              app.isAr ? const Locale('en') : const Locale('ar')),
                          child: Text(tr('langBtn'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            logo,
                            const SizedBox(height: 20),
                            Text(tr('headline'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 28,
                                    height: 1.3,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(tr('sub'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: p.muted)),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: isDark ? p.surface : p.bg,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _StartFeature(
                                      Icons.event_available_rounded, tr('feat1')),
                                  _StartFeature(
                                      Icons.notifications_active_outlined,
                                      tr('feat2')),
                                  _StartFeature(
                                      Icons.music_note_rounded, tr('feat3')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: p.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder()),
                          onPressed: () {
                            app.update(() => app.onboarded = true);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const Shell()));
                          },
                          child: Text(tr('start'),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _decorCircle(double d, Color c) => Container(
    width: d, height: d, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

class _StartFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StartFeature(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? p.soft
                    : p.surface,
                shape: BoxShape.circle),
            child: Icon(icon, color: checkColor(context)),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: p.muted)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Shell: floating bottom navigation + pages
// ═══════════════════════════════════════════════════════════════════════
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final granted = await Notifier.requestPermissions();
      await Notifier.sync();
      Notifier.openLaunchAlert();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('notifDenied'))));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        // Pages are created without `const` on purpose so they rebuild when
        // the language / theme / time format changes.
        final pages = <Widget>[
          TodayPage(),
          SchedulePage(),
          SettingsPage(),
        ];
        return Scaffold(
          body: SafeArea(
              bottom: false,
              child: IndexedStack(index: _index, children: pages)),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _NavBar(
                // nav item 2 ("Add") opens the editor instead of a tab,
                // so Settings (page 2) is highlighted as nav item 3.
                index: _index == 2 ? 3 : _index,
                onTap: (i) {
                  if (i == 2) {
                    openTimetableEditor(context);
                  } else {
                    setState(() => _index = i == 3 ? 2 : i);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _NavBar({required this.index, required this.onTap});

  static const _icons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.add_circle_outline_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: p.nav, borderRadius: BorderRadius.circular(34)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < 4; i++)
            Semantics(
              button: true,
              selected: i == index,
              label: tr('nav$i'),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  constraints: const BoxConstraints(minWidth: 48),
                  padding: EdgeInsets.symmetric(horizontal: i == index ? 18 : 14),
                  decoration: BoxDecoration(
                    color: i == index ? Brand.cyan : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[i],
                          size: 22,
                          color: i == index ? Brand.navy : Colors.white),
                      if (i == index) ...[
                        const SizedBox(width: 8),
                        Text(tr('nav$i'),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Brand.navy)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
