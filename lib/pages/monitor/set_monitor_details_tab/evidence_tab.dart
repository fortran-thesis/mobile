import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_data_tile.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_empty_state_card.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_preview_image.dart';
import '../../misc/colors.dart';

/// Final step of monitoring setup where supporting evidence is added.
///
///
/// Parameters:
/// - [locationController]: Field for location gathered.
/// - [microController]: Identified mold/value for initial microscopic evidence.
/// - [macroController]: Additional analysis details for initial macroscopic evidence.
/// - [microColorController]: Read-only color value for microscopic evidence.
/// - [microTextureController]: Read-only texture value for microscopic evidence.
/// - [macroColorController]: Read-only color value for macroscopic evidence.
/// - [macroTextureController]: Read-only texture value for macroscopic evidence.
/// - [microscopicImagePath]: Local path or URL for microscopic preview image.
/// - [macroscopicImagePath]: Local path or URL for macroscopic preview image.
/// - [onCaptureMicro]: Tap/retake callback for microscopic capture.
/// - [onCaptureMacro]: Tap/retake callback for macroscopic capture.
/// - [onSubmit]: Save callback.
/// - [onBack]: Previous step callback.
class EvidenceTab extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController microController;
  final TextEditingController macroController;
  final TextEditingController microColorController;
  final TextEditingController microTextureController;
  final TextEditingController macroColorController;
  final TextEditingController macroTextureController;
  final TextEditingController macroSymptomsController;
  final TextEditingController macroSignsController;
  final TextEditingController macroCharacteristicsController;
  final String? microscopicImagePath;
  final String? macroscopicImagePath;
  final VoidCallback onCaptureMicro;
  final VoidCallback onCaptureMacro;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final bool isSaving;

  const EvidenceTab({
    super.key,
    required this.locationController,
    required this.microController,
    required this.macroController,
    required this.microColorController,
    required this.microTextureController,
    required this.macroColorController,
    required this.macroTextureController,
    required this.macroSymptomsController,
    required this.macroSignsController,
    required this.macroCharacteristicsController,
    this.microscopicImagePath,
    this.macroscopicImagePath,
    required this.onCaptureMicro,
    required this.onCaptureMacro,
    required this.onSubmit,
    required this.onBack,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasMicroscopicImage = _isNotBlank(microscopicImagePath);
    final hasMacroscopicImage = _isNotBlank(macroscopicImagePath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        BuildTextBox(
          hintText: 'Enter location gathered',
          controller: locationController,
          showPassword: false,
        ),
        const SizedBox(height: 16),

      

          // --- Initial Microscopic Section ---
          const Text(
            'Initial Microscopic',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              color: MoldifyColors.primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: onCaptureMicro,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: hasMicroscopicImage ? 200 : 100,
              decoration: BoxDecoration(
                color: MoldifyColors.primaryColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MoldifyColors.primaryColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: hasMicroscopicImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // The preview supports both local file and remote URL paths.
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ObservationPreviewImage(
                            imagePath: microscopicImagePath!,
                          ),
                        ),
                        // Glassmorphic Label Overlay
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              color: Colors.black.withValues(alpha: 0.5),
                              child: Text(
                                microController.text.isNotEmpty 
                                  ? microController.text 
                                  : "Identified: Pending Analysis",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Bricolage-Grotesque-Regular'
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Unified retake action
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildGlassRetake(onCaptureMicro),
                        ),
                      ],
                    )
                  : const ObservationEmptyStateCard(
                      message: 'Tap to capture initial microscopic image',
                    ),
            ),
          ),
          const SizedBox(height: 16),

       // --- Initial Macroscopic Section ---
        const Text(
          'Initial Macroscopic',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Bricolage-Grotesque-SemiBold',
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: onCaptureMacro,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: MoldifyColors.taupe, 
              borderRadius: BorderRadius.circular(24),
              // Use a subtle border in Primary Color to define the shape
              border: Border.all(color: MoldifyColors.primaryColor.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Header Area
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                  child: hasMacroscopicImage
                      ? Stack(
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: ObservationPreviewImage(
                                imagePath: macroscopicImagePath!,
                              ),
                            ),
                            // Refined Glassmorphic Retake
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildGlassRetake(onCaptureMacro),
                            ),
                          ],
                        )
                      : const ObservationEmptyStateCard(
                          message: 'Tap to capture initial macroscopic image',
                        ),
                ),

                // 2. Metadata Area
              if (hasMacroscopicImage)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap Rows in IntrinsicHeight to equalize box heights
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Forces children to fill height
                          children: [
                            ObservationDataTile(
                              label: 'Color',
                              value: macroColorController.text,
                              icon: Icons.palette_outlined,
                            ),
                            const SizedBox(width: 12),
                            ObservationDataTile(
                              label: 'Texture',
                              value: macroTextureController.text,
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
                              value: macroSymptomsController.text,
                              icon: Icons.healing_outlined,
                            ),
                            const SizedBox(width: 12),
                            ObservationDataTile(
                              label: 'Signs',
                              value: macroSignsController.text,
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
                              value: macroCharacteristicsController.text,
                              icon: Icons.science_outlined,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),      
        const SizedBox(height: 40),

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
                onPressed: isSaving ? () {} : onSubmit,
                buttonText: isSaving ? 'Saving Changes...' : 'Save Changes',
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

/// Checks if a string is not null, not empty, and not just whitespace.
/// 
/// Returns [true] if the string has actual content.
bool _isNotBlank(String? value) => value != null && value.trim().isNotEmpty;


/// A glassmorphic button overlay allowing users to re-capture an image.
///
/// Uses [BackdropFilter] to create a premium blurred effect over the image preview.
/// [onTap] The callback to trigger the camera/gallery picker again.
Widget _buildGlassRetake(VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.black.withOpacity(0.4),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text(
                "RETAKE", 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 10, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 0.5
                )
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

