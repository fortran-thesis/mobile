import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/functions/empty_state.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_data_tile.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_preview_image.dart';

/// Displays the initial microscopic and macroscopic observations captured
/// during the "Set Monitoring Details" step for this mold case.
///
/// This tab presents baseline data and provides a quick action to add
/// initial observations when the case is still open.
///
/// Parameters:
/// - [microscopicImagePath]: Required local file path, asset path, or remote URL
///   for the microscopic image.
/// - [macroscopicImagePath]: Required local file path, asset path, or remote URL
///   for the macroscopic image.
/// - [identifiedMold]: Mold name returned by scan (e.g., Aspergillus fumigatus).
/// - [confidence]: Confidence label (e.g., 87%).
/// - [macroColor]: Macroscopic color value.
/// - [macroTexture]: Macroscopic texture value.
/// - [macroSymptoms]: Comma-separated symptoms value.
/// - [macroSigns]: Comma-separated signs value.
/// - [macroCharacteristics]: Comma-separated characteristics value.
class InitialObservationTab extends StatelessWidget {
  final String microscopicImagePath;
  final String macroscopicImagePath;
  final String identifiedMold;
  final String confidence;
  final String macroColor;
  final String macroTexture;
  final String macroSymptoms;
  final String macroSigns;
  final String macroCharacteristics;
  final bool isCaseClosed;
  final VoidCallback? onAddInitialObservations;

  const InitialObservationTab({
    super.key,
    required this.microscopicImagePath,
    required this.macroscopicImagePath,
    required this.identifiedMold,
    required this.confidence,
    required this.macroColor,
    required this.macroTexture,
    required this.macroSymptoms,
    required this.macroSigns,
    required this.macroCharacteristics,
    this.isCaseClosed = false,
    this.onAddInitialObservations,
  });

  @override
  Widget build(BuildContext context) {
    final hasMicroscopic =
        microscopicImagePath.trim().isNotEmpty ||
        identifiedMold.trim().isNotEmpty ||
        confidence.trim().isNotEmpty;
    final hasMacroscopic =
        macroscopicImagePath.trim().isNotEmpty ||
        macroColor.trim().isNotEmpty ||
        macroTexture.trim().isNotEmpty ||
        macroSymptoms.trim().isNotEmpty ||
        macroSigns.trim().isNotEmpty ||
        macroCharacteristics.trim().isNotEmpty;
    final hasAnyObservation = hasMicroscopic || hasMacroscopic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INITIAL OBSERVATION',
                      style: TextStyle(
                        fontFamily: 'Montserrat-Black',
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: MoldifyColors.primaryColor,
                      ),
                    ),
                    Text(
                      hasAnyObservation
                          ? 'BASELINE CAPTURED'
                          : 'NO ENTRIES FOUND',
                      style: TextStyle(
                        fontFamily: 'Bricolage-Grotesque-Bold',
                        fontSize: 8,
                        letterSpacing: 1.0,
                        color: MoldifyColors.primaryColor.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isCaseClosed &&
                    onAddInitialObservations != null &&
                    !hasAnyObservation)
                  BuildButton(
                    buttonText: 'ADD INITIAL',
                    onPressed: onAddInitialObservations!,
                    backgroundColor: Colors.transparent,
                    textColor: MoldifyColors.primaryColor,
                    leftIcon: FontAwesomeIcons.plus,
                    iconColor: MoldifyColors.primaryColor,
                    iconSize: 10,
                    paddingIconText: 6,
                    buttonHeight: 30,
                    buttonRadius: 0,
                    fontSize: 12,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Baseline microscopic and macroscopic data captured during setup.',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 12,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
          if (!hasAnyObservation) ...[
            const SizedBox(height: 24),
            EmptyState(
              message: 'No entries made yet.',
              icon: Icons.image_not_supported_outlined,
              height: (MediaQuery.of(context).size.height - 430)
                  .clamp(160.0, double.infinity)
                  .toDouble(),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 24),

            const Text(
              'Initial Microscopic',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-SemiBold',
                color: MoldifyColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: MoldifyColors.primaryColor.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ObservationPreviewImage(
                      imagePath: microscopicImagePath,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          color: Colors.black.withValues(alpha: 0.5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  identifiedMold.trim().isNotEmpty
                                      ? identifiedMold
                                      : 'Identified: Pending Analysis',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Bricolage-Grotesque-Regular',
                                  ),
                                ),
                              ),
                              if (confidence.trim().isNotEmpty)
                                Text(
                                  confidence,
                                  style: const TextStyle(
                                    color: MoldifyColors.accentColor,
                                    fontSize: 11,
                                    fontFamily: 'Bricolage-Grotesque-SemiBold',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Initial Macroscopic',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Bricolage-Grotesque-SemiBold',
                color: MoldifyColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MoldifyColors.taupe,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: MoldifyColors.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(23),
                    ),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: ObservationPreviewImage(
                        imagePath: macroscopicImagePath,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ObservationDataTile(
                                label: 'Color',
                                value: macroColor,
                                icon: Icons.palette_outlined,
                              ),
                              const SizedBox(width: 12),
                              ObservationDataTile(
                                label: 'Texture',
                                value: macroTexture,
                                icon: Icons.texture_rounded,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ObservationDataTile(
                                label: 'Symptoms',
                                value: macroSymptoms,
                                icon: Icons.healing_outlined,
                              ),
                              const SizedBox(width: 12),
                              ObservationDataTile(
                                label: 'Signs',
                                value: macroSigns,
                                icon: Icons.visibility_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ObservationDataTile(
                                label: 'Characteristics',
                                value: macroCharacteristics,
                                icon: Icons.science_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}
