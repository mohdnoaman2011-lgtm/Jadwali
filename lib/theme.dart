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

/// App-wide on/off switch: cyan track with a navy thumb when on.
Widget appSwitch(bool value, ValueChanged<bool> onChanged) => Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: Brand.cyan,
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Brand.navy : Colors.white),
    );

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Pal.dark : Pal.light;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: Brand.navy, brightness: b)
        .copyWith(primary: p.primary, surface: p.surface, onSurface: p.text),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.nav,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}
