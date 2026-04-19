import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import '../../misc/colors.dart';

/// Second step of the monitoring setup flow.
///
/// Parameters:
/// - [cropNameController]: Controller for crop/host name.
/// - [typeController]: Selected specimen type controller.
/// - [qtyController]: Numeric quantity controller.
/// - [symptomsController]: Read-only display of selected initial symptoms.
/// - [signsController]: Read-only display of selected initial signs.
/// - [charController]: Read-only display of selected initial characteristics.
/// - [specimenEntries]: Current added specimen+quantity pairs.
/// - [onAddSpecimen]: Adds a new specimen pair.
/// - [onPickType]: Opens specimen type selector.
/// - [onPickSymptoms]: Opens multi-select symptoms selector.
/// - [onPickSigns]: Opens multi-select signs selector.
/// - [onPickCharacteristics]: Opens multi-select characteristics selector.
/// - [onRemoveSpecimen]: Removes a specimen pair by index.
/// - [onNext]: Moves to next step.
/// - [onBack]: Goes to previous step.
class SpecimenTab extends StatelessWidget {
  final TextEditingController cropNameController;
  final TextEditingController typeController;
  final TextEditingController qtyController;
  final TextEditingController symptomsController;
  final TextEditingController signsController;
  final TextEditingController charController;
  final List<Map<String, String>> specimenEntries;
  final VoidCallback onAddSpecimen;
  final VoidCallback onPickType;
  final VoidCallback onPickSymptoms;
  final VoidCallback onPickSigns;
  final VoidCallback onPickCharacteristics;
  final Function(int) onRemoveSpecimen;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SpecimenTab({
    super.key,
    required this.cropNameController,
    required this.typeController,
    required this.qtyController,
    required this.symptomsController,
    required this.signsController,
    required this.charController,
    required this.specimenEntries,
    required this.onAddSpecimen,
    required this.onPickType,
    required this.onPickSymptoms,
    required this.onPickSigns,
    required this.onPickCharacteristics,
    required this.onRemoveSpecimen,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Host Plant Affected',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Enter host plant affected (e.g. tomato, mango)',
          controller: cropNameController,
          showPassword: false,
        ),
        const SizedBox(height: 16),

        const Text(
          'Type of Specimen and Quantity',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: BuildTextBox(
                hintText: 'Select type(s) of specimen',
                controller: typeController,
                showPassword: false,
                rightIcon: FontAwesomeIcons.angleRight,
                rightIconColor: MoldifyColors.accentColor,
                readOnly: true,
                onTap: onPickType,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: BuildTextBox(
                hintText: 'Quantity',
                controller: qtyController,
                showPassword: false,
                keyboardType: TextInputType.number,
                customInputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text(
          'Initial Symptoms',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Select initial symptom(s)',
          controller: symptomsController,
          showPassword: false,
          rightIcon: FontAwesomeIcons.angleRight,
          rightIconColor: MoldifyColors.accentColor,
          readOnly: true,
          onTap: onPickSymptoms,
          isMultiline: true,
        ),
        const SizedBox(height: 16),

        const Text(
          'Initial Signs',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Select initial sign(s)',
          controller: signsController,
          showPassword: false,
          rightIcon: FontAwesomeIcons.angleRight,
          rightIconColor: MoldifyColors.accentColor,
          readOnly: true,
          onTap: onPickSigns,
          isMultiline: true,
        ),
        const SizedBox(height: 16),

        const Text(
          'Initial Characteristics',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Select initial characteristic(s)',
          controller: charController,
          showPassword: false,
          rightIcon: FontAwesomeIcons.angleRight,
          rightIconColor: MoldifyColors.accentColor,
          readOnly: true,
          onTap: onPickCharacteristics,
          isMultiline: true,
        ),
        const SizedBox(height: 30),

        Row(
          children: [
            Expanded(
              child: BuildButton(
                onPressed: onBack,
                buttonText: 'Back',
                backgroundColor: MoldifyColors.taupe,
                textColor: MoldifyColors.primaryColor,
                buttonHeight: 45,
                buttonRadius: 10,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BuildButton(
                onPressed: onNext,
                buttonText: 'Next',
                backgroundColor: MoldifyColors.primaryColor,
                textColor: Colors.white,
                buttonHeight: 45,
                buttonRadius: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}