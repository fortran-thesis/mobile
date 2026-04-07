import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import '../../misc/colors.dart';

/// First step of the monitoring setup flow.
///
/// Parameters:
/// - [startDateController]: Controller for the selected start date.
/// - [endDateController]: Read-only end date from case assignment.
/// - [dateObservationController]: Controller for date of observation.
/// - [onSelectStartDate]: Callback for opening date picker.
/// - [onSelectDateObservation]: Callback for opening date picker for observation.
/// - [onNext]: Callback for moving to the next step.
class ScheduleTab extends StatelessWidget {
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController dateObservationController;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectDateObservation;
  final VoidCallback onNext;

  const ScheduleTab({
    super.key,
    required this.startDateController,
    required this.endDateController,
    required this.dateObservationController,
    required this.onSelectStartDate,
    required this.onSelectDateObservation,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Date',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Enter start date',
          controller: startDateController,
          showPassword: false,
          rightIcon: FontAwesomeIcons.solidCalendar,
          rightIconColor: MoldifyColors.accentColor,
          readOnly: true,
          onTap: onSelectStartDate,
        ),
        const SizedBox(height: 16),

        const Text(
          'End Date',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Enter end date',
          controller: endDateController,
          showPassword: false,
          rightIcon: FontAwesomeIcons.solidCalendar,
          rightIconColor: MoldifyColors.accentColor,
          readOnly: true,
        ),
        const SizedBox(height: 16),

        const Text(
          'Date Observation',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Enter date of observation',
          controller: dateObservationController,
          showPassword: false,
          rightIcon: FontAwesomeIcons.solidCalendar,
          rightIconColor: MoldifyColors.accentColor,
          readOnly: true,
          onTap: onSelectDateObservation,
        ),
        const SizedBox(height: 30),

        BuildButton(
          onPressed: onNext,
          buttonText: 'Next',
          backgroundColor: MoldifyColors.primaryColor,
          textColor: Colors.white,
          buttonHeight: 45,
          buttonRadius: 10,
          buttonWidth: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }
}