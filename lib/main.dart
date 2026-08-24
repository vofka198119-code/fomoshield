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
import 'src/core/supabase/supabase_client.dart';
import 'src/core/theme/theme_v2.dart';
import 'src/core/theme/app_palette.dart';
import 'src/core/theme/theme_variant_provider.dart';
import 'src/features/orders/pending_orders_checker.dart';
import 'src/l10n/gen/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Only report real crashes from release builds — debug-time hot-reload
  // exceptions and dev-machine noise would otherwise flood Crashlytics.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Load .env — optional so the app doesn't crash if the file is missing
  await dotenv.load(fileName: '.env', isOptional: true);

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

  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    publishableKey: SupabaseConfig.anonKey,
  );

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
  await container.read(sectorRepositoryProvider).hydrateLiveCache();

  runApp(
    UncontrolledProviderScope(container: container, child: const ScanCoApp()),
  );
}

class ScanCoApp extends ConsumerStatefulWidget {
  const ScanCoApp({super.key});

  @override
  ConsumerState<ScanCoApp> createState() => _ScanCoAppState();
}

class _ScanCoAppState extends ConsumerState<ScanCoApp> {
  @override
  void initState() {
    super.initState();
    // Delayed so this doesn't compete with everything else the first
    // frame already loads (widget order providers, home widgets, sector
    // cache hydration, ...) — the CPU spike right at cold start is real.
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) checkPendingOrders(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageOverride = ref.watch(languageProvider);
    // Single global source for the app-wide background gradient AND status
    // bar icon brightness — every screen sits on this (Home used to paint
    // its own override on top since this was Standard-only; now that every
    // screen is expected to pick up the active theme, this is the one
    // place that needs to know about AppPalette, not each screen).
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
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
        // Caps the OS accessibility "larger font" setting so it can't blow
        // past what our fixed-size cards/rows were built to tolerate — real
        // devices with this cranked up (e.g. Redmi 9S) overflowed widget
        // edges before this was added. Still lets users get noticeably
        // bigger text, just not unbounded.
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.3,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            // Dark icons read fine on Standard's light background; once
            // Luxury Gold's dark background is active, they'd be
            // dark-on-dark and invisible, so flip to light icons whenever
            // the palette defines a dark backdrop.
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  palette.backgroundGradient != null || palette.background != null
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness:
                  palette.backgroundGradient != null || palette.background != null
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: Container(
              decoration: BoxDecoration(
                // Priority: a themed gradient, else a themed flat color,
                // else Standard's own default gradient. Mirrors the
                // 3-way fallback every screen used to hand-roll itself.
                gradient: palette.backgroundGradient ??
                    (palette.background == null
                        ? ThemeV2.backgroundGradient
                        : null),
                color: palette.backgroundGradient == null
                    ? palette.background
                    : null,
              ),
              child: Center(
                child: SizedBox(
                  width: 430,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      scaffoldBackgroundColor: Colors.transparent,
                      canvasColor: Colors.transparent,
                    ),
                    child: AppOverlayHost(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
