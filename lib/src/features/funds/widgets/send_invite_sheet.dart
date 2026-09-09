import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;

// ---------------------------------------------------------------------------
// Send Invite Sheet — head picks a role + writes a message for one
// marketplace profile. Message pre-fills from the fund's own last-used
// template (doc: "приложение сохраняет его как шаблон и автоматически
// подставляет при следующих приглашениях").
// ---------------------------------------------------------------------------

Future<bool?> showSendInviteSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String fundId,
  required EmployeeProfile profile,
  required AppPalette palette,
  String? initialMessage,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SendInviteSheet(
      fundId: fundId,
      profile: profile,
      palette: palette,
      initialMessage: initialMessage,
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

class _SendInviteSheet extends ConsumerStatefulWidget {
  final String fundId;
  final EmployeeProfile profile;
  final AppPalette palette;
  final String? initialMessage;

  const _SendInviteSheet({
    required this.fundId,
    required this.profile,
    required this.palette,
    this.initialMessage,
  });

  @override
  ConsumerState<_SendInviteSheet> createState() => _SendInviteSheetState();
}

class _SendInviteSheetState extends ConsumerState<_SendInviteSheet> {
  late final TextEditingController _messageController;
  String _role = employeeRoles.first;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: widget.initialMessage ?? '',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _error = l10n.etfSendInviteMessageRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(employeeApiServiceProvider)
          .sendInvitation(
            fundId: widget.fundId,
            inviteeUserId: widget.profile.userId,
            role: _role,
            message: message,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FundApiException catch (e) {
      String text;
      switch (e.code) {
        case 'team_full':
          text = l10n.etfSendInviteTeamFullError;
          break;
        case 'already_member':
          text = l10n.etfSendInviteAlreadyMemberError;
          break;
        case 'invite_already_pending':
          text = l10n.etfSendInviteAlreadyPendingError;
          break;
        default:
          text = e.message;
      }
      setState(() => _error = text);
    } catch (_) {
      setState(() => _error = AppLocalizations.of(context)!.etfMarketplaceErrorMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              l10n.etfSendInviteTitle,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.profile.nickname,
              style: GoogleFonts.inter(fontSize: 14, color: palette.textBody),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.etfSendInviteRoleLabel,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: employeeRoles.map((role) {
                final selected = role == _role;
                return ChoiceChip(
                  label: Text(_roleLabel(l10n, role)),
                  selected: selected,
                  onSelected: (_) => setState(() => _role = role),
                  selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
                  labelStyle: GoogleFonts.inter(
                    color: selected
                        ? palette.accentPrimary
                        : palette.textBody,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.etfSendInviteMessageLabel,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 500,
              style: GoogleFonts.inter(color: palette.textHeader),
              decoration: InputDecoration(
                hintText: l10n.etfSendInviteMessageHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.loss),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: ThemeV2.buttonHeight,
              child: Material(
                type: MaterialType.transparency,
                child: themedDarkCtaButtonShell(
                  palette: palette,
                  borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
                  standardDecoration: BoxDecoration(
                    color: ThemeV2.primary,
                    borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
                    onTap: _submitting ? null : _submit,
                    child: Center(
                      child: _submitting
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: themedDarkCtaContentColor(palette),
                              ),
                            )
                          : Text(
                              l10n.etfSendInviteSubmitButton,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: themedDarkCtaContentColor(palette),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
