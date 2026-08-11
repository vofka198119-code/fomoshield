# Platform Notes — Android vs iOS

## Feature Matrix

| Feature | Android | iOS |
|---------|---------|-----|
| Version check (GitHub API) | ✅ Yes | ✅ Yes |
| In-app APK/IPA download | ✅ Yes (APK) | ❌ No |
| In-app install trigger | ✅ FileProvider + Intent | ❌ No |
| Update flow | Download → Progress → Install | Open release page in Safari |
| Permissions needed | `REQUEST_INSTALL_PACKAGES` | None |
| FileProvider | Required | N/A |
| Sideloading supported | ✅ Yes (system level) | ❌ No (MDM or enterprise only) |

## Android Details

### Why FileProvider?

Since Android 7.0 (API 24), `file://` URIs are blocked for inter-app sharing. Apps must use `content://` URIs via `FileProvider` to expose files to the package installer.

### Manifest Configuration

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

### File Paths

```xml
<paths>
    <external-cache-path name="apk_downloads" path="apk/" />
</paths>
```

`external-cache-path` is used instead of `external-files-path` because:
- Cached files can be cleared by the system when storage is low
- The APK only needs to exist long enough to trigger the install
- No user-facing file clutter after install

### Install Intent

The app uses `open_filex` to trigger Android's package installer. This package handles FileProvider internally on Android 7+, generating the required `content://` URI automatically.

```dart
import 'package:open_filex/open_filex.dart';

final result = await OpenFilex.open(
  file.path,
  type: 'application/vnd.android.package-archive',
);
if (result.type != ResultType.done) {
  // Handle failure — show snackbar to user
}
```

> Note: `open_filex` handles FileProvider internally on Android 7+. No manual `FileProvider.getUriForFile()` calls needed.

### APK Signature Compatibility

The auto-update will work IF:
- Both old and new APKs are signed with the **same key**
- Currently, `build.gradle.kts` uses debug signing (`signingConfigs.getByName("debug")`)
- For production: generate a proper keystore and reference it in `key.properties`

If signature differs → Android rejects the install with "App not installed" error.

## iOS Details

### Why No In-App IPA Install?

Apple restricts IPA installation to:
1. **App Store** (requires Apple Developer account + review)
2. **TestFlight** (Apple Developer account, beta distribution)
3. **MDM/Enterprise** (Apple Developer Enterprise Program, $299/year)
4. **Ad-hoc** (limited to 100 devices per year, requires UDID registration)

None of these are compatible with a "download and install" flow for end users.

### iOS Flow

Instead, the update dialog shows "View on GitHub" which opens:
```
https://github.com/vofka198119-code/fomoshield/releases/latest
```

...in Safari via `url_launcher` (already in `pubspec.yaml`).

Users with their own signing setup can download the IPA from the release page and install via:
- Apple Configurator 2
- Xcode → Devices and Simulators
- Third-party tools (AltStore, SideStore)

### No Code Changes Needed for iOS

The `UpdateService` already handles iOS correctly:
- `downloadUrl` is `null` for iOS (no `.ipa` asset lookup needed — though we do include the IPA in the release)
- `UpdateInfo.isIosUpdate` → dialog shows "View on GitHub" instead of "Download & Install"

## Future: App Store / TestFlight

If the app is eventually published to the App Store:
- Switch to `upgrader` package or App Store `lookup` API
- No PAT needed — App Store API is public
- No FileProvider needed
- The existing `UpdateService` can be extended with an `AppStoreUpdateChecker` implementation

## Future: Play Store

If the app is eventually published to Google Play:
- Switch to `in_app_update` package (Play In-App Update API)
- Much better UX: seamless background download, forced updates support
- No PAT needed for version check (Play Store handles it)
- No `REQUEST_INSTALL_PACKAGES` needed (Play Store handles installs)
