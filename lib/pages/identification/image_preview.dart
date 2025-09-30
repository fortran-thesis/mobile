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

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isProcessing = false;
  final GlobalKey _previewContainerKey = GlobalKey();
  final GlobalKey _dottedBoxKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();

  Future<void> _captureAndCropImage() async {
    if (_isProcessing) return; // Prevent multiple taps
    setState(() {
      _isProcessing = true;
    });

    /// 1. Get Render Objects
    final RenderRepaintBoundary? boundary = _previewContainerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final RenderBox? dottedBoxRenderBox = _dottedBoxKey.currentContext?.findRenderObject() as RenderBox?;

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
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      /// 2. Capture Image
      final ui.Image capturedImage = await boundary.toImage(pixelRatio: pixelRatio);

      /// 3. Calculate Crop Rectangle (coordinates relative to the captured image)
      final Offset dottedBoxGlobalOffset = dottedBoxRenderBox.localToGlobal(Offset.zero);
      final Offset previewContainerGlobalOffset = (boundary as RenderBox).localToGlobal(Offset.zero);
      final Offset relativeOffset = dottedBoxGlobalOffset - previewContainerGlobalOffset;

      final Rect cropRectLogical = Rect.fromLTWH(
        relativeOffset.dx,
        relativeOffset.dy,
        dottedBoxRenderBox.size.width,
        dottedBoxRenderBox.size.height,
      );

      final Rect cropRectPhysical = Rect.fromLTWH(
        cropRectLogical.left * pixelRatio,
        cropRectLogical.top * pixelRatio,
        cropRectLogical.width * pixelRatio,
        cropRectLogical.height * pixelRatio,
      );

      // Basic bounds check for the crop rectangle
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

      /// 4. Perform the Crop
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint();
      canvas.drawImageRect(
          capturedImage,
          cropRectPhysical,
          Rect.fromLTWH(0, 0, cropRectPhysical.width, cropRectPhysical.height),
          paint);
      final ui.Image croppedUiImage = await recorder.endRecording().toImage(
        cropRectPhysical.width.round(),
        cropRectPhysical.height.round(),
      );

      /// 5. Convert to File
      final ByteData? byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);
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
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'cropped_preview_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      print('Cropped image saved to: ${file.path}');

      /// 6. Navigate
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/mold_result',
        arguments: {'croppedImagePath': file.path},
      );

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
        /// Layer 1: Image Preview Background
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

        /// Layer 2: Overlay UI
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// 1. Go Back Button
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

                /// 2. Proceed Button
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

        /// Layer 4: Dotted Border Overlay To Guide User
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

        /// Layer 5: Loading Overlay
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
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
