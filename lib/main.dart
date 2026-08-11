import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/cache/sector_providers.dart';
import 'src/core/router/app_router.dart';
import 'src/core/supabase/supabase_client.dart';
import 'src/core/theme/theme_v2.dart';
import 'src/features/orders/pending_orders_checker.dart';
import 'src/features/update/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Must be called exactly once, before any other GoogleSignIn method.
  await GoogleSignIn.instance.initialize(
    clientId: SupabaseConfig.googleIosClientId,
    serverClientId: SupabaseConfig.googleWebClientId,
  );

  // Hydrate the stress-test engine's synchronous GICS-sector cache from
  // disk before the UI (and any resumed simulation ticks) can run — see
  // resolveGicsSector's live-cache check in gics_sector_mapper.dart. A
  // manual ProviderContainer lets this finish before runApp, instead of
  // racing the app's first frame with a fire-and-forget read.
  final container = ProviderContainer();
  await container.read(sectorRepositoryProvider).hydrateLiveCache();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ScanCoApp(),
    ),
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
    // Auto-update: show dialog after 5 seconds — it starts in CHECKING
    // state (spinner) and calls the GitHub Releases API internally.
    // Non-blocking — user can dismiss at any time.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => const UpdateDialog(),
        );
      }
    });

    // Delayed so this doesn't compete with everything else the first
    // frame already loads (widget order providers, home widgets, sector
    // cache hydration, ...) — the CPU spike right at cold start is real.
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) checkPendingOrders(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'F.O.M.O. Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeV2.lightTheme,
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
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
