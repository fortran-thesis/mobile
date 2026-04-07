// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../buttons/popmenu_button.dart';
import '../colors.dart';
import 'initial_observation_components/observation_data_tile.dart';
import 'initial_observation_components/observation_empty_state_card.dart';
import 'initial_observation_components/observation_preview_image.dart';

/// A single monitoring log entry displayed inside the In Vitro or In Vivo timeline.
///
/// Each entry contains two evidence sections that mirror the structure used in
/// [SetMonitoringDetailsScreen] > EvidenceTab:
///
/// - **Microscopic section**: image from the mold scanner with a glassmorphic
///   genus-name overlay (identical visual to [InitialObservationTab]).
///
/// - **Macroscopic section**: taupe card containing the macroscopic image, three
///   observation chips (shape, size, texture), and a two-column metadata row
///   (symptoms, characteristics).
///
/// ---
/// Parameters:
///
/// [dateTime] — Human-readable timestamp string shown at the top of the tile.
///
/// **Microscopic**
/// [microscopicImagePath] — Local file path, asset path, or remote URL of the
///   image captured via the mold scanner.
/// [microGenusName] — Identified genus/species name returned by the scanner
///   (e.g. "Aspergillus fumigatus"). Displayed as a glass overlay on the image.
///
/// **Macroscopic**
/// [macroscopicImagePath] — Local file path, asset path, or remote URL of the
///   macroscopic observation image.
/// [macroShape] — Observed colony/lesion shape (e.g. "Circular").
/// [macroTexture] — Observed surface texture (e.g. "Powdery").
/// [macroSymptoms] — Comma-separated symptoms (e.g. "Leaf spots, Wilting").
/// [macroSigns] — Comma-separated signs (e.g. "White cottony growth").
/// [macroCharacteristics] — Comma-separated characteristic traits.
///
/// **Context-sensitive labels** (supplied by the parent tab):
/// [shapeLabel]   — e.g. "Colony Shape" (in-vitro) or "Lesion Shape" (in-vivo).
/// [textureLabel] — e.g. "Colony Texture" or "Lesion Texture".
///
/// **General**
/// [isFirst] / [isLast] — Timeline connector visibility flags.
///
/// **Popup menu** (all optional)
/// [popupMenuItems] — Labels for the 3-dot overflow menu.
/// [popupMenuIcons] — Matching icons for each menu item.
/// [onPopupMenuItemSelected] — Callback with the index of the tapped item.
/// [popupMenuIcon] — Custom trigger icon widget (defaults to 3 dots).
class ExperimentTimelineTile extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor parameters
  // ---------------------------------------------------------------------------

  final String dateTime;

  // --- Microscopic ---

  /// Path to the image captured via the mold scanner.
  final String microscopicImagePath;

  /// Genus/species name returned by the scanner (shown as overlay label).
  final String microGenusName;

  // --- Macroscopic ---

  /// Path to the macroscopic observation image.
  final String macroscopicImagePath;

  /// Observed colony/lesion shape.
  final String macroShape;

  /// Observed surface texture.
  final String macroTexture;

  /// Comma-separated symptoms.
  final String macroSymptoms;

  /// Comma-separated signs.
  final String macroSigns;

  /// Comma-separated characteristic traits.
  final String macroCharacteristics;

  /// Optional culture timer/source identity assigned when log was recorded.
  final String cultureName;

  // --- Context-sensitive chip labels (set by the parent tab) ---

  /// "Colony Shape" for in-vitro, "Lesion Shape" for in-vivo.
  final String shapeLabel;

  /// "Colony Texture" for in-vitro, "Lesion Texture" for in-vivo.
  final String textureLabel;

  // --- General ---

  /// Whether this is the first tile in the timeline (hides upper connector).
  final bool isFirst;

  /// Whether this is the last tile in the timeline (hides lower connector).
  final bool isLast;

  // --- Popup menu (all optional) ---

  final List<String>? popupMenuItems;
  final List<IconData>? popupMenuIcons;

  /// Callback receiving the tapped item's index.
  final ValueChanged<int>? onPopupMenuItemSelected;

  /// Custom icon widget for the popup-menu trigger.
  final Widget? popupMenuIcon;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const ExperimentTimelineTile({
    super.key,
    required this.dateTime,
    // Microscopic
    required this.microscopicImagePath,
    required this.microGenusName,
    // Macroscopic
    required this.macroscopicImagePath,
    required this.macroShape,
    required this.macroTexture,
    required this.macroSymptoms,
    required this.macroSigns,
    required this.macroCharacteristics,
    this.cultureName = '',
    // Labels
    required this.shapeLabel,
    required this.textureLabel,
    // General
    this.isFirst = false,
    this.isLast = false,
    // Popup menu
    this.popupMenuItems,
    this.popupMenuIcons,
    this.onPopupMenuItemSelected,
    this.popupMenuIcon,
  });

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Opens [imagePath] as a full-screen, pinch-to-zoom dialog.
  void _showFullscreen(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: ObservationPreviewImage(
                  imagePath: imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 15,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Uppercase section heading with a faint trailing divider line.
  Widget _sectionHeader(String label) => Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Bricolage-Grotesque-SemiBold',
        fontSize: 11,
        letterSpacing: 1.2,
        color: MoldifyColors.primaryColor.withValues(alpha: 0.7),
      ),
    ),
  );

  /// Compact chip displaying a [label] / [value] pair.
  ///
  /// Used for the three macroscopic observation chips:
  /// shape, size, and texture.
  Widget _chip(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      decoration: BoxDecoration(
        color: MoldifyColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: MoldifyColors.primaryColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontFamily: 'Bricolage-Grotesque-SemiBold',
              color: MoldifyColors.primaryColor.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.trim().isNotEmpty ? value : '---',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Bricolage-Grotesque-Regular',
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasMicro = microscopicImagePath.trim().isNotEmpty;
    final hasMacro = macroscopicImagePath.trim().isNotEmpty;
    final hasMicroEvidence = hasMicro || microGenusName.trim().isNotEmpty;
    final hasMacroEvidence =
        hasMacro ||
        macroShape.trim().isNotEmpty ||
        macroTexture.trim().isNotEmpty ||
        macroSymptoms.trim().isNotEmpty ||
        macroSigns.trim().isNotEmpty ||
        macroCharacteristics.trim().isNotEmpty;

    return TimelineTile(
      alignment: TimelineAlign.start,
      lineXY: 0.5,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 10,
        color: MoldifyColors.primaryColor,
        indicatorXY: 0.04,
        padding: const EdgeInsets.all(6),
      ),
      beforeLineStyle: LineStyle(
        color: MoldifyColors.primaryColor,
        thickness: 1,
      ),
      endChild: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 60,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 28.0, right: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Date + overflow menu row ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateTime,
                    style: const TextStyle(
                      color: MoldifyColors.MoldifyGrey,
                      fontFamily: 'Bricolage-Grotesque-Regular',
                      fontSize: 12,
                    ),
                  ),
                  if (popupMenuItems != null &&
                      popupMenuItems!.isNotEmpty &&
                      onPopupMenuItemSelected != null)
                    PopupMenu(
                      popMenuColor: MoldifyColors.MoldifyGrey,
                      popMenuIcon: popupMenuIcon,
                      items: popupMenuItems!,
                      icons: popupMenuIcons,
                      onItemSelected: onPopupMenuItemSelected!,
                    ),
                ],
              ),

              // =================================================================
              // MICROSCOPIC SECTION
              //
              // Shows the mold-scanner image with a glassmorphic genus-name
              // overlay at the bottom — identical to InitialObservationTab.
              // Tapping the image opens the full-screen viewer.
              // =================================================================
              if (hasMicroEvidence) ...[
                _sectionHeader('Microscopic'),
                GestureDetector(
                  onTap: hasMicro
                      ? () => _showFullscreen(context, microscopicImagePath)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: hasMicro ? 180 : 80,
                    decoration: BoxDecoration(
                      color: MoldifyColors.primaryColor.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: MoldifyColors.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: hasMicro
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              // Microscopic image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ObservationPreviewImage(
                                  imagePath: microscopicImagePath,
                                ),
                              ),
                              // Glassmorphic genus-name label
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 8,
                                      sigmaY: 8,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 7,
                                        horizontal: 12,
                                      ),
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      child: Text(
                                        microGenusName.trim().isNotEmpty
                                            ? microGenusName
                                            : 'Identified: Pending Analysis',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily:
                                              'Bricolage-Grotesque-Regular',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const ObservationEmptyStateCard(
                            message: 'No microscopic image captured',
                            height: 80,
                          ),
                  ),
                ),
              ],

              // =================================================================
              // MACROSCOPIC SECTION
              //
              // Taupe card:
              //   1. Full-bleed image header (tap to full-screen)
              //   2. Two chips: shape | texture
              //      (labels are context-driven by the parent tab)
              //   3. Two ObservationDataTile widgets: symptoms | characteristics
              // =================================================================
              if (hasMacroEvidence) ...[
                _sectionHeader('Macroscopic'),
                Container(
                  decoration: BoxDecoration(
                    color: MoldifyColors.taupe,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: MoldifyColors.primaryColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image header
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: hasMacro
                            ? GestureDetector(
                                onTap: () => _showFullscreen(
                                  context,
                                  macroscopicImagePath,
                                ),
                                child: SizedBox(
                                  height: 180,
                                  width: double.infinity,
                                  child: ObservationPreviewImage(
                                    imagePath: macroscopicImagePath,
                                  ),
                                ),
                              )
                            : const ObservationEmptyStateCard(
                                message: 'No macroscopic image captured',
                              ),
                      ),

                      // Metadata (only shown when an image exists)
                      if (hasMacro)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              // Row 1: shape | texture chips
                              Row(
                                children: [
                                  _chip(shapeLabel, macroShape),
                                  const SizedBox(width: 6),
                                  _chip(textureLabel, macroTexture),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Row 2: symptoms | characteristics tiles
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ObservationDataTile(
                                      label: 'Symptoms',
                                      value: macroSymptoms,
                                      icon: Icons.healing_outlined,
                                    ),
                                    const SizedBox(width: 8),
                                    ObservationDataTile(
                                      label: 'Characteristics',
                                      value: macroCharacteristics,
                                      icon: Icons.science_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ObservationDataTile(
                                    label: 'Signs',
                                    value: macroSigns,
                                    icon: Icons.visibility_outlined,
                                  ),
                                ],
                              ),
                              if (cultureName.trim().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ObservationDataTile(
                                      label: 'Culture Source',
                                      value: cultureName,
                                      icon: Icons.timer_outlined,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              if (!hasMicroEvidence && !hasMacroEvidence)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: ObservationEmptyStateCard(
                    message:
                        'No microscopic or macroscopic evidence in this log',
                    height: 90,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
