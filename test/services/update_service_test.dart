import 'package:flutter/foundation.dart' show TargetPlatform;
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

  group('isNewer — branch-label precedence (installed on dev)', () {
    test('higher run on same dev label → true', () {
      expect(service.isNewer('1.0.0-dev.25', '1.0.0', 24, 'dev'), isTrue);
    });

    test('same run on same dev label → false', () {
      expect(service.isNewer('1.0.0-dev.24', '1.0.0', 24, 'dev'), isFalse);
    });

    test('main label beats dev even with lower run → true', () {
      expect(service.isNewer('1.0.0-main.10', '1.0.0', 24, 'dev'), isTrue);
    });

    test('dev label never supersedes main → false', () {
      expect(service.isNewer('1.0.0-dev.40', '1.0.0', 24, 'main'), isFalse);
    });

    test('other branch label loses to dev → false', () {
      expect(service.isNewer('1.0.0-feature-x.30', '1.0.0', 24, 'dev'), isFalse);
    });

    test('main beats other branch → true', () {
      expect(service.isNewer('1.0.0-main.5', '1.0.0', 24, 'feature-x'), isTrue);
    });

    test('numeric-only label ranks lowest → false vs dev', () {
      expect(service.isNewer('1.0.0-35.99', '1.0.0', 24, 'dev'), isFalse);
    });
  });

  group('isNewer — same-label run comparison', () {
    test('same label, higher run → true', () {
      expect(service.isNewer('1.0.0-main.40', '1.0.0', 30, 'main'), isTrue);
    });

    test('same label, lower run → false', () {
      expect(service.isNewer('1.0.0-main.5', '1.0.0', 30, 'main'), isFalse);
    });
  });

  group('isNewer — no installed label (older builds, build-only)', () {
    test('build-number-only comparison still applies', () {
      expect(service.isNewer('1.0.0-main.5', '1.0.0', 24), isFalse);
      expect(service.isNewer('1.0.0-dev.25', '1.0.0', 24, ''), isTrue);
    });

    test('stable same-base still not newer', () {
      expect(service.isNewer('1.0.0', '1.0.0', 24, 'dev'), isFalse);
    });
  });

  group('assetSuffix — per-platform release asset', () {
    test('maps every download platform to its asset', () {
      expect(service.assetSuffix(TargetPlatform.android), '.apk');
      expect(service.assetSuffix(TargetPlatform.windows), '.zip');
      expect(service.assetSuffix(TargetPlatform.linux), '.tar.gz');
      expect(service.assetSuffix(TargetPlatform.macOS), '.dmg');
    });

    test('iOS maps to the IPA asset', () {
      expect(service.assetSuffix(TargetPlatform.iOS), '.ipa');
    });
  });
}
