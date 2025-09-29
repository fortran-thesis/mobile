import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../misc/colors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  Object? _error; // To hold any initialization error.

  // This is used to track the flash state.
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _setUpCameraController();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  // --- This is used to toggle the flash ---
  void _toggleFlash() async {
    if (cameraController == null) return;

    // Determine the new mode and update the camera.
    // FlashMode.torch keeps the light on.
    final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
    try {
      await cameraController!.setFlashMode(newMode);
      // Update the state to change the icon.
      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } on CameraException catch (e) {
      print('Error setting flash mode: $e');
    }
  }

  //This is used to handle taking picture
  void _onCaptureButtonPressed() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      print('Error: Camera controller is not initialized.');
      return;
    }

    try {
      // The takePicture() method returns an XFile object with the path.
      final XFile imageFile = await cameraController!.takePicture();

      if (mounted) {
        // For now, we just print the path to the console.
        print('Picture saved to: ${imageFile.path}');

        // The next step would be to navigate to a new screen to show the preview.
        // Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewScreen(imagePath: imageFile.path)));
      }
    } on CameraException catch (e) {
      print('Error taking picture: $e');
    }
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
      // If not ready, show a loading indicator.
      return const Center(child: CircularProgressIndicator());
    }

    // If ready, show the camera preview.
    return Stack(
      fit: StackFit.expand,
      children: [
        /// Layer 1: The Camera Preview as the background
        CameraPreview(cameraController!),

        /// Layer 2: Your FAB, positioned  at the bottom center
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// 1. This is the cancel button
                TextButton (
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Bricolage-Grotesque-Bold',
                      fontSize: 18,
                      color: MoldifyColors.backgroundColor,
                      decoration: TextDecoration.none, // Explicitly remove decoration
                    ),
                  ),
                ),
                /// 2. This is the capture button
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
                    onPressed: _onCaptureButtonPressed,
                    backgroundColor: MoldifyColors.primaryColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: MoldifyColors.backgroundColor,
                        width: 5.0,
                      ),
                    ),
                  ),
                ),

                /// 3. This is the flash button
                IconButton(
                  onPressed: _toggleFlash,
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
        /// End Of Layer 2

        /// Layer 3: Instructions banner at the top
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
                    decoration: TextDecoration.none, // Explicitly remove decoration
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _setUpCameraController() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('NoCamerasFound', 'No cameras were found on this device.');
      }

      final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      
      // Make sure flash is off when camera starts.
      await controller.setFlashMode(FlashMode.off);

      // If initialization is successful, update the state.
      if (!mounted) return;
      setState(() {
        cameraController = controller;
        _isFlashOn = false; // Sync the state
        _error = null; // Clear any previous error.
      });

    } catch (e) {
      // If an error occurs, update the state to show the error.
      if (!mounted) return;
      setState(() {
        _error = e;
      });
      print('Camera Error: $e'); // Log the error for debugging.
    }
  }
}
