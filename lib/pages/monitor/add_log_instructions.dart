import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import '../misc/appbar/primary_app_bar.dart';
import '../misc/colors.dart';
import 'package:moldify/core/utils/logger.dart';

class AddLogInstructionsScreen extends StatefulWidget {
  // 1. Add sourceTab as a constructor argument
  final String? sourceTab;
  final String? caseId;

  const AddLogInstructionsScreen({super.key, this.sourceTab, this.caseId});

  @override
  State<AddLogInstructionsScreen> createState() => _AddLogInstructionsScreenState();
}

class _AddLogInstructionsScreenState extends State<AddLogInstructionsScreen> {
  bool _isProcessingImage = false; // State variable for loading

  /// This is used to open gallery and pick an image
  Future<void> _pickImageFromGallery() async {
    if (_isProcessingImage) return;

    if (!mounted) return;
    setState(() {
      _isProcessingImage = true;
    });

    final ImagePicker picker = ImagePicker();
    XFile? imageFile;

    try {
      imageFile = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return;

      if (imageFile != null) {
        AppLogger.d('Image selected from gallery: ${imageFile.path}');
        // 2. Pass both 'source' and the new 'sourceTab' argument
        await Navigator.pushNamed(
          context,
          RouteNames.imagePreview,
          arguments: {
            'imagePath': imageFile.path,
            'source': 'add_log',
            'sourceTab': widget.sourceTab,
            'caseId': widget.caseId
          },
        );
      } else {
        AppLogger.d('No image selected.');
      }
    } catch (e) {
      AppLogger.e('Error picking image or navigating', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  /// This is used to navigate to the camera screen
  void _navigateToCamera() {
    if (_isProcessingImage) return;
    // 3. Pass both 'source' and the new 'sourceTab' argument
    Navigator.pushNamed(
      context,
      RouteNames.camera,
      arguments: {
        'source': 'add_log',
        'sourceTab': widget.sourceTab,
        'caseId': widget.caseId
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: PrimaryAppBar(
        title: 'Add New Log',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ----------- Mold Scanner Header -----------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text('Add New Log',
                            style: TextStyle(
                              fontSize: 36,
                              fontFamily: 'Montserrat-Black',
                              color: MoldifyColors.primaryColor,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                            'Please submit an image of the mold sample you want to log.',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                              color: MoldifyColors.MoldifyBlack,
                            )),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: SvgPicture.asset(
                          'assets/images/add_log_curve.svg',
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                      /// ----------- End of Mold Scanner Header -----------

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructions Before Using',
                              style: TextStyle(
                                fontFamily: 'Montserrat-Black',
                                fontSize: 16,
                                color: MoldifyColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            /// Start of Instructions Before Using
                            Column(
                              children: [
                                'Stand about half a meter from the mold to accurately measure its diameter.',
                                'Make sure the mold is centered in the frame.',
                                'Ensure that the mold is in clear lighting',
                              ].asMap().entries.map((entry) {
                                int idx = entry.key;
                                String text = entry.value;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${idx + 1}. ',
                                      style: const TextStyle(
                                        fontFamily:
                                        'Bricolage-Grotesque-Regular',
                                        fontSize: 16,
                                        color: MoldifyColors.MoldifyBlack,
                                        letterSpacing: 0.5,
                                        height: 1.7,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        text,
                                        style: const TextStyle(
                                          fontFamily:
                                          'Bricolage-Grotesque-Regular',
                                          fontSize: 16,
                                          color: MoldifyColors.MoldifyBlack,
                                          letterSpacing: 0.5,
                                          height: 1.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            /// End of Instructions Before Using

                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: BuildButton(
                                  buttonText: 'Use Camera',
                                  onPressed: _isProcessingImage ? () {} : _navigateToCamera,
                                  backgroundColor: MoldifyColors.primaryColor,
                                  textColor: MoldifyColors.backgroundColor,
                                  buttonHeight: 40.0,
                                  buttonWidth: MediaQuery.of(context).size.width,
                                  buttonRadius: 10.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: BuildButton(
                                  buttonText: 'Upload Image',
                                  onPressed: _isProcessingImage ? () {} : _pickImageFromGallery,
                                  backgroundColor: MoldifyColors.accentColor,
                                  textColor: MoldifyColors.MoldifyBlack,
                                  buttonHeight: 45.0,
                                  buttonWidth: MediaQuery.of(context).size.width,
                                  buttonRadius: 10.0
                              ),
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
          if (_isProcessingImage)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}