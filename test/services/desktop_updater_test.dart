import 'package:flutter_test/flutter_test.dart';
import 'package:scanco/src/core/services/desktop_updater.dart';

/// Validates the generated self-update helper scripts (the actual install +
/// relaunch logic on desktop). The scripts are pure templates, so we assert
/// they contain the right commands — this catches regressions in CI without
/// executing OS-level operations.
void main() {
  group('DesktopUpdater helper scripts', () {
    test('windows: waits for exit, copies release over app dir, relaunches',
        () {
      final s = DesktopUpdater.windowsScript();
      expect(s, contains("Get-Process -Name 'scanco'"));
      expect(s, contains(r'Copy-Item -Path "$Staging\app\*"'));
      expect(s, contains(r'Start-Process -FilePath $NewExe'));
      expect(s, contains(r'Remove-Item -Path $Staging'));
    });

    test('linux: waits for exit, copies bundle, relaunches via nohup', () {
      final s = DesktopUpdater.linuxScript();
      expect(s, contains('kill -0'));
      expect(s, contains(r'cp -R "$STAGING/app/." "$APP_DIR/"'));
      expect(s, contains('nohup'));
    });

    test('macos: mounts dmg, swaps scanco.app, opens new version', () {
      final s = DesktopUpdater.macosScript();
      expect(s, contains('hdiutil attach'));
      expect(s, contains(r'cp -R "$MOUNT/scanco.app"'));
      expect(s, contains('hdiutil detach'));
      expect(s, contains(r'open "$INSTALL_DIR/scanco.app"'));
    });
  });
}
