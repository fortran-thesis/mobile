import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import '../../misc/colors.dart';

/// Final step of monitoring setup where supporting evidence is added.
///
/// This tab is "fetch-ready": if image paths come from backend data,
/// both local file paths and remote URLs are supported.
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
                              color: Colors.black.withOpacity(0.5),
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
                  : _buildCaptureEmptyState('Tap to capture initial microscopic image'),
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
              border: Border.all(color: MoldifyColors.primaryColor.withOpacity(0.15)),
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
                      : _buildCaptureEmptyState('Tap to capture initial macroscopic image'),
                ),

                // 2. Metadata Area
                if (hasMacroscopicImage)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildDataTile("Color", macroColorController.text, Icons.palette_outlined),
                            const SizedBox(width: 12),
                            _buildDataTile("Texture", macroTextureController.text, Icons.texture_rounded),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "ANALYSIS DETAILS",
                          style: TextStyle(
                            fontSize: 11, 
                            fontFamily: 'Bricolage-Grotesque-Bold', 
                            color: MoldifyColors.primaryColor.withOpacity(0.5),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          macroController.text.isNotEmpty ? macroController.text : "No additional findings.",
                          style: const TextStyle(
                            fontSize: 14, 
                            color: MoldifyColors.MoldifyBlack,
                            height: 1.5,
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

bool _isNotBlank(String? value) => value != null && value.trim().isNotEmpty;

/// Renders an evidence image from either a local file path or a remote URL.
///
/// This makes the UI fetch-ready when image paths are loaded from backend APIs.
Widget _buildEvidencePreviewImage(String imagePath) {
  final normalized = imagePath.trim();
  final isRemote = normalized.startsWith('http://') || normalized.startsWith('https://');

  if (isRemote) {
    return Image.network(
      normalized,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
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

Widget _buildDataTile(String label, String value, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // No white. We use a very subtle tint of the primary color 
        // to create a "recessed" look against the Taupe background.
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
          // Use the primary color for icons to keep it tonal
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
            value.isNotEmpty ? value : "---",
            style: const TextStyle(
              fontFamily: 'Bricolage-Grotesque-SemiBold', 
              fontSize: 14,
              color: MoldifyColors.primaryColor, // Dark text for readability
            ),
          ),
        ],
      ),
    ),
  );
}
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
            children: [
              Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text("RETAKE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildCaptureEmptyState(String message) {
  return Column(
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
  );
}

