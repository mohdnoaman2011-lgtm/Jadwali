part of 'main.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Brand & palette (taken from the Jadwali logo)
// ═══════════════════════════════════════════════════════════════════════
class Brand {
  static const navy = Color(0xFF1B3560); // deep brand navy (alerts, accents)
  static const cyan = Color(0xFF5BC0E0); // soft sky accent
  static const green = Color(0xFF3FA37F);
  static const blue = Color(0xFF2B5BA8); // primary
  static const amber = Color(0xFFCC9438);
  static const coral = Color(0xFFCB5340);
}

/// Eye-friendly palette: softened brand blues, off-white backgrounds and a
/// calm (not pure-black/white) dark theme.
class Pal {
  final Color bg, surface, text, muted, soft, nav, primary;
  const Pal(this.bg, this.surface, this.text, this.muted, this.soft, this.nav,
      this.primary);

  static const light = Pal(Color(0xFFF4F6FA), Colors.white, Color(0xFF1E2B4A),
      Color(0xFF5B6B86), Color(0xFFE7ECF4), Color(0xFF1E3A66), Brand.blue);
  static const dark = Pal(Color(0xFF0F1A2E), Color(0xFF172640),
      Color(0xFFE6EDF7), Color(0xFF9FB0CC), Color(0xFF1F3354),
      Color(0xFF1C3158), Color(0xFF3F73C7));

  static Pal of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

/// Selection marks (checks) follow the brand: blue on light, cyan on dark.
Color checkColor(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark ? Brand.cyan : Brand.blue;

/// App-wide on/off switch (same look as the design: 48x28 track, 22 knob).
Widget appSwitch(bool value, ValueChanged<bool> onChanged) =>
    _AppSwitch(value: value, onChanged: onChanged);

class _AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AppSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offTrack = isDark ? const Color(0xFF2E4670) : const Color(0xFFD3DCEA);
    return Semantics(
      toggled: value,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? Brand.cyan : offTrack,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? p.nav : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ThemeData buildTheme(Brightness b, bool arabic) {
  final p = b == Brightness.dark ? Pal.dark : Pal.light;
  final base = ThemeData(brightness: b).textTheme;

  // Fonts from the design: IBM Plex Sans Arabic (Arabic) / DM Sans (English),
  // with the same 1.35 line height.
  var text = arabic
      ? GoogleFonts.ibmPlexSansArabicTextTheme(base)
      : GoogleFonts.dmSansTextTheme(base);
  TextStyle? h(TextStyle? s) => s?.copyWith(height: 1.35);
  text = text.copyWith(
    bodyLarge: h(text.bodyLarge),
    bodyMedium: h(text.bodyMedium),
    bodySmall: h(text.bodySmall),
    titleMedium: h(text.titleMedium),
    labelLarge: h(text.labelLarge),
  );
  text = text.apply(bodyColor: p.text, displayColor: p.text);

  final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none);

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: p.bg,
    textTheme: text,
    colorScheme: ColorScheme.fromSeed(seedColor: Brand.navy, brightness: b)
        .copyWith(primary: p.primary, surface: p.surface, onSurface: p.text),
    splashFactory: NoSplash.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      border: noBorder,
      enabledBorder: noBorder,
      focusedBorder: noBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.nav,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}
