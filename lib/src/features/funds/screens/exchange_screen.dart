import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../widgets/candidates_lane.dart';
import '../widgets/my_listing_card.dart';
import '../widgets/vacancies_lane.dart';

// ---------------------------------------------------------------------------
// The Exchange — one screen with both sides of hiring, merged from two
// (2026-10-10). It was a vacancy board living in the employee's own profile
// and a candidate list buried inside a fund, neither aware of the other, and
// one of them was even called "БИРЖА ВАКАНСИЙ" while listing people. His
// verdict: "ты увел в две разные стороны то что должно быть одно целое".
//
// Both lanes are open to everyone. A head reading what other funds offer is
// useful, and so is a candidate seeing who else is out there -- what changes
// with [fundId] is only the ability to ACT: hiring needs a fund to hire into,
// so Invite appears on the candidates lane only when the screen was opened
// from one.
//
// The tab strip is Search's own (search_screen.dart): labels with an accent
// underline over a PageView, so the two swipe the way Companies and Funds
// already do.
// ---------------------------------------------------------------------------

enum ExchangeLane { vacancies, candidates }

class ExchangeScreen extends ConsumerStatefulWidget {
  /// The fund doing the hiring, when opened from a fund's team screen.
  final String? fundId;
  final ExchangeLane initialLane;

  const ExchangeScreen({
    super.key,
    this.fundId,
    this.initialLane = ExchangeLane.vacancies,
  });

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  static const _lanes = ExchangeLane.values;
  late int _index;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _index = _lanes.indexOf(widget.initialLane);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfExchangeTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Above the tabs: whether you are visible here is true of you on
            // either side of the exchange.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: MyListingCard(palette: palette),
            ),
            _tabStrip(l10n, palette),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  VacanciesLane(palette: palette),
                  CandidatesLane(palette: palette, fundId: widget.fundId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabStrip(AppLocalizations l10n, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          for (int i = 0; i < _lanes.length; i++) ...[
            if (i > 0) const SizedBox(width: 20),
            _tabButton(_label(l10n, _lanes[i]), i, palette),
          ],
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n, ExchangeLane lane) => switch (lane) {
    ExchangeLane.vacancies => l10n.etfExchangeTabVacancies,
    ExchangeLane.candidates => l10n.etfExchangeTabCandidates,
  };

  Widget _tabButton(String label, int index, AppPalette palette) {
    final active = _index == index;
    return InkWell(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? palette.accentPrimary : palette.textBody,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 28,
              color: active ? palette.accentPrimary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
