import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/widgets/company_logo.dart';
import '../top_companies_provider.dart';

// ---------------------------------------------------------------------------
// CompanyListSheet — full list behind a lane's "see all", no live price
// ---------------------------------------------------------------------------
// Same no-Finnhub-per-row rule as everywhere else on this screen: rows read
// name from the entry the caller already has (top_companies_provider.dart's
// backend-ranked list) and logo from the permanent local cache — price only
// shows once the user taps through to Company Detail.
// ---------------------------------------------------------------------------

Future<void> showCompanyListSheet(
  BuildContext context,
  String title,
  List<TopCompanyEntry> companies,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CompanyListSheet(title: title, companies: companies),
  );
}

class _CompanyListSheet extends StatelessWidget {
  final String title;
  final List<TopCompanyEntry> companies;

  const _CompanyListSheet({required this.title, required this.companies});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: ThemeV2.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeV2.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ThemeV2.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      '${companies.length}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x0F000000)),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: companies.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 68, color: Color(0x0F000000)),
                  itemBuilder: (context, i) => _CompanyRow(entry: companies[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompanyRow extends ConsumerWidget {
  final TopCompanyEntry entry;

  const _CompanyRow({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoEntry = ref.watch(cachedLogoEntryProvider(entry.symbol)).valueOrNull;
    final sector = resolveGicsSector(entry.symbol, companyName: entry.name);

    return ListTile(
      onTap: () {
        Navigator.of(context).pop();
        context.push('/company/${entry.symbol}');
      },
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ThemeV2.primary, width: 1.5),
        ),
        child: CompanyLogo(
          ticker: entry.symbol,
          logoUrl: logoEntry?.logoUrl,
          domain: logoEntry?.domain,
          radius: 18,
        ),
      ),
      title: Text(
        entry.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ThemeV2.textPrimary,
        ),
      ),
      subtitle: Text(
        sector?.label ?? entry.symbol,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: ThemeV2.textSecondary,
        size: 20,
      ),
    );
  }
}
