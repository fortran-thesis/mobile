import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moldify/core/constants/route_names.dart';
import 'package:moldify/pages/misc/appbar/primary_app_bar.dart';
import 'package:moldify/pages/misc/buttons/primary_button.dart';
import '../misc/colors.dart';
import 'package:moldify/core/utils/logger.dart';

class MainCameraScreen extends StatefulWidget {
  // 1. Add a boolean to control AppBar visibility, defaulting to false.
  final bool showAppBar;
  final bool returnResult;

  const MainCameraScreen({
    super.key,
    this.showAppBar = false,
    this.returnResult = false,
  });

  @override
  State<MainCameraScreen> createState() => _MainCameraScreenState();
}

class _MainCameraScreenState extends State<MainCameraScreen> {
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
        // Use named route for navigation
        final result = await Navigator.pushNamed(context, RouteNames.imagePreview,
            arguments: {
              'imagePath': imageFile.path,
              'source': 'main_camera',
              'returnResult': widget.returnResult,
            });
        if (!mounted) return;
        if (widget.returnResult && result != null) {
          Navigator.of(context).pop(result);
          return;
        }
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
    // Use named route for navigation
    Navigator.pushNamed(context, RouteNames.camera,
        arguments: {
          'source': 'main_camera',
          'returnResult': widget.returnResult,
        }).then((result) {
      if (!mounted) return;
      if (widget.returnResult && result != null) {
        Navigator.of(context).pop(result);
      }
    });
  }

  // 2. The page's UI content is extracted into a helper method to avoid duplication.
  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            color: MoldifyColors.backgroundColor,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ----------- Mold Scanner Header -----------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('Mold Scanner',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Montserrat-Black',
                            color: MoldifyColors.primaryColor,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('Please capture or upload mold sample.',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bricolage-Grotesque-Regular',
                            color: MoldifyColors.MoldifyBlack,
                          )),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: SvgPicture.asset(
                        'assets/images/mold_scanner_curve.svg',
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
                                'Make sure the mold sample is centered in the frame.',
                                'Ensure good lighting conditions for better accuracy.',
                                'Only photograph one mold species per image; avoid mixing species.',
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
                                  onPressed:
                                  _isProcessingImage ? () {} : _navigateToCamera,
                                  backgroundColor: MoldifyColors.primaryColor,
                                  textColor: MoldifyColors.backgroundColor,
                                  buttonHeight: 40.0,
                                  buttonWidth: MediaQuery.of(context).size.width,
                                  buttonRadius: 10.0),
                            ),
                            Padding(
                              padding:
                              EdgeInsets.only(top: 10.0, bottom: widget.showAppBar ? 10.0 : 70.0),
                              child: BuildButton(
                                  buttonText: 'Upload Image',
                                  onPressed: _isProcessingImage
                                      ? () {}
                                      : _pickImageFromGallery,
                                  backgroundColor: MoldifyColors.accentColor,
                                  textColor: MoldifyColors.MoldifyBlack,
                                  buttonHeight: 45.0,
                                  buttonWidth: MediaQuery.of(context).size.width,
                                  buttonRadius: 10.0),
                            ),
                          ]),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        // Loading Overlay
        if (_isProcessingImage)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: MoldifyColors.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    // 3. Check the `showAppBar` flag to decide what to build.
    if (widget.showAppBar) {
      // If true, build the UI inside a Scaffold with an AppBar.
      // This provides the correct layout and a back button.
      return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        appBar: PrimaryAppBar(title: 'Mold Scanner'),
        body: _buildContent(context),
      );
    } else {
      // If false, build just the content. This is for the bottom navigation bar.
      return _buildContent(context);
    }
  }
}