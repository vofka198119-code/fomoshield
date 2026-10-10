import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_sheet.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import 'fund_form_fields.dart';
import 'role_picker_field.dart';
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
  return showAppSheet<bool>(
    context: context,
    palette: palette,
    scrollable: true,
    builder: (ctx) => _SendInviteSheet(
      fundId: fundId,
      profile: profile,
      palette: palette,
      initialMessage: initialMessage,
    ),
  );
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

/// Kept in step with fundTeamService.MAX_INVITE_MESSAGE_LENGTH -- the server
/// is the one that refuses, this only stops the typing.
const int _maxMessageLength = 1000;

class _SendInviteSheetState extends ConsumerState<_SendInviteSheet> {
  late final TextEditingController _messageController;
  // Explicitly the junior role, not employeeRoles.first -- that list is
  // ordered by seniority now, and defaulting an invite to deputy would hand
  // out approval rights on a mis-tap.
  String _role = 'analyst';
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
      setState(
        () => _error = AppLocalizations.of(context)!.etfMarketplaceErrorMessage,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appSheetTitle(l10n.etfSendInviteTitle, palette),
        const SizedBox(height: 14),
        // Which fund is doing the inviting, drawn the way a fund is drawn
        // everywhere else -- ring avatar carrying the ticker, name, then
        // the ticker in full (FundMiniCard's own recipe). An invite that
        // only named the candidate left the fund implicit, and the two
        // names here can even be the same word.
        _fundRow(palette),
        const SizedBox(height: 12),
        Text(
          l10n.etfSendInviteToLabel,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textHeader,
          ),
        ),
        const SizedBox(height: 8),
        // In a box of its own: as plain text it sat between two labels
        // and read as one more of them, which matters more than usual
        // here because a nickname can be any word at all.
        fundFieldWrapper(
          palette,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: palette.textBody,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.profile.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: palette.textHeader,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          l10n.etfSendInviteRoleLabel,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textHeader,
          ),
        ),
        const SizedBox(height: 8),
        RolePickerField(
          palette: palette,
          value: _role,
          onChanged: (role) => setState(() => _role = role),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.etfSendInviteMessageLabel,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textHeader,
          ),
        ),
        const SizedBox(height: 8),
        // The same box as the two fields above it -- it used to draw its
        // own outline, which is why it looked like a different kind of
        // thing on the same sheet.
        fundFieldWrapper(
          palette,
          TextField(
            controller: _messageController,
            maxLines: 4,
            maxLength: _maxMessageLength,
            style: GoogleFonts.inter(fontSize: 14, color: palette.textHeader),
            // The field's own counter would sit INSIDE the box; this
            // keeps it under the box where it was, and where it reads as
            // a note about the field rather than part of it.
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
            decoration: fundFieldDecoration(
              palette,
              hint: l10n.etfSendInviteMessageHint,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (_, value, _) => Text(
              // Counted the way the server counts, not by grapheme:
              // otherwise an emoji reads as one here and as two to the
              // check that actually refuses the message.
              '${value.text.length}/$_maxMessageLength',
              style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
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
    );
  }

  /// The inviting fund, in the app's own fund-row style.
  Widget _fundRow(AppPalette palette) {
    final fund = ref.watch(fundDetailProvider(widget.fundId)).valueOrNull;
    if (fund == null) return const SizedBox.shrink();
    final short = fund.ticker.length > 4
        ? fund.ticker.substring(0, 4)
        : fund.ticker;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: palette.accentPrimary, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 23,
            backgroundColor: palette.accentPrimary.withValues(alpha: 0.15),
            child: Text(
              short,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: palette.accentPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fund.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: palette.textHeader,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fund.ticker,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: palette.textBody,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
