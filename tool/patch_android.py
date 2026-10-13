import pathlib
import re

# 1) Manifest: notification permissions + receivers used by scheduled alerts
m = pathlib.Path("android/app/src/main/AndroidManifest.xml")
s = m.read_text()
for perm in ("android.permission.POST_NOTIFICATIONS", "android.permission.RECEIVE_BOOT_COMPLETED", "android.permission.VIBRATE"):
    if perm not in s:
        s = s.replace("<application", f'<uses-permission android:name="{perm}"/>\n    <application', 1)
receivers = """<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
    """
if "ScheduledNotificationReceiver" not in s:
    s = s.replace("</application>", receivers + "</application>", 1)
m.write_text(s)

# 2) Gradle: core library desugaring (required by flutter_local_notifications)
for name in ("android/app/build.gradle.kts", "android/app/build.gradle"):
    f = pathlib.Path(name)
    if not f.exists():
        continue
    g = f.read_text()
    kts = name.endswith(".kts")
    if "oreLibraryDesugaring" not in g:
        flag = "isCoreLibraryDesugaringEnabled = true" if kts else "coreLibraryDesugaringEnabled true"
        g = re.sub(r"(compileOptions\s*\{)", lambda mo: mo.group(1) + "\n        " + flag, g, count=1)
        dep = ('coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' if kts
               else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'")
        if re.search(r"^dependencies\s*\{", g, re.M):
            g = re.sub(r"^(dependencies\s*\{)", lambda mo: mo.group(1) + "\n    " + dep, g, count=1, flags=re.M)
        else:
            g += "\ndependencies {\n    " + dep + "\n}\n"
    f.write_text(g)
print("android patched")
