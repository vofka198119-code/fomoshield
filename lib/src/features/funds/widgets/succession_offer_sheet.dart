import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/supabase/supabase_providers.dart'
    show subscriptionTierProvider, SubscriptionTierAccess;
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund_succession_offer.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import 'etf_premium_required_sheet.dart';

// ---------------------------------------------------------------------------
// Succession Offer Sheet — the tap destination for SuccessionOfferCard.
// Spells out the Phase B rules in plain language BEFORE the button,
// because accepting is easy to misread as "I am now the head": it only
// enters the caller into the running, and seniority decides at the
// deadline. Returns true once the caller has entered.
//
// Premium gate lives here rather than in the error handler: the backend
// happily LISTS the offer to every active team member and only rejects
// the accept with `not_eligible`, so a free-tier user would otherwise tap
// a live-looking button to get an error. Non-premium sees the app's own
// existing ETF paywall sheet instead (showEtfPremiumRequiredSheet).
// ---------------------------------------------------------------------------

/// What an acceptance actually did — the deputy takes the fund on the
/// spot, everyone else only joins the running, and the caller says so.
enum SuccessionAcceptResult { applied, becameHead }

Future<SuccessionAcceptResult?> showSuccessionOfferSheet({
  required BuildContext context,
  required WidgetRef ref,
  required FundSuccessionOffer offer,
  required AppPalette palette,
}) {
  return showModalBottomSheet<SuccessionAcceptResult>(
    context: context,
    backgroundColor: palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (_) => _SuccessionOfferSheet(offer: offer, palette: palette),
  );
}

class _SuccessionOfferSheet extends ConsumerStatefulWidget {
  final FundSuccessionOffer offer;
  final AppPalette palette;

  const _SuccessionOfferSheet({required this.offer, required this.palette});

  @override
  ConsumerState<_SuccessionOfferSheet> createState() =>
      _SuccessionOfferSheetState();
}

class _SuccessionOfferSheetState extends ConsumerState<_SuccessionOfferSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _accept() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final becameHead = await ref
          .read(employeeApiServiceProvider)
          .acceptSuccessionOffer(widget.offer.id);
      if (!mounted) return;
      Navigator.of(context).pop(becameHead ? SuccessionAcceptResult.becameHead : SuccessionAcceptResult.applied);
    } on FundApiException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'offer_not_pending' => l10n.etfSuccessionErrorClosed,
          'not_eligible' => l10n.etfSuccessionErrorNotEligible,
          // Shouldn't normally be reachable -- the backend hides an offer
          // entirely while it's the deputy's alone -- but an offer listed
          // just before the window opened and accepted just after would
          // land here, and "deputy has first refusal" explains itself far
          // better than the raw server sentence.
          'deputy_priority' => l10n.etfSuccessionErrorDeputyFirst,
          _ => e.message,
        };
      });
    } catch (_) {
      setState(() => _error = l10n.etfSuccessionErrorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final offer = widget.offer;
    final locale = Localizations.localeOf(context).toString();
    final deadline = DateFormat.yMMMd(locale).format(offer.deadline.toLocal());
    final isPremium = ref.watch(subscriptionTierProvider).isPremiumOrAdmin;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.displayName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.etfSuccessionSheetIntro,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
          const SizedBox(height: 16),
          _rule(palette, l10n.etfSuccessionRuleDeputyFirst),
          _rule(palette, l10n.etfSuccessionRuleEnterRunning),
          _rule(palette, l10n.etfSuccessionRuleSeniorityWins),
          _rule(palette, l10n.etfSuccessionRuleHeadMayReturn),
          _rule(palette, l10n.etfSuccessionRuleNobodyAccepts),
          _rule(palette, l10n.etfSuccessionRuleMoneyStays),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.etfSuccessionDeadlineLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textBody,
                ),
              ),
              Text(
                deadline,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.textHeader,
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.loss),
            ),
          ],
          const SizedBox(height: 20),
          if (offer.alreadyAccepted)
            Text(
              l10n.etfSuccessionAlreadyAppliedBody,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.accentPrimary,
              ),
            )
          else
            _acceptButton(palette, l10n, isPremium),
        ],
      ),
    );
  }

  Widget _rule(AppPalette palette, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(
            Icons.circle,
            size: 5,
            color: palette.accentPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: palette.textHeader,
            ),
          ),
        ),
      ],
    ),
  );

  /// Same full-width CTA recipe as proposal_card.dart's own primary action
  /// (themedDarkCtaButtonShell) — the one treatment that stays legible on
  /// every admin theme, per the Luxury Gold/Graphite CTA sweep.
  Widget _acceptButton(
    AppPalette palette,
    AppLocalizations l10n,
    bool isPremium,
  ) {
    final radius = ThemeV2.borderRadiusMedium;
    final contentColor = themedDarkCtaContentColor(palette);
    return SizedBox(
      width: double.infinity,
      height: ThemeV2.buttonHeight,
      child: Material(
        type: MaterialType.transparency,
        child: themedDarkCtaButtonShell(
          palette: palette,
          borderRadius: radius,
          standardDecoration: BoxDecoration(
            color: ThemeV2.primary,
            borderRadius: radius,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: _submitting
                ? null
                : () async {
                    if (!isPremium) {
                      await showEtfPremiumRequiredSheet(context, ref);
                      return;
                    }
                    await _accept();
                  },
            child: Center(
              child: _submitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: contentColor,
                      ),
                    )
                  : Text(
                      isPremium
                          ? l10n.etfSuccessionAcceptButton
                          : l10n.etfSuccessionPremiumRequiredButton,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: contentColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
