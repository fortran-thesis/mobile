import 'package:flutter/material.dart';
import '../../../monitor/content_tab/case_details.dart';

class ReportCaseDetailsTab extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final String farmerName;
  final String dateFirstObserved;
  final String emailAddress;
  final String contactNumber;

  const ReportCaseDetailsTab({
    super.key,
    required this.entries,
    required this.farmerName,
    required this.dateFirstObserved,
    required this.emailAddress,
    required this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: CaseDetailsTab(
        entries: entries,
        farmerName: farmerName,
        dateFirstObserved: dateFirstObserved,
        emailAddress: emailAddress,
        contactNumber: contactNumber,
      ),
    );
  }
}
