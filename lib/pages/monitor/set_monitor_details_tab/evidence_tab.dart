import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
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
  final TextEditingController macroCharacteristicsController;
  final String? microscopicImagePath;
  final String? macroscopicImagePath;
  final VoidCallback onCaptureMicro;
  final VoidCallback onCaptureMacro;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

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
    required this.macroCharacteristicsController,
    this.microscopicImagePath,
    this.macroscopicImagePath,
    required this.onCaptureMicro,
    required this.onCaptureMacro,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final hasMicroscopicImage = _isNotBlank(microscopicImagePath);
    final hasMacroscopicImage = _isNotBlank(macroscopicImagePath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location Gathered',
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
                          child: _buildEvidencePreviewImage(microscopicImagePath!),
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
                  : _buildUnifiedEmptyCaptureCard(
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
                              child: _buildEvidencePreviewImage(macroscopicImagePath!),
                            ),
                            // Refined Glassmorphic Retake
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildGlassRetake(onCaptureMacro),
                            ),
                          ],
                        )
                      : _buildUnifiedEmptyCaptureCard(
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
                            _buildDataTile("Color", macroColorController.text, Icons.palette_outlined),
                            const SizedBox(width: 12),
                            _buildDataTile("Texture", macroTextureController.text, Icons.texture_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch, 
                          children: [
                            _buildDataTile(
                              "Symptoms",
                              macroSymptomsController.text,
                              Icons.healing_outlined,
                            ),
                            const SizedBox(width: 12),
                            _buildDataTile(
                              "Characteristics",
                              macroCharacteristicsController.text,
                              Icons.science_outlined,
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
                onPressed: onSubmit,
                buttonText: 'Save Changes',
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

/// Renders an evidence image from either a local file path or a remote URL.
///
/// [imagePath] can be a local file path (from camera/gallery) or a URL.
/// This ensures the UI is fetch-ready for backend integration.
Widget _buildEvidencePreviewImage(String imagePath) {
  final normalized = imagePath.trim();
  final isRemote = normalized.startsWith('http://') || normalized.startsWith('https://');

  if (isRemote) {
    return Image.network(
      normalized,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
      loadingBuilder: (context, child, loadingProgress) {
        // Return the image once loading is complete
        if (loadingProgress == null) return child;
        // Show the shimmer-like loader during network fetch
        return _buildImageFallback(showLoader: true);
      },
    );
  }

  return Image.file(
    File(normalized),
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _buildImageFallback(),
  );
}

/// Provides a placeholder when an image is loading or fails to load.
///
/// [showLoader] toggles between a simple broken image icon and a progress indicator.
Widget _buildImageFallback({bool showLoader = false}) {
  return Container(
    color: MoldifyColors.primaryColor.withValues(alpha: 0.08),
    alignment: Alignment.center,
    child: showLoader
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(
            Icons.broken_image_outlined,
            color: MoldifyColors.primaryColor,
            size: 28,
          ),
  );
}

/// Builds a tonal data tile to display identification results (Color, Texture, etc.).
///
/// This uses a monochromatic Primary-on-Taupe style to avoid "ugly" white clashes.
/// [label] The header text (e.g., "Color").
/// [value] The data to display (e.g., "Yellowish").
/// [icon] The descriptive icon for the tile.
Widget _buildDataTile(String label, String value, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Recessed tonal look to blend with the Taupe card
        color: MoldifyColors.primaryColor.withValues(alpha: 0.04), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: MoldifyColors.primaryColor),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(), 
            style: TextStyle(
              fontSize: 9, 
              color: MoldifyColors.primaryColor.withValues(alpha: 0.5), 
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            )
          ),
          const SizedBox(height: 4),
          Text(
            _isNotBlank(value) ? value : "---",
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-SemiBold', 
              fontSize: 14,
              color: MoldifyColors.primaryColor,
            ),
          ),
        ],
      ),
    ),
  );
}

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

/// Displays an inviting placeholder state when no image has been captured yet.
///
/// [message] The hint text to guide the user (e.g., "Tap to capture image").
Widget _buildUnifiedEmptyCaptureCard({required String message}) {
  return Container(
    width: double.infinity,
    height: 100,
    decoration: BoxDecoration(
      color: MoldifyColors.primaryColor.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: MoldifyColors.primaryColor.withValues(alpha: 0.1),
        width: 1.5,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.biotech_outlined,
          color: MoldifyColors.primaryColor.withValues(alpha: 0.4),
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            color: MoldifyColors.primaryColor.withValues(alpha: 0.5),
            fontFamily: 'Bricolage-Grotesque-Regular',
          ),
        ),
      ],
    ),
  );
}