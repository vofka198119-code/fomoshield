import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'src/core/ads/ad_providers.dart';
import 'src/core/ads/app_open_ad_provider.dart';
import 'src/core/cache/sector_providers.dart';
import 'src/features/disclaimer/disclaimer_providers.dart';
import 'src/core/localization/language_provider.dart';
import 'src/core/overlay/app_overlay_host.dart';
import 'src/core/purchases/purchase_listener.dart';
import 'src/core/router/app_router.dart';
import 'src/core/supabase/supabase_client.dart';
import 'src/core/supabase/supabase_providers.dart';
import 'src/core/updates/in_app_update_service.dart';
import 'src/core/theme/theme_v2.dart';
import 'src/core/theme/app_palette.dart';
import 'src/core/theme/theme_variant_provider.dart';
import 'src/features/auth/password_recovery.dart';
import 'src/features/orders/pending_orders_checker.dart';
import 'src/l10n/gen/app_localizations.dart';

void main() async {
  // TEMP DEBUG 2026-09-19 — bracketing main()'s startup awaits to find
  // exactly where a real-device boot stalls (see mac_migration_gotchas
  // memory: build 128 showed only 1 I/flutter logcat line ever, no
  // steady-state traffic, during 3 reported sign-in attempts). Remove once
  // the hang location is found.
  debugPrint('🐛 main() start');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🐛 WidgetsFlutterBinding ready');

  // Locked portrait-only regardless of the device's own rotation-lock
  // setting or auto-rotate being on — nothing in the UI (fixed-width 430
  // shell in ScanCoApp.build, chart layouts, etc.) is built to handle
  // landscape, so letting the OS rotate it free would just show a
  // squished/broken layout rather than a real landscape mode.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('🐛 orientation locked');

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

  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    publishableKey: SupabaseConfig.anonKey,
  );
  initPasswordRecoveryListener();

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

class _ScanCoAppState extends ConsumerState<ScanCoApp>
    with WidgetsBindingObserver {
  // Global so the in-app-update "restart to apply" snackbar can be shown
  // from a lifecycle callback that isn't tied to whatever screen GoRouter
  // currently has up — MaterialApp.router below wires this in.
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // NOT delayed, unlike checkPendingOrders below — the purchaseStream
    // doc comment explicitly warns to subscribe "as soon as your app
    // launches", since any purchase update that arrives before a listener
    // is attached is simply lost.
    initPurchaseListener(ref);

    // Delayed so this doesn't compete with everything else the first
    // frame already loads (widget order providers, home widgets, sector
    // cache hydration, ...) — the CPU spike right at cold start is real.
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) checkPendingOrders(ref);
    });

    // App Open ad — this State object is the one thing that lives for the
    // app's entire process lifetime (unlike any single route/screen), so
    // it's the only place that can reliably see every resume regardless
    // of which screen GoRouter currently has up. WidgetsBindingObserver
    // only reports actual pause->resume transitions, never the initial
    // cold-start frame, so cold start needs its own explicit trigger —
    // fired after splash's own 7s minimum display window (splash_screen.dart)
    // so this lands right as Home first appears, not on top of the splash
    // branding, and gives subscriptionTierProvider's async fetch time to
    // resolve before the very first premium/admin check.
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(seconds: 7), _maybeShowAppOpenAd);

    // In-app update check — cheap no-op if already on the latest version,
    // so no delay/cooldown needed like the ad above. Re-checked on every
    // resume too (see didChangeAppLifecycleState) in case a newer version
    // published while the app sat backgrounded.
    checkForAppUpdate(_scaffoldMessengerKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeShowAppOpenAd();
      checkForAppUpdate(_scaffoldMessengerKey);
    }
  }

  Future<void> _maybeShowAppOpenAd() async {
    if (!mounted) return;
    // Only show once the user is actually inside the app — logged in, past
    // the disclaimer, and past mandatory nickname setup — not merely
    // "not premium/admin". Confirmed live 2026-09-25: without this, the ad
    // could fire on top of the auth/disclaimer/onboarding screens
    // themselves, before the user had even signed in — jarring UX, and
    // premature from a consent standpoint since no ad-consent flow (UMP)
    // has run for someone who isn't authenticated yet.
    final user = ref.read(currentUserProvider);
    if (user == null) {
      debugPrint('🚪 appOpenAd: skipped (not logged in)');
      return;
    }
    final disclaimerAccepted = await ref.read(
      isDisclaimerAcceptedProvider.future,
    );
    if (!mounted) return;
    if (!disclaimerAccepted) {
      debugPrint('🚪 appOpenAd: skipped (disclaimer not accepted)');
      return;
    }
    final nickname = await ref.read(myNicknameProvider.future);
    if (!mounted) return;
    if (nickname == null) {
      debugPrint('🚪 appOpenAd: skipped (onboarding incomplete)');
      return;
    }

    // Waits for the real tier instead of trusting whatever's cached at this
    // exact instant — the fixed post-splash delay above was found to still
    // lose the race against Supabase's DB round-trip on real devices (see
    // resolveSubscriptionTier's doc comment), showing the ad to a
    // premium/admin user. Bounded internally so this can't hang forever.
    final tier = await resolveSubscriptionTier(ref);
    if (!mounted) return;
    debugPrint('🚪 appOpenAd: tier=$tier');
    if (tier.isPremiumOrAdmin) {
      debugPrint('🚪 appOpenAd: skipped (premium/admin)');
      return;
    }
    final cooldown = ref.read(appOpenAdCooldownProvider);
    final ready = await cooldown.isReady;
    debugPrint('🚪 appOpenAd: cooldown ready=$ready');
    if (!ready) return;
    if (!mounted) return;
    await cooldown.recordShown();
    debugPrint('🚪 appOpenAd: showAppOpen()');
    await ref.read(adServiceProvider).showAppOpen();
    debugPrint('🚪 appOpenAd: dismissed');
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
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
                  palette.backgroundGradient != null ||
                      palette.background != null
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness:
                  palette.backgroundGradient != null ||
                      palette.background != null
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: Container(
              decoration: BoxDecoration(
                // Priority: a themed gradient, else a themed flat color,
                // else Standard's own default gradient. Mirrors the
                // 3-way fallback every screen used to hand-roll itself.
                gradient:
                    palette.backgroundGradient ??
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
