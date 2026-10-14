import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'theme.dart';
part 'state.dart';
part 'l10n.dart';
part 'data.dart';
part 'app_widgets.dart';
part 'start_shell.dart';
part 'home_schedule.dart';
part 'settings_alert.dart';
part 'notifications.dart';
part 'editors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.load(); // restore saved settings + reminders
  await Notifier.init(); // timezone + local notifications plugin
  runApp(const JadwaliApp());
}
