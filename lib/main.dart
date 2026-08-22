import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'src/core/cache/sector_providers.dart';
import 'src/core/localization/language_provider.dart';
import 'src/core/overlay/app_overlay_host.dart';
import 'src/core/router/app_router.dart';
import 'src/core/services/file_logger.dart';
import 'src/core/supabase/supabase_client.dart';
import 'src/core/theme/theme_v2.dart';
import 'src/features/orders/pending_orders_checker.dart';
import 'src/features/update/update_dialog.dart';
import 'src/l10n/gen/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Run the whole bootstrap inside a guarded zone so that:
  //  - every print()/debugPrint() is mirrored to logs/app.log (full diagnostics)
  //  - any uncaught async error is captured and written to the log
  runZonedGuarded(
    () async {
      await _bootstrap();
    },
    (Object error, StackTrace stack) {
      FileLogger.instance.error('Uncaught zone error: $error\n$stack');
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        FileLogger.instance.write('PRINT $line');
        parent.print(zone, line);
      },
    ),
  );
}

Future<void> _bootstrap() async {
  await FileLogger.instance.init();
  FileLogger.instance.info('main: ensureInitialized');

  // Mobile-only startup that has no meaning/implementation on desktop or web:
  // edge-to-edge system UI, Firebase (only Android has FirebaseOptions here),
  // and Crashlytics (no Windows/Linux support). Guarding it prevents a crash
  // before runApp() — which previously left the Windows window blank.
  final isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (isMobile) {
    // Edge-to-edge with a fully transparent system nav bar — no solid plate
    // behind the 3-button/gesture bar, regardless of the device's system
    // light/dark setting (the app itself is always light-themed).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    FileLogger.instance.info('main: system chrome configured (mobile)');
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Only report real crashes from release builds — debug-time hot-reload
    // exceptions and dev-machine noise would otherwise flood Crashlytics.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    FlutterError.onError = (details) {
      FileLogger.instance
          .error('FlutterError: ${details.exception}\n${details.stack}');
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FileLogger.instance.error('Platform error: $error\n$stack');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    FileLogger.instance.info('main: firebase + crashlytics ready (android)');
  } else {
    // Desktop/web: no Firebase — still capture errors to the log file.
    FlutterError.onError = (details) {
      FileLogger.instance
          .error('FlutterError: ${details.exception}\n${details.stack}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FileLogger.instance.error('Platform error: $error\n$stack');
      return true;
    };
    FileLogger.instance.info('main: firebase skipped (non-android)');
  }

  // Load .env — optional so the app doesn't crash if the file is missing
  await dotenv.load(fileName: '.env', isOptional: true);
  FileLogger.instance.info('main: .env loaded');

  // 🐛 Debug: verify API configuration loaded correctly
  final rawKey = dotenv.env['FINNHUB_API_KEY'] ?? '';
  final masked = rawKey.length > 8
      ? '${rawKey.substring(0, 4)}...${rawKey.substring(rawKey.length - 4)}'
      : 'NOT SET';
  debugPrint('═══════════════════════════════════════');
  debugPrint('🔧 Finnhub base: https://finnhub.io/api/v1');
  debugPrint('🔑 FINNHUB_API_KEY: $masked (len=${rawKey.length})');
  debugPrint('📁 .env loaded successfully');
  debugPrint('═══════════════════════════════════════');

  // Supabase is needed for auth/data, but a failure on a given platform
  // shouldn't blank the whole UI — log it and let the app still start.
  try {
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      publishableKey: SupabaseConfig.anonKey,
    );
    FileLogger.instance.info('main: supabase initialized');
  } catch (e, s) {
    FileLogger.instance.error('main: Supabase.initialize failed: $e\n$s');
  }

  // GoogleSignIn.instance.initialize() moved off this blocking path
  // (2026-08-14) — it isn't needed until the user actually taps "Continue
  // with Google" on the Auth screen, and typically takes noticeably longer
  // than the other steps here (Play Services round-trip), so leaving it
  // here was adding real time to the black screen between tapping the app
  // icon and Flutter's first frame. Kicked off instead from SplashScreen's
  // own bootstrap, in parallel with its 7s minimum display timer — see
  // splash_screen.dart's initGoogleSignIn().

  // Hydrate the stress-test engine's synchronous GICS-sector cache from
  // disk before the UI (and any resumed simulation ticks) can run — see
  // resolveGicsSector's live-cache check in gics_sector_mapper.dart. A
  // manual ProviderContainer lets this finish before runApp, instead of
  // racing the app's first frame with a fire-and-forget read.
  final container = ProviderContainer();
  try {
    await container.read(sectorRepositoryProvider).hydrateLiveCache();
    FileLogger.instance.info('main: sector cache hydrated');
  } catch (e, s) {
    FileLogger.instance.error('main: hydrateLiveCache failed: $e\n$s');
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const ScanCoApp()),
  );
  FileLogger.instance.info('main: runApp called');
}

