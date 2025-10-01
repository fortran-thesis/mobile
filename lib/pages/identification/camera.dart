import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../misc/colors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  Object? _error;

  // This is used to track the flash state.
  bool _isFlashOn = false;
  // This is used to prevent multiple captures at once and show loading indicator
  bool _isTakingPicture = false;

  /// Initialize the camera when the widget is first created.
  @override
  void initState() {
    super.initState();
    _setUpCameraController();
  }

  /// Dispose the camera controller when the widget is disposed.
  @override
  void dispose() {
    if (cameraController != null && cameraController!.value.isInitialized) {
      cameraController!.setFlashMode(FlashMode.off);
      cameraController!.dispose();
    } else {
      cameraController?.dispose();
    }
    super.dispose();
  }

  /// This is used to toggle the flash
  void _toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
    try {
      await cameraController!.setFlashMode(newMode);
      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } on CameraException catch (e) {
      print('Error setting flash mode: $e');
    }
  }

  /// This is used to handle capture button
  void _onCaptureButtonPressed() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      print('Error: Camera controller is not initialized.');
      return;
    }
    // Prevent multiple captures if one is already in progress
    if (_isTakingPicture) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isTakingPicture = true; // Show loading indicator
        });
      }

      final XFile imageFile = await cameraController!.takePicture();

      if (mounted) {
        print('Picture saved to: ${imageFile.path}');

        // Turn off flash if on before navigating
        if (_isFlashOn || cameraController!.value.flashMode == FlashMode.torch) {
          await cameraController!.setFlashMode(FlashMode.off);
          print('Flash explicitly turned off before navigating.');
          if (mounted) { // Re-check mounted after async gap
            setState(() {
              _isFlashOn = false;
            });
          }
        }

        // Navigate after picture is taken.
        await Navigator.pushNamed
          (context, '/image_preview',
            arguments: {'imagePath': imageFile.path}
        );
      }
    } on CameraException catch (e) {
      print('Error taking picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  /// This is used to set up the camera controller
  /// and handle errors during initialization.
  /// It also sets the initial flash mode to off.
  /// If no cameras are found, it sets an appropriate error message.
  /// This method is called in initState.
  Future<void> _setUpCameraController() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('NoCamerasFound', 'No cameras were found on this device.');
      }

      final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();

      await controller.setFlashMode(FlashMode.off);

      if (!mounted) return;
      setState(() {
        cameraController = controller;
        _isFlashOn = false;
        _error = null;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
      print('Camera Error: $e');
    }
  }

  /// Build the widget tree.
  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    // First, check if an error occurred.
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Failed to initialize camera.\nError: $_error\nPlease ensure you have granted camera permissions and restart the page.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // If no error, check if the controller is ready.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // If ready, show the camera preview.
    return Stack(
      fit: StackFit.expand,
      children: [

        /// Layer 1: Camera Preview
        CameraPreview(cameraController!),

        /// Layer 2: Overlay UI
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// 1. Cancel Button
                TextButton (
                  onPressed: _isTakingPicture ? null : () { // Disable cancel when taking picture
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      fontSize: 18,
                      color: MoldifyColors.backgroundColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                /// 2. Capture Button
                Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: MoldifyColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: MoldifyColors.primaryColor,
                      width: 4.0,
                    ),
                  ),
                  child: FloatingActionButton(
                    heroTag: 'capture_button',
                    // Disable button if a picture is being taken
                    onPressed: _isTakingPicture ? null : _onCaptureButtonPressed,
                    backgroundColor: _isTakingPicture ? MoldifyColors.primaryColor.withValues(alpha: 0.5) : MoldifyColors.primaryColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: MoldifyColors.backgroundColor,
                        width: 5.0,
                      ),
                    ),

                  ),
                ),

                /// 3. Flash Button
                IconButton(
                  onPressed: _isTakingPicture ? null : _toggleFlash,
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: MoldifyColors.backgroundColor,
                    size: 28.0,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Layer 3: Instructional Banner Text
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Container(
              width: double.infinity,
              color: MoldifyColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Material(
                type: MaterialType.transparency,
                child: const Text(
                  'Please keep mold centered and in clear lighting.',
                  style: TextStyle(
                    fontFamily: 'Bricolage-Grotesque-Regular',
                    fontSize: 12,
                    color: MoldifyColors.backgroundColor,
                    decoration: TextDecoration.none, 
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),

        /// Layer 4: Dotted Border Box Overlay To Guide User
        Align(
          alignment: Alignment.center,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: [10, 6],
              radius: Radius.circular(12),
              strokeWidth: 3,
              padding: EdgeInsets.all(16),
              color: MoldifyColors.backgroundColor,
            ),
            child: Container(
              width: 200,
              height: 200,
              color: Colors.transparent,
            ),
          )
        ),

        /// Loading Indicator Overlay
        Visibility(
          visible: _isTakingPicture,
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}