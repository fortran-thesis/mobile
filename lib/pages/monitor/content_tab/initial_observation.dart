import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_data_tile.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_preview_image.dart';

/// Displays the initial microscopic and macroscopic observations captured
/// during the "Set Monitoring Details" step for this mold case.
///
/// This tab is read-only: it presents baseline data and does not allow
/// add/edit actions.
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
/// - [macroCharacteristics]: Comma-separated characteristics value.
class InitialObservationTab extends StatelessWidget {
  final String microscopicImagePath;
  final String macroscopicImagePath;
  final String identifiedMold;
  final String confidence;
  final String macroColor;
  final String macroTexture;
  final String macroSymptoms;
  final String macroCharacteristics;

  const InitialObservationTab({
    super.key,
    required this.microscopicImagePath,
    required this.macroscopicImagePath,
    required this.identifiedMold,
    required this.confidence,
    required this.macroColor,
    required this.macroTexture,
    required this.macroSymptoms,
    required this.macroCharacteristics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Initial Observation',
            style: TextStyle(
              fontFamily: 'Montserrat-Black',
              fontSize: 20,
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Baseline microscopic and macroscopic data captured during setup.',
            style: TextStyle(
              fontFamily: 'Bricolage-Grotesque-Regular',
              fontSize: 12,
              color: MoldifyColors.MoldifyGrey,
            ),
          ),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(23)),
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
      ),
    );
  }
}
