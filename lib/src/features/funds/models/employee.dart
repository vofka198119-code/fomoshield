// ---------------------------------------------------------------------------
// Employee models — ETF Fund Emulation, Phase 3 (docs/ETF_FUND_EMULATION.md).
// Mirrors the shapes returned by scanco-backend's employeeService.js/
// fundTeamService.js — see src/routes/employees.js, src/routes/invitations.js
// and the /funds/:id/team, /funds/:id/invitations routes in that repo.
// ---------------------------------------------------------------------------

const List<String> employeeRoles = [
  'analyst',
  'co_manager',
  'trader',
  'risk_manager',
];

class EmployeeProfile {
  final String userId;
  final String nickname;
  final String? bio;
  final String? language;
  // Migration 018 (2026-09-12) — a wishlist entry from the same [employeeRoles]
  // list fundTeamService hires against, never validated against any fund's
  // actual open roles.
  final String? desiredRole;
  final bool availableForHire;
  final int approvedProposalsCount;
  final int rejectedProposalsCount;
  final int fundsChangedCount;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeProfile({
    required this.userId,
    required this.nickname,
    this.bio,
    this.language,
    this.desiredRole,
    required this.availableForHire,
    required this.approvedProposalsCount,
    required this.rejectedProposalsCount,
    required this.fundsChangedCount,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) => EmployeeProfile(
    userId: json['userId'] as String,
    nickname: json['nickname'] as String,
    bio: json['bio'] as String?,
    language: json['language'] as String?,
    desiredRole: json['desiredRole'] as String?,
    availableForHire: json['availableForHire'] as bool,
    approvedProposalsCount: json['approvedProposalsCount'] as int,
    rejectedProposalsCount: json['rejectedProposalsCount'] as int,
    fundsChangedCount: json['fundsChangedCount'] as int,
    rating: (json['rating'] as num?)?.toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class FundTeamMember {
  final String userId;
  final String? nickname;
  final String? bio;
  final String role;
  final Map<String, bool> permissions;
  final double? treasurerLimitAmount;
  final String status; // 'active' | 'pending_termination'
  final DateTime? terminationNoticeAt;
  final DateTime joinedAt;

  const FundTeamMember({
    required this.userId,
    this.nickname,
    this.bio,
    required this.role,
    required this.permissions,
    this.treasurerLimitAmount,
    required this.status,
    this.terminationNoticeAt,
    required this.joinedAt,
  });

  bool get isPendingTermination => status == 'pending_termination';

  factory FundTeamMember.fromJson(Map<String, dynamic> json) => FundTeamMember(
    userId: json['userId'] as String,
    nickname: json['nickname'] as String?,
    bio: json['bio'] as String?,
    role: json['role'] as String,
    permissions: Map<String, bool>.from(
      (json['permissions'] as Map?)?.cast<String, dynamic>() ?? {},
    ),
    treasurerLimitAmount: (json['treasurerLimitAmount'] as num?)?.toDouble(),
    status: json['status'] as String,
    terminationNoticeAt: json['terminationNoticeAt'] != null
        ? DateTime.parse(json['terminationNoticeAt'] as String)
        : null,
    joinedAt: DateTime.parse(json['joinedAt'] as String),
  );
}

class FundInvitation {
  final String id;
  final String fundId;
  final String? fundName;
  final String? fundTicker;
  final double? fundApproxAum;
  final String role;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const FundInvitation({
    required this.id,
    required this.fundId,
    this.fundName,
    this.fundTicker,
    this.fundApproxAum,
    required this.role,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory FundInvitation.fromJson(Map<String, dynamic> json) => FundInvitation(
    id: json['id'] as String,
    fundId: json['fundId'] as String,
    fundName: json['fundName'] as String?,
    fundTicker: json['fundTicker'] as String?,
    fundApproxAum: (json['fundApproxAum'] as num?)?.toDouble(),
    role: json['role'] as String,
    message: json['message'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    respondedAt: json['respondedAt'] != null
        ? DateTime.parse(json['respondedAt'] as String)
        : null,
  );
}

// Migration 019 — one row per fund stint (open or closed), the "companies
// I've worked for" record. fund_team_members only tracks CURRENT
// membership (the row disappears on departure); this is the durable log
// leaveType/leftAt survive that deletion in.
class EmploymentRecord {
  final String fundId;
  final String? fundName;
  final String? fundTicker;
  final String role;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final String? leaveType; // 'resigned' | 'terminated' | null (still active)

  const EmploymentRecord({
    required this.fundId,
    this.fundName,
    this.fundTicker,
    required this.role,
    required this.joinedAt,
    this.leftAt,
    this.leaveType,
  });

  bool get isActive => leftAt == null;

  factory EmploymentRecord.fromJson(Map<String, dynamic> json) => EmploymentRecord(
    fundId: json['fundId'] as String,
    fundName: json['fundName'] as String?,
    fundTicker: json['fundTicker'] as String?,
    role: json['role'] as String,
    joinedAt: DateTime.parse(json['joinedAt'] as String),
    leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt'] as String) : null,
    leaveType: json['leaveType'] as String?,
  );
}
