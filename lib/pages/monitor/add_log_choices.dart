import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import 'package:moldify/pages/misc/colors.dart';
import 'package:moldify/pages/misc/textboxes/textboxes.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_data_tile.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_empty_state_card.dart';
import 'package:moldify/pages/misc/tiles/initial_observation_components/observation_preview_image.dart';

class AddLogChoicesScreen extends StatefulWidget {
  final String? microscopicImagePath;
  final String? macroscopicImagePath;
  final VoidCallback onCaptureMicro;
  final VoidCallback onCaptureMacro;
  final VoidCallback onSubmit;

  const AddLogChoicesScreen({
    super.key,
    this.microscopicImagePath,
    this.macroscopicImagePath,
    required this.onCaptureMicro,
    required this.onCaptureMacro,
    required this.onSubmit,
  });

  @override
  State<AddLogChoicesScreen> createState() => _AddLogChoicesScreenState();
}

class _AddLogChoicesScreenState extends State<AddLogChoicesScreen> {
  // Controllers specifically for log documentation
  final TextEditingController _microAnalysisController = TextEditingController();
  final TextEditingController _macroColorController = TextEditingController();
  final TextEditingController _macroTextureController = TextEditingController();
  final TextEditingController _macroSymptomsController = TextEditingController();
  final TextEditingController _macroCharacteristicsController = TextEditingController();

  @override
  void dispose() {
    _microAnalysisController.dispose();
    _macroColorController.dispose();
    _macroTextureController.dispose();
    _macroSymptomsController.dispose();
    _macroCharacteristicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMicro = _isNotBlank(widget.microscopicImagePath);
    final hasMacro = _isNotBlank(widget.macroscopicImagePath);

    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: const PrimaryAppBar(title: "Add Log Entry"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(),
            const SizedBox(height: 50),

            // --- MICROSCOPIC SECTION ---
            _buildSectionHeader("MICROSCOPIC EVIDENCE"),
            const SizedBox(height: 25),
            _buildCaptureCard(
              hasImage: hasMicro,
              imagePath: widget.microscopicImagePath,
              onTap: widget.onCaptureMicro,
              statusText: _microAnalysisController.text.isEmpty 
                  ? "Pending Analysis" 
                  : _microAnalysisController.text,
              emptyMsg: "Tap to capture microscopic view",
            ),

            const SizedBox(height: 60),

            // --- MACROSCOPIC SECTION ---
            _buildSectionHeader("MACROSCOPIC EVIDENCE"),
            const SizedBox(height: 25),
            _buildMacroscopicEvidenceBlock(hasMacro),

            const SizedBox(height: 60),
            _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
                "Add Log Entry",
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'Montserrat-Black',
                  color: MoldifyColors.primaryColor,
                )
            ),
            Text(
                "Document your observations with images and details to track the progression of the case.",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Bricolage-Grotesque-Regular',
                  color: MoldifyColors.MoldifyBlack,
                )
            ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Bricolage-Grotesque-Bold',
            fontSize: 18,
            letterSpacing: 0.5,
            color: MoldifyColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1.5, color: MoldifyColors.primaryColor),
      ],
    );
  }

  Widget _buildCaptureCard({
    required bool hasImage,
    String? imagePath,
    required VoidCallback onTap,
    required String statusText,
    required String emptyMsg,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: hasImage ? 220 : 120,
        decoration: BoxDecoration(
          color: MoldifyColors.primaryColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MoldifyColors.primaryColor.withOpacity(0.1), width: 1.5),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ObservationPreviewImage(imagePath: imagePath!),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: _buildGlassLabel(statusText),
                  ),
                  Positioned(top: 12, right: 12, child: _buildGlassRetake(onTap)),
                ],
              )
            : ObservationEmptyStateCard(message: emptyMsg),
      ),
    );
  }

  Widget _buildMacroscopicEvidenceBlock(bool hasImage) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MoldifyColors.taupe,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MoldifyColors.primaryColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildCaptureCard(
            hasImage: hasImage,
            imagePath: widget.macroscopicImagePath,
            onTap: widget.onCaptureMacro,
            statusText: "Macroscopic Specimen",
            emptyMsg: "Tap to capture macroscopic view",
          ),
          if (hasImage)
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  _buildDataRow(
                    l1: 'COLOR', v1: _macroColorController.text, i1: Icons.palette_outlined,
                    l2: 'TEXTURE', v2: _macroTextureController.text, i2: Icons.texture_rounded,
                  ),
                  const SizedBox(height: 15),
                  _buildDataRow(
                    l1: 'SYMPTOMS', v1: _macroSymptomsController.text, i1: Icons.healing_outlined,
                    l2: 'DETAILS', v2: _macroCharacteristicsController.text, i2: Icons.science_outlined,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required String l1, required String v1, required IconData i1,
    required String l2, required String v2, required IconData i2,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: ObservationDataTile(label: l1, value: v1, icon: i1)),
          const SizedBox(width: 12),
          Expanded(child: ObservationDataTile(label: l2, value: v2, icon: i2)),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Bricolage-Grotesque-Bold',
        fontSize: 12,
        letterSpacing: 1.5,
        color: MoldifyColors.primaryColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildGlassLabel(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        color: Colors.black.withOpacity(0.5),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Bricolage-Grotesque-Regular'),
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
              mainAxisSize: MainAxisSize.min,
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

  Widget _buildFooterActions() {
    return SizedBox(
      width: double.infinity,
      child: BuildButton(
        onPressed: widget.onSubmit,
        buttonText: 'SAVE LOG CHANGES',
        fontSize: 13,
        backgroundColor: MoldifyColors.primaryColor,
        textColor: Colors.white,
        buttonHeight: 56,
        buttonRadius: 12,
      ),
    );
  }

  bool _isNotBlank(String? val) => val != null && val.trim().isNotEmpty;
}