class ScanCoApp extends ConsumerStatefulWidget {
  const ScanCoApp({super.key});

  @override
  ConsumerState<ScanCoApp> createState() => _ScanCoAppState();
}

class _ScanCoAppState extends ConsumerState<ScanCoApp> {
  bool _updateDialogShown = false;

  @override
  void initState() {
    super.initState();
    // Auto-update: wait for the splash → first-screen hand-off before
    // showing the dialog. Showing it during the splash let the splash's
    // `context.go(...)` to /auth or /home dismiss it ~1-2s later — the
    // "prompt closes and jumps to the main UI" the user saw. Now it appears
    // over the settled first screen and is modal (barrierDismissible: false):
    // when an update is available the app PAUSES at the prompt until the
    // user taps "Maybe later" or "Install" — no auto-forward to the UI.
    //
    // `context` here belongs to the app shell, which sits ABOVE the Navigator
    // inside MaterialApp.router — showDialog on it would throw "No Navigator
    // found" (which is why the dialog never appeared on cold start). Use the
    // router's root navigator instead.
    AppRouter.router.routerDelegate.addListener(_maybeShowUpdateDialog);

    // Delayed so this doesn't compete with everything else the first
    // frame already loads (widget order providers, home widgets, sector
    // cache hydration, ...) — the CPU spike right at cold start is real.
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) checkPendingOrders(ref);
    });
  }

  /// Fires once the router has handed off from the splash ('/') to a real
  /// screen — then shows the modal auto-update dialog (one shot).
  void _maybeShowUpdateDialog() {
    if (_updateDialogShown) return;
    final path =
        AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    if (path.isEmpty || path == '/') return; // still on the splash

    _updateDialogShown = true;
    AppRouter.router.routerDelegate.removeListener(_maybeShowUpdateDialog);

    final navContext = AppRouter.rootNavigatorKey.currentContext;
    if (navContext == null) return;
    showDialog(
      context: navContext,
      // Non-dismissible: when an update is available the prompt stays until
      // the user explicitly taps "Maybe later" / "Install". When there's no
      // update, silentWhenUpToDate pops it immediately anyway.
      barrierDismissible: false,
      builder: (_) => const UpdateDialog(silentWhenUpToDate: true),
    );
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_maybeShowUpdateDialog);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageOverride = ref.watch(languageProvider);
    return MaterialApp.router(
      title: 'F.O.M.O. Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeV2.lightTheme,
      // null follows the device's system locale; a non-null value is the
      // user's explicit Profile → Language override (language_provider.dart).
      locale: languageOverride,
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(gradient: ThemeV2.backgroundGradient),
          child: Center(
            child: SizedBox(
              width: 430,
              child: Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                  canvasColor: Colors.transparent,
                ),
                child: AppOverlayHost(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        );
      },
    );
  }
}
