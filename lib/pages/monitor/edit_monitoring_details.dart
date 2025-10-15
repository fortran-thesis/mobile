import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

import '../misc/appbar/primary_app_bar.dart';

class EditMonitoringDetailsScreen extends StatefulWidget {
  // final String monitoringId;

  EditMonitoringDetailsScreen({super.key});

  @override
  _EditMonitoringDetailsScreenState createState() => _EditMonitoringDetailsScreenState();
}

class _EditMonitoringDetailsScreenState extends State<EditMonitoringDetailsScreen> {
  // late TextEditingController _nameController;
  // late TextEditingController _descriptionController;
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // // Initialize controllers with existing monitoring details
    // _nameController = TextEditingController(text: "Existing Name");
    // _descriptionController =
    //     TextEditingController(text: "Existing Description");
  }

  @override
  void dispose() {
    // _nameController.dispose();
    // _descriptionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Edit Monitoring Details',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            ],
          )
        ),
      )
    );
  }
}