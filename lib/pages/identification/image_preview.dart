import 'package:moldify/core/features/camera/services/camera_service.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:moldify/pages/misc/overlays/modals/confirmation_dialog.dart';
import 'dart:typed_data';
import '../misc/colors.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:moldify/core/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:moldify/providers/auth_provider.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String? source;
  final String? sourceTab;
  final String? caseId;
  final String? sourceFlow;
  final String? scanModality;
  final bool includeSize;
  final bool returnResult;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    this.source,
    this.sourceTab,
    this.caseId,
    this.sourceFlow,
    this.scanModality,
    this.includeSize = true,
    this.returnResult = false,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isProcessing = false;
  final GlobalKey _previewContainerKey = GlobalKey();
  final GlobalKey _dottedBoxKey = GlobalKey();
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    AppLogger.d('🚀🚀🚀 ImagePreview: initState called - CODE VERSION WITH DEBUG LOGS LOADED 🚀🚀🚀');
    AppLogger.d('ImagePreview: source = ${widget.source}, sourceTab = ${widget.sourceTab}');
  }

  /// Captures the current UI preview, crops it based on a defined box, and navigates to the appropriate screen.
  Future<void> _captureAndCropImage() async {
    AppLogger.d('🎬 ImagePreview: _captureAndCropImage called - starting capture process');
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
      AppLogger.e("Error: Could not get render objects for cropping.");
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
        AppLogger.e("Error: Crop area is outside the captured image bounds.");
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
        AppLogger.e("Error: Could not get byte data from cropped image.");
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
      AppLogger.d('Cropped image saved to: ${file.path}');

      if (!mounted) return;
      // Cropping is complete; stop the preview processing overlay before next step.
      setState(() {
        _isProcessing = false;
      });
      
      // Check the source to determine next action
      if (widget.source == 'add_log') {
        // For add_log source, navigate directly without API call
        final result = await Navigator.pushNamed(
          context,
          '/add-log',
          arguments: {
            'imagePath': file.path,
            'sourceTab': widget.sourceTab,
            'caseId': widget.caseId,
            'includeSize': widget.includeSize,
            'sourceFlow': widget.sourceFlow,
            'scanModality': widget.scanModality,
          },
        );

        // Bubble the local result back to caller (e.g., monitoring setup).
        if (!mounted) return;
        if (result != null) {
          Navigator.of(context).pop(result);
          return;
        }
      } else {
        // For main_camera source, show modal to let user choose
        AppLogger.d('🔷 ImagePreview: Showing confirmation dialog');
        showDialog(
            context: context,
            barrierDismissible: false, // User must choose an option
            builder: (BuildContext dialogContext) {
              AppLogger.d('🔷 ImagePreview: Dialog builder called');
              return BuildConfirmationDialog(
                title: 'Improve Prediction',
                subtitle: 'Do you want to input additional characteristics for a more accurate result?',
                confirmText: 'Yes, Add Details',
                cancelText: 'No, See Result',
                onConfirm: () {
                  // YES action: Navigate to Input Characteristics (no API call yet)
                  AppLogger.d('🟠 ImagePreview: User selected "Yes, Add Details"');
                  Navigator.of(dialogContext).pop(); // Dismiss dialog
                  Navigator.pushNamed(
                    context,
                    '/input-characteristics',
                    arguments: {
                      'croppedImagePath': file.path,
                      'imageBytes': pngBytes,
                      'fileName': fileName,
                      'sourceFlow': widget.sourceFlow,
                      'scanModality': widget.scanModality,
                      'sourceTab': widget.sourceTab,
                      'caseId': widget.caseId,
                      'returnResult': widget.returnResult,
                    },
                  ).then((result) {
                    if (!mounted) return;
                    if (result != null) {
                      Navigator.of(context).pop(result);
                    }
                  });
                },
                onCancel: () {
                  // NO action: Call identifyImage API, then fetch mold details
                  AppLogger.d('🔵 ImagePreview: BUTTON CLICKED - No, See Result');
                  Navigator.of(dialogContext).pop();
                  
                  // Call async function to handle the API calls
                  _handleNoSeeResult(context, file.path, pngBytes, fileName);
                },
              );
            },
        );
      }

    } catch (e, s) {
      AppLogger.e('Error during cropping or navigation', error: e, stackTrace: s);
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

  /// Helper method to handle "No, See Result" button action
  Future<void> _handleNoSeeResult(BuildContext context, String imagePath, Uint8List imageBytes, String fileName) async {
    AppLogger.d('🟢 ImagePreview: _handleNoSeeResult called');

    // Use the page-level loading overlay to avoid stacked loading indicators.
    if (mounted) {
      setState(() {
        _isProcessing = true;
      });
    }
    
    try {
      // Step 1: Call identifyImage to get the mold prediction
      AppLogger.d('🟡 ImagePreview: Step 1 - Calling identifyImage API');
      final cameraService = CameraService();
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final modelResult = await cameraService.identifyImage(
        imageBytes: imageBytes,
        filename: fileName,
        sessionCookie: authProvider.cookie,
      );
      AppLogger.d('📊 ImagePreview: identifyImage result: $modelResult');
      
      // Step 2: Get predicted class name from model response
      final predictedClass = modelResult['predicted_class']?.toString() ?? '';
      
      AppLogger.d('🟡 ImagePreview: Step 2 - Predicted class: $predictedClass');
      
      // Step 3: Fetch detailed mold information using full predicted class name
      AppLogger.d('🟡 ImagePreview: Step 3 - Calling getMoldDetails(moldName: $predictedClass)');
      final moldDetails = await cameraService.getMoldDetails(
        moldName: predictedClass,
        sessionCookie: authProvider.cookie,
      );
      
      AppLogger.d('✅ ImagePreview: getMoldDetails completed');
      AppLogger.d('✅ ImagePreview: Response preview: ${moldDetails.toString().substring(0, moldDetails.toString().length > 200 ? 200 : moldDetails.toString().length)}...');
      
      if (moldDetails.containsKey('error')) {
        AppLogger.e('❌ ImagePreview: ERROR in moldDetails response: ${moldDetails['error']}');
      } else {
        AppLogger.d('✅ ImagePreview: moldDetails keys: ${moldDetails.keys.toList()}');
      }
      
      if (!context.mounted) return;
      
      AppLogger.d('🚀 ImagePreview: Navigating to /mold_result with both modelResult and moldDetails');
      final result = await Navigator.of(context).pushNamed(
        '/mold_result',
        arguments: {
          'croppedImagePath': imagePath,
          'modelResult': modelResult,
          'moldDetails': moldDetails,
          'sourceFlow': widget.sourceFlow,
          'scanModality': widget.scanModality,
          'sourceTab': widget.sourceTab,
          'caseId': widget.caseId,
        },
      );

      if (!context.mounted) return;
      if (result != null) {
        Navigator.of(context).pop(result);
        return;
      }
    } catch (e, stackTrace) {
      AppLogger.e('❌ ImagePreview: EXCEPTION in _handleNoSeeResult', error: e, stackTrace: stackTrace);

      if (!context.mounted) return;
      
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: $e')),
        );
        
        // Navigate anyway with error data
        final result = await Navigator.of(context).pushNamed(
          '/mold_result',
          arguments: {
            'croppedImagePath': imagePath,
            'modelResult': {'error': e.toString()},
            'moldDetails': {'error': e.toString()},
            'sourceFlow': widget.sourceFlow,
            'scanModality': widget.scanModality,
            'sourceTab': widget.sourceTab,
            'caseId': widget.caseId,
          },
        );

        if (result != null) {
          Navigator.of(context).pop(result);
          return;
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
