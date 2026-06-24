import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/router/app_router.dart';
import 'src/core/supabase/supabase_client.dart';
import 'src/core/theme/app_theme.dart';

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
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: ScanCoApp()));
}

class ScanCoApp extends ConsumerWidget {
  const ScanCoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'F.O.M.O. Shield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
