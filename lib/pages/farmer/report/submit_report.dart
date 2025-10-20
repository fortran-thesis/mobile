import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}
class _SubmitReportScreenState extends State<SubmitReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Submit Report Screen'),
      ),
    );
  }
}