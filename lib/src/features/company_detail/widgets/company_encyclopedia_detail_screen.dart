import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Company Encyclopedia article reader — full-screen text view for one of
// the two "Company History" rows. Content is authored offline as light
// markdown (a single leading "# Headline" + "**bold**" emphasis inside
// paragraphs, nothing else) — a real markdown package felt like overkill
// for two constructs, so this does its own tiny parse instead of adding a
// new dependency.
// ---------------------------------------------------------------------------

class CompanyEncyclopediaDetailScreen extends ConsumerWidget {
  final String rowLabel;
  final String symbol;
  final String companyName;
  final String text;
  final AppPalette palette;

  const CompanyEncyclopediaDetailScreen({
    super.key,
    required this.rowLabel,
    required this.symbol,
    required this.companyName,
    required this.text,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final blocks = text.trim().split(RegExp(r'\n\s*\n'));
    String? headline;
    var bodyBlocks = blocks;
    if (blocks.isNotEmpty && blocks.first.trimLeft().startsWith('# ')) {
      headline = blocks.first.trimLeft().substring(2).trim();
      bodyBlocks = blocks.sublist(1);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          rowLabel.toUpperCase(),
          palette,
          GoogleFonts.inter(
            fontSize: 16,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      companyName.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: palette.accentPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      final logoAsync = ref.watch(cachedLogoProvider(symbol));
                      return Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.accentPrimary.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: logoAsync.when(
                            data: (url) =>
                                CompanyLogo(ticker: symbol, logoUrl: url, radius: 25),
                            error: (_, _) => CompanyLogo(ticker: symbol, radius: 25),
                            loading: () => CompanyLogo(ticker: symbol, radius: 25),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (headline != null) ...[
                const SizedBox(height: 8),
                Text(
                  headline,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: palette.textHeader,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              for (final block in bodyBlocks) ...[
                Text.rich(
                  TextSpan(children: _parseInlineBold(block.trim())),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.6,
                    // Plain white under Luxury Gold's dark backdrop — the
                    // usual muted textBody read as too low-contrast for a
                    // long article (accessibility ask, not just taste).
                    // Standard's light backdrop has the same problem in
                    // reverse (gray textBody on near-white), so it gets
                    // textHeader (near-black) instead — same fix, opposite
                    // direction. Other dark-card themes (B&W, Light Lime,
                    // Midnight Sea) keep textBody as-is.
                    color: palette.titleGradient != null
                        ? Colors.white
                        : palette.background == null
                            ? palette.textHeader
                            : palette.textBody,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    l10n.companyEncyclopediaDisclaimerTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: palette.textBody.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.companyEncyclopediaDisclaimerBody,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: palette.textBody.withValues(alpha: 0.5),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Splits `**bold**` spans out of one paragraph's plain text into a bold
  /// [TextSpan] list, everything else left as regular-weight spans.
  List<InlineSpan> _parseInlineBold(String paragraph) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var lastEnd = 0;
    for (final match in pattern.allMatches(paragraph)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: paragraph.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(fontWeight: FontWeight.w800, color: palette.textHeader),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < paragraph.length) {
      spans.add(TextSpan(text: paragraph.substring(lastEnd)));
    }
    return spans;
  }
}
