class UserReport {
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final String details;

  UserReport({
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'reason': reason,
      'details': details,
    };
  }

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      reporterId: json['reporter_id'],
      reportedUserId: json['reported_user_id'],
      reason: json['reason'],
      details: json['details'],
    );
  }
}
