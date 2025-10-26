class MoldReport {
	final String id;
	final String userId;
	final String? assignedMycologistId;
	final List<MoldReportDetails> caseDetails;
	final String host;
	final String caseName;
	final DateTime? dateObserved;
	final String status;
	final bool isArchived;

	MoldReport({
		required this.id,
		required this.userId,
		this.assignedMycologistId,
		required this.caseDetails,
		required this.host,
		required this.caseName,
		this.dateObserved,
		required this.status,
		required this.isArchived,
	});

	factory MoldReport.fromJson(Map<String, dynamic> json) {
		print('MoldReport.fromJson: parsing json: $json');
		
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
		print('MoldReport.fromJson: parsed id="$parsedId", userId="${json['user_id']}", caseName="${json['case_name']}", host="${json['host']}"');

		return MoldReport(
			id: parsedId,
			userId: json['user_id']?.toString() ?? '',
			assignedMycologistId: json['assigned_mycologist_id']?.toString(),
			caseDetails: parsedCaseDetails,
			host: json['host']?.toString() ?? '',
			caseName: json['case_name']?.toString() ?? '',
			dateObserved: _parseDateObserved(json['date_observed']),
			status: json['status']?.toString() ?? '',
			isArchived: json['is_archived'] == null
				? false
				: (json['is_archived'] is bool
					? json['is_archived'] as bool
					: (json['is_archived'].toString() == '1' || json['is_archived'].toString().toLowerCase() == 'true')),
		);
	}

	/// Parse date_observed which may come as:
	/// - ISO8601 string
	/// - integer milliseconds / seconds
	/// - Firestore-like map { seconds: ..., nanoseconds: ... } or {_seconds, _nanoseconds}
	static DateTime? _parseDateObserved(dynamic raw) {
		if (raw == null) return null;
		// Backend now returns ISO8601 strings for date_observed. Keep parsing
		// minimal: accept DateTime or ISO string only.
		if (raw is DateTime) return raw.toUtc();
		if (raw is String) {
			try {
				return DateTime.parse(raw).toUtc();
			} catch (_) {
				return null;
			}
		}
		return null;
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'user_id': userId,
			'assigned_mycologist_id': assignedMycologistId,
			'case_details': caseDetails.map((e) => e.toJson()).toList(),
			'host': host,
			'case_name': caseName,
			'date_observed': dateObserved?.toUtc().toIso8601String(),
			'status': status,
			'is_archived': isArchived,
		};
	}
}

class MoldReportDetails {
	final List<String> coverPhoto;
	final String description;

	MoldReportDetails({required this.coverPhoto, required this.description});

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

		return MoldReportDetails(
			coverPhoto: covers,
			description: json['description']?.toString() ?? '',
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'cover_photo': coverPhoto,
			'description': description,
		};
	}
}