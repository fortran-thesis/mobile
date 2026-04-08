import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../misc/colors.dart';
import 'package:moldify/core/utils/logger.dart';

class CameraScreen extends StatefulWidget {
  final String? source;
  final String? sourceTab;
  final String? caseId;
  final String? selectedCultureId;
  final String? selectedCultureName;
  final String? sourceFlow;
  final String? scanModality;
  final bool includeSize;
  final bool returnResult;

  const CameraScreen({
    super.key,
    this.source,
    this.sourceTab,
    this.caseId,
    this.selectedCultureId,
    this.selectedCultureName,
    this.sourceFlow,
    this.scanModality,
    this.includeSize = true,
    this.returnResult = false,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  Object? _error;

  bool _isFlashOn = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _setUpCameraController();
  }

  /// Disposes the camera controller to release resources when the widget is removed.
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

  /// Toggles the camera's flash mode between torch and off.
  void _toggleFlash() async {
    // Check if the camera controller is null or not initialized yet
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    // Determine the new flash mode: turn it off if currently on, or turn it on if currently off
    final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
    try {
      await cameraController!.setFlashMode(newMode);
      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } on CameraException catch (e) {
      AppLogger.e('Error setting flash mode', error: e);
    }
  }

  /// Handles the capture button press, takes a picture, and navigates to the preview screen.
  void _onCaptureButtonPressed() async {
    // Check if the camera is initialized and ready to use
    if (cameraController == null || !cameraController!.value.isInitialized) {
      AppLogger.e('Error: Camera controller is not initialized.');
      return;
    }
    // Prevents taking multiple pictures at the same time
    if (_isTakingPicture) {
      return;
    }

    try {
      // Indicates that the app is in the process of taking a picture
      if (mounted) {
        setState(() {
          _isTakingPicture = true;
        });
      }

      // Capture the image using the camera controller
      final XFile imageFile = await cameraController!.takePicture();

      if (mounted) {
        AppLogger.d('Picture saved to: ${imageFile.path}');

        // If the flash is on (either tracked manually or set by the controller), turn it off before navigating
        if (_isFlashOn || cameraController!.value.flashMode == FlashMode.torch) {
          await cameraController!.setFlashMode(FlashMode.off);
          AppLogger.d('Flash explicitly turned off before navigating.');
          // Update the internal flash state to reflect that it's now off
          if (mounted) {
            setState(() {
              _isFlashOn = false;
            });
          }
        }

        // Navigate to the image preview screen and pass relevant data (like image path and source info)
        if (!mounted) return;
        if (mounted) {
          final result = await Navigator.pushNamed(
            context,
            '/image_preview',
            arguments: {
              'imagePath': imageFile.path,
              'source': widget.source,
              'sourceTab': widget.sourceTab,
              'caseId': widget.caseId,
              'selectedCultureId': widget.selectedCultureId,
              'selectedCultureName': widget.selectedCultureName,
              'sourceFlow': widget.sourceFlow,
              'scanModality': widget.scanModality,
              'includeSize': widget.includeSize,
              'returnResult': widget.returnResult,
            },
          );

          // Bubble the result to the previous route when this camera flow is used for logs.
          if (result != null) {
            Navigator.of(context).pop(result);
            return;
          }
        }
      }
    } on CameraException catch (e) {
      AppLogger.e('Error taking picture', error: e);
    } finally {
      // Reset the `_isTakingPicture` flag to allow new pictures to be taken
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  /// Finds available cameras and initializes the [CameraController].
  Future<void> _setUpCameraController() async {
    try {
      // Get a list of all available cameras on the device
      final cameras = await availableCameras();

      // If no cameras are found, throw a custom exception
      if (cameras.isEmpty) {
        throw CameraException('NoCamerasFound', 'No cameras were found on this device.');
      }

      // Create a new CameraController using the first available camera
      // Set the resolution to high and disable audio
      final controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false);

      // Initialize the camera (starts the camera feed and prepares for use)
      await controller.initialize();
      // Set the initial flash mode to off
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
      AppLogger.e('Camera Error', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: MoldifyColors.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to initialize camera.\nError: $_error\nPlease ensure you have granted camera permissions and restart the page.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: MoldifyColors.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: MoldifyColors.primaryColor,
            ),
          )
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 1. Camera Feed
          /// This widget displays the live feed from the device's camera.
          CameraPreview(cameraController!),

          /// 2. Bottom Control Bar
          /// This bar contains the 'Cancel' button, the capture button, and the flash toggle
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// Cancel Button
                  TextButton (
                    onPressed: _isTakingPicture ? null : () {
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

                  /// Capture Button
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

                  /// Flash Toggle Button
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

          /// 3. Instructional Banner
          /// This banner at the top provides guidance to the user.
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

          /// 4. Dotted Border Overlay
          /// This provides a visual guide
          IgnorePointer(
            ignoring: true,
            child: Align(
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
          ),

          /// 5. Loading Indicator Overlay
          /// This appears on top of the screen while a picture is being processed.
          if (_isTakingPicture)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}