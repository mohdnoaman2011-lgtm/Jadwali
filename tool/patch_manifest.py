import re
p = "android/app/src/main/AndroidManifest.xml"
s = open(p, encoding="utf-8").read()
perms = [
    "POST_NOTIFICATIONS", "VIBRATE", "WAKE_LOCK", "RECEIVE_BOOT_COMPLETED",
    "SCHEDULE_EXACT_ALARM", "USE_EXACT_ALARM", "USE_FULL_SCREEN_INTENT", "DISABLE_KEYGUARD",
]
add = "".join(
    '    <uses-permission android:name="android.permission.%s"/>\n' % x
    for x in perms if x not in s
)
if add:
    s = s.replace("<application", add + "    <application", 1)
if 'android:showWhenLocked' not in s:
    s = s.replace('<activity', '<activity android:showWhenLocked="true" android:turnScreenOn="true"', 1)
if "ScheduledNotificationReceiver" not in s:
    rec = (
        '        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>\n'
        '        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">\n'
        '            <intent-filter>\n'
        '                <action android:name="android.intent.action.BOOT_COMPLETED"/>\n'
        '                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>\n'
        '                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>\n'
        '                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>\n'
        '            </intent-filter>\n'