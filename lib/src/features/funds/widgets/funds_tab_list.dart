import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund.dart';
import '../providers/fund_providers.dart';

// ---------------------------------------------------------------------------
// Funds Tab List — the Search screen's "Funds" tab (ETF Fund Emulation,
// Phase 1). Flat list ordered by creation date for now; New/Popular/Top-
// by-Capitalization rankings (design doc section 4) are a later phase.
//
// Search box filters client-side over the already-fetched list — Phase 1's
// fund counts are small enough that a dedicated backend search endpoint
// isn't worth it yet; add one if/when the funds table actually grows large.
// ---------------------------------------------------------------------------

class FundsTabList extends ConsumerStatefulWidget {
  final AppPalette palette;

  const FundsTabList({super.key, required this.palette});

  @override
  ConsumerState<FundsTabList> createState() => _FundsTabListState();
}

class _FundsTabListState extends ConsumerState<FundsTabList> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Fund> _filter(List<Fund> funds) {
    if (_query.isEmpty) return funds;
    final q = _query.toLowerCase();
    return funds
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.ticker.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final fundsAsync = ref.watch(fundsListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          // Same recipe as the Companies tab's search field (search_screen.dart)
          // for visual consistency between the two tabs.
          child: themedBorder(
            palette: palette,
            borderRadius: ThemeV2.borderRadiusMedium,
            child: Container(
              decoration: BoxDecoration(
                gradient: palette.windowGradient,
                borderRadius: ThemeV2.borderRadiusMedium,
              ),
              child: TextField(
                controller: _controller,
                onChanged: (q) => setState(() => _query = q.trim()),
                decoration: InputDecoration(
                  filled: false,
                  hintText: l10n.etfFundsSearchHint,
                  hintStyle: GoogleFonts.inter(
                    color: palette.textBody,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: palette.textBody,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: palette.textBody,
                            size: 20,
                          ),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                style: GoogleFonts.inter(
                  color: palette.textHeader,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: fundsAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(color: palette.accentPrimary),
            ),
            error: (_, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.etfFundsListErrorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: palette.textBody,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            data: (allFunds) {
              if (allFunds.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.etfFundsEmptyState,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: palette.textBody,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              final funds = _filter(allFunds);
              if (funds.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.searchNoResults,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: palette.textBody,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: palette.accentPrimary,
                onRefresh: () async => ref.invalidate(fundsListProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: funds.length,
                  separatorBuilder: (_, _) => palette.dividerGradient != null
                      ? themedDivider(palette, indent: 0, endIndent: 0)
                      : const Divider(),
                  itemBuilder: (context, i) =>
                      _FundRow(fund: funds[i], palette: palette),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FundRow extends StatelessWidget {
  final Fund fund;
  final AppPalette palette;

  const _FundRow({required this.fund, required this.palette});

  @override
  Widget build(BuildContext context) {
    final up = fund.navPerUnit >= 10.0; // vs. the $10.00 launch NAV
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: palette.accentPrimary.withValues(alpha: 0.15),
        child: Text(
          fund.ticker.length > 4 ? fund.ticker.substring(0, 4) : fund.ticker,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: palette.accentPrimary,
          ),
        ),
      ),
      title: Text(
        fund.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: palette.textHeader,
        ),
      ),
      subtitle: Text(
        fund.ticker,
        style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${fund.navPerUnit.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
          Text(
            up ? '▲' : '▼',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: up ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      onTap: () => context.push('/funds/${fund.id}'),
    );
  }
}
