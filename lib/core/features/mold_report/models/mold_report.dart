class MoldReport {
	final String id;
	final String userId;
	final String? assignedMycologistId;
	final List<MoldReportDetails> caseDetails;
	final String host;
	final String caseName;
	final String? location;
	final DateTime? createdAt;
	final DateTime? dateObserved;
	final String status;
	final bool isArchived;
	final String? priority; // "low" | "medium" | "high" — populated by list endpoints

	MoldReport({
		required this.id,
		required this.userId,
		this.assignedMycologistId,
		required this.caseDetails,
		required this.host,
		required this.caseName,
		this.location,
		this.createdAt,
		this.dateObserved,
		required this.status,
		required this.isArchived,
		this.priority,
	});

	factory MoldReport.fromJson(Map<String, dynamic> json) {
		
		// defensive parsing for case_details which may be a List, a Map wrapping a list,
		// or a single object depending on backend shape
		final rawCaseDetails = json['case_details'];
		List<MoldReportDetails> parsedCaseDetails = <MoldReportDetails>[];
		if (rawCaseDetails is List) {
			parsedCaseDetails = rawCaseDetails
				.map((e) => MoldReportDetails.fromJson(e as Map<String, dynamic>))
				.toList();
		} else if (rawCaseDetails is Map<String, dynamic>) {
			// Some backends may wrap the list under a 'data' key or provide a single object
			if (rawCaseDetails['data'] is List) {
				parsedCaseDetails = (rawCaseDetails['data'] as List)
					.map((e) => MoldReportDetails.fromJson(e as Map<String, dynamic>))
					.toList();
			} else {
				// treat as single entry
				parsedCaseDetails = [MoldReportDetails.fromJson(rawCaseDetails)];
			}
		}

		final parsedId = json['id']?.toString() ?? json['_id']?.toString() ?? json['report_id']?.toString() ?? '';

		return MoldReport(
			id: parsedId,
			userId: json['user_id']?.toString() ?? '',
			assignedMycologistId: json['assigned_mycologist_id']?.toString(),
			caseDetails: parsedCaseDetails,
			host: json['host']?.toString() ?? '',
			caseName: json['case_name']?.toString() ?? '',
			location: json['location']?.toString(),
			createdAt: _parseTimestamp(json['created_at']),
			dateObserved: _parseDateObserved(json['date_observed']),
			status: json['status']?.toString() ?? '',
			isArchived: json['is_archived'] == null
				? false
				: (json['is_archived'] is bool
					? json['is_archived'] as bool
					: (json['is_archived'].toString() == '1' || json['is_archived'].toString().toLowerCase() == 'true')),
			priority: json['priority']?.toString(),
		);
	}

	/// Parse date_observed which may come as:
	/// - ISO8601 string
	/// - integer milliseconds / seconds
	/// - Firestore-like map { seconds: ..., nanoseconds: ... } or {_seconds, _nanoseconds}
	static DateTime? _parseTimestamp(dynamic raw) {
		if (raw == null) return null;
		if (raw is DateTime) return raw.toUtc();
		if (raw is String) {
			try {
				return DateTime.parse(raw).toUtc();
			} catch (_) {
				return null;
			}
		}
		if (raw is int) {
			final milliseconds = raw > 9999999999 ? raw : raw * 1000;
			return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
		}
		if (raw is Map<String, dynamic>) {
			final seconds = raw['_seconds'] ?? raw['seconds'];
			if (seconds is int) {
				return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
			}
		}
		return null;
	}

	static DateTime? _parseDateObserved(dynamic raw) {
		return _parseTimestamp(raw);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'user_id': userId,
			'assigned_mycologist_id': assignedMycologistId,
			'case_details': caseDetails.map((e) => e.toJson()).toList(),
			'host': host,
			'case_name': caseName,
			'location': location,
			'created_at': createdAt?.toUtc().toIso8601String(),
			'date_observed': dateObserved?.toUtc().toIso8601String(),
			'status': status,
			'is_archived': isArchived,
			'priority': priority,
		};
	}
}

class MoldReportDetails {
	final List<String> coverPhoto;
	final String description;
	final String? priority; // may come from 'priority' or nested 'mold_case.priority'

	MoldReportDetails({required this.coverPhoto, required this.description, this.priority});

	factory MoldReportDetails.fromJson(Map<String, dynamic> json) {
		final rawCovers = json['cover_photo'];
		List<String> covers = <String>[];
		if (rawCovers is List) {
			covers = rawCovers.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
		} else if (rawCovers is String) {
			// single URL string
			if (rawCovers.isNotEmpty) covers = [rawCovers];
		} else if (rawCovers is Map<String, dynamic>) {
			// sometimes wrapped under 'data' or similar
			if (rawCovers['data'] is List) {
				covers = (rawCovers['data'] as List).map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
			}
		}

		// Extract priority from possible locations in the payload
		String? parsedPriority;
		if (json['priority'] != null) {
			parsedPriority = json['priority']?.toString();
		} else if (json['mold_case'] is Map<String, dynamic>) {
			parsedPriority = (json['mold_case'] as Map<String, dynamic>)['priority']?.toString();
		} else if (json['case'] is Map<String, dynamic>) {
			// some backends might nest under 'case'
			parsedPriority = (json['case'] as Map<String, dynamic>)['priority']?.toString();
		}

		return MoldReportDetails(
			coverPhoto: covers,
			description: json['description']?.toString() ?? '',
			priority: parsedPriority == null || parsedPriority.isEmpty ? null : parsedPriority,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'cover_photo': coverPhoto,
			'description': description,
			'priority': priority,
		};
	}
}