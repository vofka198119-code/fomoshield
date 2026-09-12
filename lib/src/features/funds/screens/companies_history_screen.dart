import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../providers/employee_providers.dart';
import '../widgets/company_history_tile.dart';

// ---------------------------------------------------------------------------
// Companies — full employment-history list, reached via the "More" button
// on EmployeeHubScreen's own Companies widget. Same CardFrame shell as
// portfolio_trade_history_screen.dart (that screen's own "full history"
// convention); no batch-reveal here since a single account's fund-history
// list is expected to be short, unlike a trade log.
// ---------------------------------------------------------------------------

class CompaniesHistoryScreen extends ConsumerWidget {
  const CompaniesHistoryScreen({super.key});

  String _roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'co_manager':
        return l10n.etfRoleCoManager;
      case 'trader':
        return l10n.etfRoleTrader;
      case 'risk_manager':
        return l10n.etfRoleRiskManager;
      default:
        return l10n.etfRoleAnalyst;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final historyAsync = ref.watch(myEmploymentHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.etfEmployeeHubCompaniesTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: historyAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundsListErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (history) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: CardFrame(
              padding: EdgeInsets.zero,
              decoration: FomoShieldTheme.cardDecoration,
              palette: palette,
              child: Column(
                children: [
                  for (int i = 0; i < history.length; i++)
                    CompanyHistoryTile(
                      fundName: history[i].fundName ?? history[i].fundTicker ?? '—',
                      fundTicker: history[i].fundTicker ?? '',
                      roleLabel: _roleLabel(l10n, history[i].role),
                      isActive: history[i].isActive,
                      palette: palette,
                      showDivider: i != history.length - 1,
                      onTap: () => context.push(
                        '/funds/employment-history/detail',
                        extra: history[i],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
