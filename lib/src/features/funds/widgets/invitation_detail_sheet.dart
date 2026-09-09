import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;

// ---------------------------------------------------------------------------
// Invitation Detail Sheet — the doc's envelope-tap destination: "по тапу
// видит, кто приглашает, инфо о фонде... → кнопки «Присоединиться» /
// «Отказаться»". Returns true if the invitee joined (caller refreshes
// their invitation list either way).
// ---------------------------------------------------------------------------

Future<bool?> showInvitationDetailSheet({
  required BuildContext context,
  required WidgetRef ref,
  required FundInvitation invitation,
  required AppPalette palette,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _InvitationDetailSheet(
      invitation: invitation,
      palette: palette,
    ),
  );
}

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

class _InvitationDetailSheet extends ConsumerStatefulWidget {
  final FundInvitation invitation;
  final AppPalette palette;

  const _InvitationDetailSheet({required this.invitation, required this.palette});

  @override
  ConsumerState<_InvitationDetailSheet> createState() =>
      _InvitationDetailSheetState();
}

class _InvitationDetailSheetState
    extends ConsumerState<_InvitationDetailSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _respond(bool accept) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(employeeApiServiceProvider);
      if (accept) {
        await api.acceptInvitation(widget.invitation.id);
      } else {
        await api.declineInvitation(widget.invitation.id);
      }
      if (!mounted) return;
      Navigator.of(context).pop(accept);
    } on FundApiException catch (e) {
      setState(() {
        _error = e.code == 'team_full'
            ? l10n.etfInvitationTeamFullError
            : e.message;
      });
    } catch (_) {
      setState(() => _error = l10n.etfInvitationsErrorMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final invitation = widget.invitation;

    return Container(
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invitation.fundName ?? invitation.fundTicker ?? '',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
          if (invitation.fundApproxAum != null) ...[
            const SizedBox(height: 4),
            Text(
              formatUsd(invitation.fundApproxAum!),
              style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.etfInvitationDetailRoleLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textBody,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _roleLabel(l10n, invitation.role),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.etfInvitationDetailMessageLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textBody,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            invitation.message,
            style: GoogleFonts.inter(fontSize: 14, color: palette.textHeader),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.loss),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : () => _respond(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: palette.textBody),
                  ),
                  child: Text(
                    l10n.etfInvitationDeclineButton,
                    style: GoogleFonts.inter(color: palette.textBody),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _respond(true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.etfInvitationJoinButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
