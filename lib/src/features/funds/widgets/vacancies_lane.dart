import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/employee_providers.dart';
import 'vacancy_card.dart';

// ---------------------------------------------------------------------------
// Vacancies lane — the jobs side of the exchange: every open advert from
// every active fund. Tapping one opens the fund that posted it.
// ---------------------------------------------------------------------------

class VacanciesLane extends ConsumerWidget {
  final AppPalette palette;

  const VacanciesLane({super.key, required this.palette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final boardAsync = ref.watch(vacancyBoardProvider);

    return RefreshIndicator(
      color: palette.accentPrimary,
      onRefresh: () async => ref.invalidate(vacancyBoardProvider),
      child: boardAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: palette.accentPrimary),
        ),
        error: (_, _) => _note(l10n.etfVacancyErrorGeneric),
        data: (vacancies) {
          if (vacancies.isEmpty) return _note(l10n.etfVacancyBoardEmpty);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: vacancies.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VacancyCard(
                vacancy: vacancies[i],
                palette: palette,
                onTap: () => context.push('/funds/${vacancies[i].fundId}'),
              ),
            ),
          );
        },
      ),
    );
  }

  /// A scrollable even when it says nothing, so pull-to-refresh still works
  /// on an empty board -- which is exactly when someone will try it.
  Widget _note(String text) => ListView(
    padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
    children: [
      Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          height: 1.4,
          color: palette.textBody,
        ),
      ),
    ],
  );
}
