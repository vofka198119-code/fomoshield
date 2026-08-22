import 'dart:io';

import 'package:flutter/foundation.dart';

/// Applies a downloaded release package on desktop and relaunches the new
/// version. The current app process exits afterwards so the new files can
/// replace it.
///
/// The classic self-update dance:
///  1. Download the platform package (zip / tar.gz / dmg) to a temp file.
///  2. Stage/extract it into a temp dir.
///  3. Launch a DETACHED helper that waits for THIS process to exit, copies
///     the staged files over the running install, cleans up, and starts the
///     new version.
///  4. The app calls `exit(0)`.
///
/// User data is safe: SharedPreferences/secure storage live outside the app
/// folder on every desktop platform, so replacing the install dir only swaps
/// the binaries.
class DesktopUpdater {
  /// Stages [package] and launches the detached updater helper. Callers
  /// should then exit the app so the helper can replace the running files.
  static Future<void> applyAndRelaunch(File package) async {
    if (Platform.isWindows) return _applyWindows(package);
    if (Platform.isLinux) return _applyLinux(package);
    if (Platform.isMacOS) return _applyMacOS(package);
    throw UnsupportedError('No desktop self-update for this platform');
  }

  // ── Windows ──────────────────────────────────────────────────────────────
  // ScanCo.zip (the Release/ folder) → Expand-Archive → helper copies over the
  // exe's dir, then launches the new scanco.exe.

  static Future<void> _applyWindows(File package) async {
    final exe = Platform.resolvedExecutable; // ...\ScanCo\scanco.exe
    final appDir = File(exe).parent.path;
    final staging = await Directory.systemTemp.createTemp('scanco_upd');
    final stagingPath = staging.path;
    final appStaging = '$stagingPath\\app';

    // Expand-Archive is built into Windows — avoids a Dart zip dependency.
    await Process.run('powershell.exe', [
      '-NoProfile',
      '-Command',
      'Expand-Archive -Path "${package.path}" -DestinationPath "$appStaging" -Force',
    ]);

    final scriptPath = '$stagingPath\\apply_update.ps1';
    File(scriptPath).writeAsStringSync(windowsScript());

    await Process.start('powershell.exe', [
      '-NoProfile',
      '-WindowStyle', 'Hidden',
      '-ExecutionPolicy', 'Bypass',
      '-File', scriptPath,
      appDir,
      stagingPath,
      exe,
    ]);
  }

  // ── Linux ────────────────────────────────────────────────────────────────
  // ScanCo.tar.gz (the bundle/) → tar -xzf → helper copies over the bundle
  // dir, then launches the new binary.

  static Future<void> _applyLinux(File package) async {
    final exe = Platform.resolvedExecutable; // .../bundle/scanco
    final bundleDir = File(exe).parent.path;
    final staging = await Directory.systemTemp.createTemp('scanco_upd');
    final stagingPath = staging.path;
    final appStaging = '$stagingPath/app';
    Directory(appStaging).createSync(recursive: true);

    await Process.run('tar', ['-xzf', package.path, '-C', appStaging]);

    final scriptPath = '$stagingPath/apply_update.sh';
    File(scriptPath).writeAsStringSync(linuxScript());

    await Process.start('/bin/sh', [
      scriptPath,
      '$pid',
      bundleDir,
      stagingPath,
      exe,
    ]);
  }

  // ── macOS ────────────────────────────────────────────────────────────────
  // ScanCo.dmg → helper mounts it, swaps scanco.app into the install dir,
  // detaches, and opens the new app.

  static Future<void> _applyMacOS(File package) async {
    final exe = Platform.resolvedExecutable;
    // .../scanco.app/Contents/MacOS/scanco
    final bundle = File(exe).parent.parent.parent.path; // scanco.app
    final installDir = File(bundle).parent.path; // e.g. /Applications

    final staging = await Directory.systemTemp.createTemp('scanco_upd');
    final scriptPath = '${staging.path}/apply_update.sh';
    File(scriptPath).writeAsStringSync(macosScript());

    await Process.start('/bin/sh', [
      scriptPath,
      '$pid',
      package.path,
      installDir,
    ]);
  }

  // ── Helper script templates (exposed for tests) ─────────────────────────

  @visibleForTesting
  static String windowsScript() => r'''
param([string]$AppDir, [string]$Staging, [string]$NewExe)
$deadline = (Get-Date).AddMinutes(5)
while ((Get-Date) -lt $deadline) {
  if (-not (Get-Process -Name 'scanco' -ErrorAction SilentlyContinue)) { break }
  Start-Sleep -Milliseconds 200
}
try {
  Copy-Item -Path "$Staging\app\*" -Destination $AppDir -Recurse -Force
} catch { }
Remove-Item -Path $Staging -Recurse -Force -ErrorAction SilentlyContinue
Start-Process -FilePath $NewExe -WorkingDirectory $AppDir
''';

  @visibleForTesting
  static String linuxScript() => '''
#!/bin/sh
OLD_PID="\$1"; APP_DIR="\$2"; STAGING="\$3"; NEW_EXE="\$4"
while kill -0 "\$OLD_PID" 2>/dev/null; do sleep 0.2; done
cp -R "\$STAGING/app/." "\$APP_DIR/"
rm -rf "\$STAGING"
nohup "\$NEW_EXE" >/dev/null 2>&1 &
''';

  @visibleForTesting
  static String macosScript() => '''
#!/bin/sh
OLD_PID="\$1"; DMG="\$2"; INSTALL_DIR="\$3"; MOUNT="/Volumes/ScanCo"
while kill -0 "\$OLD_PID" 2>/dev/null; do sleep 0.2; done
hdiutil attach -nobrowse -readonly "\$DMG" -quiet
rm -rf "\$INSTALL_DIR/scanco.app"
cp -R "\$MOUNT/scanco.app" "\$INSTALL_DIR/"
hdiutil detach "\$MOUNT" -quiet
rm -f "\$DMG"
open "\$INSTALL_DIR/scanco.app"
''';
}
