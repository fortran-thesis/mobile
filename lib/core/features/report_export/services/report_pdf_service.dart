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
          style: const pw.TextStyle(
            fontSize: 10.5,
            lineSpacing: 3,
          ),
          textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  Future<Uint8List> buildPdf(Map<String, dynamic> payload) async {
    final pdf = pw.Document();

    final report = (payload['report'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final identities =
        (payload['identities'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final sections = (payload['sections'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    final affectedHosts = _asList(sections['affected_hosts']);

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
                  _pdfSafeText(report['case_name'], fallback: _pdfSafeText(report['report_id'])),
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
                pw.Text('Report Date: ${_pdfSafeText(report['report_date'])}',
                  style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Date Observed: ${_pdfSafeText(report['date_observed'])}',
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
                pw.Text('Host Plant: ${_pdfSafeText(report['host_plant_affected'])}'),
                pw.Text('Case Status: ${_pdfSafeText(report['case_status'])}'),
                pw.Text('Confidence Level: ${_pdfSafeText(report['confidence_level'])}'),
                pw.Text('Reporter: ${_pdfSafeText(identities['reporter_name'])}'),
                pw.Text('Mycologist: ${_pdfSafeText(identities['mycologist_name'])}'),
                pw.Text('Location: ${_pdfSafeText(report['location'])}'),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            _pdfSafeText(sections['fungus_name'], fallback: 'Pending Identification'),
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
            pw.Text('No host records available.', style: const pw.TextStyle(fontSize: 10.5))
          else
              ...affectedHosts.map(
              (host) => pw.Bullet(
                text: _pdfSafeText(host),
                style: const pw.TextStyle(fontSize: 10.5),
              ),
            ),
          pw.SizedBox(height: 10),
          _buildSection('Symptoms and Signs', _pdfSafeText(sections['symptoms_and_signs'])),
          pw.SizedBox(height: 10),
          _buildSection('Disease Cycle', _pdfSafeText(sections['disease_cycle'])),
          pw.SizedBox(height: 10),
          _buildSection('Impact', _pdfSafeText(sections['impact'])),
          pw.SizedBox(height: 10),
          _buildSection('Prevention Summary', _pdfSafeText(sections['prevention_summary'])),
          pw.SizedBox(height: 12),
          _buildSection('Physical Control', _pdfSafeText(sections['physical_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Cultural Control', _pdfSafeText(sections['cultural_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Biological Control', _pdfSafeText(sections['biological_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Mechanical Control', _pdfSafeText(sections['mechanical_control'])),
          pw.SizedBox(height: 10),
          _buildSection('Chemical Control', _pdfSafeText(sections['chemical_control'])),
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

    final savedLocation = await _savePdfToDownloads(
      bytes,
      fileName: fileName,
    );

    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'application/pdf', name: fileName)],
      text: 'Laboratory report PDF',
      subject: 'Laboratory Report',
    );

    return savedLocation;
  }

  Future<String> _savePdfToDownloads(
    Uint8List bytes, {
    required String fileName,
  }) async {
    if (Platform.isAndroid) {
      try {
        final savedLocation = await _downloadChannel.invokeMethod<String>(
          'savePdfToDownloads',
          {
            'bytes': bytes,
            'fileName': fileName,
            'subDirectory': 'Moldify',
          },
        );

        if (savedLocation != null && savedLocation.trim().isNotEmpty) {
          return savedLocation;
        }
      } on PlatformException {
        // Fall through to app-scoped storage if public Downloads save fails.
      }
    }

    Directory? targetDirectory = await getDownloadsDirectory();

    targetDirectory ??= await getExternalStorageDirectory();

    targetDirectory ??= await getApplicationDocumentsDirectory();

    final file = File('${targetDirectory.path}/$fileName');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }
}
