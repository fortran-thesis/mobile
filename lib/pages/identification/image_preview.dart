import 'package:moldify/core/features/camera/services/camera_service.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import '../misc/colors.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String? source;
  final String? sourceTab;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    this.source,
    this.sourceTab,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isProcessing = false;
  final GlobalKey _previewContainerKey = GlobalKey();
  final GlobalKey _dottedBoxKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();

  /// Captures the current UI preview, crops it based on a defined box, and navigates to the appropriate screen.
  Future<void> _captureAndCropImage() async {
    if (_isProcessing) return;

    // Set the processing flag to true to indicate a task is in progress
    setState(() {
      _isProcessing = true;
    });

    // Get the RenderObject for the full preview container and the dotted box
    final RenderRepaintBoundary? boundary = _previewContainerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final RenderBox? dottedBoxRenderBox = _dottedBoxKey.currentContext?.findRenderObject() as RenderBox?;

    // If either render object is null, show error and exit
    if (boundary == null || dottedBoxRenderBox == null) {
      print("Error: Could not get render objects for cropping.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error preparing image. Please try again.')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
      return;
    }

    try {
      // Get the device's pixel ratio (for accurate cropping on high DPI screens)
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;

      // Capture the full preview as an image
      final ui.Image capturedImage = await boundary.toImage(pixelRatio: pixelRatio);

      // Get the global position of the dotted crop box and the preview container
      final Offset dottedBoxGlobalOffset = dottedBoxRenderBox.localToGlobal(Offset.zero);
      final Offset previewContainerGlobalOffset = (boundary as RenderBox).localToGlobal(Offset.zero);
      // Calculate the crop rectangle (logical coordinates)
      final Offset relativeOffset = dottedBoxGlobalOffset - previewContainerGlobalOffset;

      final Rect cropRectLogical = Rect.fromLTWH(
        relativeOffset.dx,
        relativeOffset.dy,
        dottedBoxRenderBox.size.width,
        dottedBoxRenderBox.size.height,
      );

      // Convert logical crop rect to physical (pixel-based) coordinates
      final Rect cropRectPhysical = Rect.fromLTWH(
        cropRectLogical.left * pixelRatio,
        cropRectLogical.top * pixelRatio,
        cropRectLogical.width * pixelRatio,
        cropRectLogical.height * pixelRatio,
      );

      // Check if the crop area is within the captured image bounds
      if (cropRectPhysical.left < 0 || cropRectPhysical.top < 0 ||
          cropRectPhysical.right > capturedImage.width || cropRectPhysical.bottom > capturedImage.height) {
        print("Error: Crop area is outside the captured image bounds.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crop area is outside the image. Adjust and try again.')),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      // Begin a new canvas to draw the cropped portion
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();

      // Draw the cropped area from the captured image onto the new canvas
      canvas.drawImageRect(
          capturedImage,
          cropRectPhysical,
          Rect.fromLTWH(0, 0, cropRectPhysical.width, cropRectPhysical.height),
          paint);

      // Convert the canvas drawing into a ui.Image (cropped image)
      final ui.Image croppedUiImage = await recorder.endRecording().toImage(
        cropRectPhysical.width.round(),
        cropRectPhysical.height.round(),
      );

      // Convert the cropped image to PNG byte data
      final ByteData? byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);
      // Check if byte data was successfully obtained
      if (byteData == null) {
        print("Error: Could not get byte data from cropped image.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error processing cropped image.')),
          );
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      // Save the PNG byte data to a temporary file
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'cropped_preview_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      print('Cropped image saved to: ${file.path}');

      // Send image to model API
      try {
        // Import CameraService at the top of the file:
        // import 'package:moldify/core/features/camera/services/camera_service.dart';
        final cameraService = CameraService();
        final result = await cameraService.identifyImage(
          imageBytes: pngBytes,
          filename: fileName,
        );
        print('Model API result: $result');

        if (!mounted) return;
        if (widget.source == 'add_log') {
          Navigator.pushNamed(
            context,
            '/add-log',
            arguments: {
              'imagePath': file.path,
              'sourceTab': widget.sourceTab,
            },
          );
        } else {
          Navigator.pushNamed(
            context,
            '/mold_result',
            arguments: {
              'croppedImagePath': file.path,
              'modelResult': result,
            },
          );
        }
      } catch (e) {
        print('Error sending image to model API: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send image for identification.')),
          );
        }
      }

    } catch (e, s) {
      print('Error during cropping or navigation: $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 1. Interactive Image Preview
        /// This allows the user to pan and zoom the captured image. It is wrapped
        /// in a RepaintBoundary to allow us to capture it as an image.
        RepaintBoundary(
          key: _previewContainerKey,
          child: InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        /// 2. Bottom Control Bar
        /// This bar contains the 'Close' (cancel) and 'Check' (confirm) buttons.
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// Close Button
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    color: MoldifyColors.backgroundColor,
                    size: 28.0,
                  ),
                ),

                /// Check Button
                IconButton(
                  onPressed: _captureAndCropImage,
                  icon: Icon(
                    Icons.check,
                    color: MoldifyColors.backgroundColor,
                    size: 33.0,
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
                  'Pinch to fit target within the box. ',
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
        /// This provides a non-interactive visual guide for cropping.
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
                  key: _dottedBoxKey,
                  width: 200,
                  height: 200,
                  color: Colors.transparent,
                ),
              )
          ),
        ),

        /// 5. Loading Indicator Overlay
        /// This appears on top of the screen while the image is being processed.
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
