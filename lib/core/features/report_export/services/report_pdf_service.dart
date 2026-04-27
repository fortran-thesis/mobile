import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportPdfService {
  static const MethodChannel _downloadChannel = MethodChannel(
    'com.fortranthesis.moldify/pdf_export',
  );

  String _pdfSafeText(dynamic value, {String fallback = 'N/A'}) {
    final text = _asText(value, fallback: fallback);

    return text
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('₂', '2')
        .replaceAll('₁', '1')
        .replaceAll('₃', '3')
        .replaceAll('₄', '4')
        .replaceAll('₅', '5')
        .replaceAll('₆', '6')
        .replaceAll('₇', '7')
        .replaceAll('₈', '8')
        .replaceAll('₉', '9')
        .replaceAll('₀', '0');
  }

  String _asText(dynamic value, {String fallback = 'N/A'}) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isNotEmpty ? trimmed : fallback;
    }
    if (value is num) return value.toString();
    return fallback;
  }

  List<String> _asList(dynamic value) {
    if (value is List) {
      return value
          .map((entry) => entry.toString().trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }

    if (value is String) {
      return value
          .split(RegExp(r'[,;|\n]'))
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }

    return const [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }
    return <String, dynamic>{};
  }

  String _formatTimestamp(dynamic value) {
    if (value is! String) return 'N/A';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return parsed.toLocal().toString();
  }

  pw.Widget _buildSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          content,
          style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 3),
          textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  Future<Uint8List> buildPdf(Map<String, dynamic> payload) async {
    final pdf = pw.Document();

    final report =
        (payload['report'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final identities =
        (payload['identities'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final sections =
        (payload['sections'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final followUps = payload['follow_ups'] is List
        ? List<Map<String, dynamic>>.from(
            (payload['follow_ups'] as List).whereType<Map>().map(
              (entry) => _asMap(entry),
            ),
          )
        : const <Map<String, dynamic>>[];
    final investigation = _asMap(payload['investigation']);
    final initialObservation = _asMap(investigation['initial_observation']);
    final inVivoLatest = _asMap(investigation['in_vivo_latest']);
    final inVitroLatest = _asMap(investigation['in_vitro_latest']);
    final cultivationLogs = investigation['cultivation_logs'] is List
        ? List<Map<String, dynamic>>.from(
            (investigation['cultivation_logs'] as List).whereType<Map>().map(
              (entry) => _asMap(entry),
            ),
          )
        : const <Map<String, dynamic>>[];

    final affectedHosts = _asList(sections['affected_hosts']);
    final hasInvestigationSnapshot = initialObservation.isNotEmpty ||
        inVivoLatest.isNotEmpty ||
        inVitroLatest.isNotEmpty ||
        cultivationLogs.isNotEmpty;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(26),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.green900,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LABORATORY REPORT',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _asText(report['case_name'], fallback: _asText(report['report_id'])),
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Report Date: ${_asText(report['report_date'])}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Date Observed: ${_asText(report['date_observed'])}',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Host Plant: ${_asText(report['host_plant_affected'])}'),
                pw.Text('Case Status: ${_asText(report['case_status'])}'),
                pw.Text('Confidence Level: ${_asText(report['confidence_level'])}'),
                pw.Text('Reporter: ${_asText(identities['reporter_name'])}'),
                pw.Text('Mycologist: ${_asText(identities['mycologist_name'])}'),
                pw.Text('Location: ${_asText(report['location'])}'),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            _asText(sections['fungus_name'], fallback: 'Pending Identification'),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildSection('Overview', _pdfSafeText(sections['overview'])),
          pw.SizedBox(height: 10),
          _buildSection('Description', _pdfSafeText(sections['description'])),
          pw.SizedBox(height: 10),
          _buildSection('Health Risks', _pdfSafeText(sections['health_risks'])),
          pw.SizedBox(height: 10),
          pw.Text(
            'Affected Crops and Hosts',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 6),
          if (affectedHosts.isEmpty)
            pw.Text(
              'No host records available.',
              style: const pw.TextStyle(fontSize: 10.5),
            )
          else
              ...affectedHosts.map(
              (host) => pw.Bullet(
                text: _pdfSafeText(host),
                style: const pw.TextStyle(fontSize: 10.5),
              ),
            ),
          pw.SizedBox(height: 10),
          _buildSection('Symptoms and Signs', _asText(sections['symptoms_and_signs'])),
          pw.SizedBox(height: 10),
          _buildSection('Disease Cycle', _pdfSafeText(sections['disease_cycle'])),
          pw.SizedBox(height: 10),
          _buildSection('Impact', _pdfSafeText(sections['impact'])),
          pw.SizedBox(height: 10),
          _buildSection('Prevention Summary', _asText(sections['prevention_summary'])),
          pw.SizedBox(height: 12),
          _buildSection('Physical Control', _asText(sections['physical_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Cultural Control', _asText(sections['cultural_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Biological Control', _asText(sections['biological_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Mechanical Control', _asText(sections['mechanical_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Chemical Control', _asText(sections['chemical_control'])),
          if (followUps.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              'Follow-up Timeline',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
            pw.SizedBox(height: 8),
            ...followUps.asMap().entries.map((entry) {
              final followUpIndex = entry.key;
              final followUp = entry.value;
              final photos = _asList(followUp['cover_photo']);

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Follow-up ${followUpIndex + 1} • ${_formatTimestamp(followUp['observed_at'])}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _pdfSafeText(followUp['description'], fallback: 'N/A'),
                      style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 2.5),
                      textAlign: pw.TextAlign.justify,
                    ),
                    if (photos.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Photo attachments: ${photos.length}',
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
          if (hasInvestigationSnapshot) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              'Investigation Snapshot',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Initial Observation',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Microscopic: ${_asText(initialObservation['microscopic_identification'], fallback: _asText(initialObservation['microscopic']))}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Confidence: ${_asText(initialObservation['microscopic_confidence'], fallback: _asText(initialObservation['confidence']))}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Macroscopic: ${_asText(initialObservation['macroscopic_summary'], fallback: _asText(initialObservation['summary']))}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Symptoms: ${_asList(initialObservation['symptoms']).join(', ')}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Signs: ${_asList(initialObservation['signs']).join(', ')}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Characteristics: ${_asList(initialObservation['characteristics']).join(', ')}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            if (inVivoLatest.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Latest In Vivo',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Observed At: ${_formatTimestamp(inVivoLatest['observed_at'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Identified Mold: ${_asText(inVivoLatest['identified_mold'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Confidence: ${_asText(inVivoLatest['confidence'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Summary: ${_asText(inVivoLatest['summary'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Additional Info: ${_asText(inVivoLatest['additional_info'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Culture Name: ${_asText(inVivoLatest['culture_name'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
            if (inVitroLatest.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Latest In Vitro',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Observed At: ${_formatTimestamp(inVitroLatest['observed_at'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Identified Mold: ${_asText(inVitroLatest['identified_mold'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Confidence: ${_asText(inVitroLatest['confidence'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Summary: ${_asText(inVitroLatest['summary'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Additional Info: ${_asText(inVitroLatest['additional_info'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Culture Name: ${_asText(inVitroLatest['culture_name'])}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
            if (cultivationLogs.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                'Cultivation Logs',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
              ),
              pw.SizedBox(height: 6),
              ...cultivationLogs.asMap().entries.map((entry) {
                final log = entry.value;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${_asText(log['type']).toUpperCase()} • ${_formatTimestamp(log['observed_at'])}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Identified Mold: ${_asText(log['identified_mold'], fallback: 'Pending identification')}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Confidence: ${_asText(log['confidence'])}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Summary: ${_asText(log['summary'])}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Additional Info: ${_asText(log['additional_info'])}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Culture Name: ${_asText(log['culture_name'])}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );

    return pdf.save();
  }

  Future<String> sharePdfFromPayload({
    required Map<String, dynamic> payload,
    required String fileName,
  }) async {
    final bytes = await buildPdf(payload);
    
    // Get the Downloads directory
    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Downloads directory not accessible');
    }
    
    // Create the file in the Downloads directory
    final file = File('${downloadsDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
