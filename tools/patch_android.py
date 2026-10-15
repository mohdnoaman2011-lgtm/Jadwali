"""Adds the Android permissions, receivers and desugaring that flutter_local_notifications needs.
Run after `flutter create . --platforms=android`."""
import re

MANIFEST = 'android/app/src/main/AndroidManifest.xml'

PERMS = """<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32"/>
    """

RECEIVERS = """<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
    """

s = open(MANIFEST, encoding='utf-8').read()
if 'POST_NOTIFICATIONS' not in s:
    s = s.replace('<application', PERMS + '<application', 1)
    s = s.replace('</application>', RECEIVERS + '</application>', 1)
    s = re.sub(r'android:label="[^"]*"', 'android:label="جدولي"', s, count=1)
    open(MANIFEST, 'w', encoding='utf-8').write(s)
    print('manifest patched')

for path, kts in (('android/app/build.gradle', False), ('android/app/build.gradle.kts', True)):
    try:
        t = open(path, encoding='utf-8').read()
    except FileNotFoundError:
        continue
    if 'oreLibraryDesugaring' in t:
        continue
    if kts:
        t = re.sub(r'(compileOptions\s*\{)', r'\1\n        isCoreLibraryDesugaringEnabled = true', t, count=1)
        t += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    else:
        t = re.sub(r'(compileOptions\s*\{)', r'\1\n        coreLibraryDesugaringEnabled true', t, count=1)
        t += "\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"
    open(path, 'w', encoding='utf-8').write(t)
    print(path, 'patched')