import 'package:flutter_test/flutter_test.dart';
import 'package:scanco/src/core/services/update_service.dart';

/// Build-aware update comparison tests.
///
/// `isNewer(latest, current, currentBuild)` decides whether release tag
/// `latest` is newer than the installed build (version `current`, build/run
/// number `currentBuild`). CI tags dev releases `v1.0.0-dev.{run_number}` and
/// injects the same run number as `APP_BUILD`, so the comparison is by run
/// number — same build means no update prompt.
void main() {
  // Installed build = run 24 (e.g. a build produced by run #24).
  const installedBuild = 24;

  final service = UpdateService();

  group('isNewer — dev pre-releases (base equal)', () {
    test('newer run number → true', () {
      expect(service.isNewer('1.0.0-dev.25', '1.0.0', installedBuild), isTrue);
      expect(service.isNewer('1.0.0-dev.27', '1.0.0', installedBuild), isTrue);
    });

    test('same run number → false (no self-update)', () {
      expect(service.isNewer('1.0.0-dev.24', '1.0.0', installedBuild), isFalse);
    });

    test('older run number → false', () {
      expect(service.isNewer('1.0.0-dev.10', '1.0.0', installedBuild), isFalse);
    });

    test('leading v is ignored', () {
      expect(service.isNewer('v1.0.0-dev.25', '1.0.0', installedBuild), isTrue);
    });
  });

  group('isNewer — base semver differences', () {
    test('higher base semver → true (stable wins over dev)', () {
      expect(service.isNewer('1.0.1', '1.0.0', installedBuild), isTrue);
      expect(service.isNewer('1.1.0', '1.0.9', installedBuild), isTrue);
      expect(service.isNewer('1.0.1-dev.1', '1.0.0', installedBuild), isTrue);
    });

    test('lower base semver → false', () {
      expect(service.isNewer('1.0.0-dev.30', '1.1.0', installedBuild), isFalse);
      expect(service.isNewer('0.9.9', '1.0.0', installedBuild), isFalse);
    });

    test('same stable base → false', () {
      expect(service.isNewer('1.0.0', '1.0.0', installedBuild), isFalse);
    });
  });

  group('isNewer — installed build varies', () {
    test('installed on latest run → no update for same run', () {
      expect(service.isNewer('1.0.0-dev.27', '1.0.0', 27), isFalse);
      expect(service.isNewer('1.0.0-dev.28', '1.0.0', 27), isTrue);
    });

    test('local build (build 0) sees any dev release as newer', () {
      expect(service.isNewer('1.0.0-dev.1', '1.0.0', 0), isTrue);
    });
  });
}
