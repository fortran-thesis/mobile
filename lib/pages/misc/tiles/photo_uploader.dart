import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moldify/pages/misc/colors.dart';


import 'bottom_sheet.dart';
import 'bottom_sheet_contents/photo_options_content.dart';

/// A reusable photo uploader widget with gallery and camera options.
///
/// Features:
/// - Uses custom bottom sheet (BuildBottomSheet + PhotoOptionsBottomSheetContent)
/// - Supports up to 5 photos.
/// - Shows upload progress indicators.
/// - Emits updates via [onPhotosChanged] callback.
/// - Fully reusable with customizable title and option label.
///
/// Example:
/// ```dart
/// PhotoUploader(
///   title: "Upload New Photo",
///   photoOptionLabel: "Use Camera",
///   onPhotosChanged: (photos) => print("Total photos: ${photos.length}"),
/// )
/// ```
class PhotoUploader extends StatefulWidget {
  final String? photoOptionLabel;
  final ValueChanged<List<File>>? onPhotosChanged;

  const PhotoUploader({
    super.key,
    this.photoOptionLabel,
    this.onPhotosChanged,
  });

  @override
  State<PhotoUploader> createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _photos = [];
  final List<double> _progress = [];

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BuildBottomSheet(
          showDragHandle: true,
          child: PhotoOptionsBottomSheetContent(
            onUploadPhoto: _pickFromGallery,
            onRemovePhoto: _useCamera,
            label2: 'Use Camera',
            label2Icon: FontAwesomeIcons.camera,
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    Navigator.pop(context);
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      for (var img in images) {
        if (_photos.length >= 5) {
          _showLimitSnackBar();
          break;
        }
        // Copy XFile to persistent temp file immediately
        try {
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = img.name;
          final tempFile = File('${tempDir.path}/${timestamp}_$fileName');
          
          final bytes = await img.readAsBytes();
          final savedFile = await tempFile.writeAsBytes(bytes);
          
          _addPhoto(savedFile);
        } catch (e) {
          // Skip files that can't be copied
          continue;
        }
      }
    }
  }

  Future<void> _useCamera() async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      if (_photos.length >= 5) {
        _showLimitSnackBar();
      } else {
        // Copy XFile to persistent temp file immediately
        try {
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = image.name;
          final tempFile = File('${tempDir.path}/${timestamp}_$fileName');
          
          final bytes = await image.readAsBytes();
          final savedFile = await tempFile.writeAsBytes(bytes);
          
          _addPhoto(savedFile);
        } catch (e) {
          // Skip files that can't be copied
          return;
        }
      }
    }
  }

  void _addPhoto(File file) {
    setState(() {
      _photos.add(file);
      _progress.add(0.0);
    });

    _notifyParent();
    _simulateProgress();
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      _progress.removeAt(index);
    });

    _notifyParent();
  }

  void _simulateProgress() {
    for (int i = 0; i < _progress.length; i++) {
      if (_progress[i] < 1.0) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _progress[i] = (_progress[i] + 0.1).clamp(0.0, 1.0);
            });
            _simulateProgress();
          }
        });
        break;
      }
    }
  }

  void _showLimitSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You can only upload up to 5 photos.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _notifyParent() {
    if (widget.onPhotosChanged != null) {
      // Create a copy of the list to prevent parent from referencing
      // PhotoUploader's internal _photos list directly
      widget.onPhotosChanged!([..._photos]);
    }
  }
  String _formatFileSize(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    if (bytes >= mb) {
      return "${(bytes / mb).toStringAsFixed(1)} MB";
    } else if (bytes >= kb) {
      return "${(bytes / kb).toStringAsFixed(0)} KB";
    } else {
      return "$bytes B";
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showPhotoOptions,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: MoldifyColors.taupe,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                    Icons.image,
                    size: 50,
                    color: MoldifyColors.accentColor
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MoldifyColors.backgroundColor,
                      borderRadius: BorderRadius.circular(20)
                    ),
                      child: const Icon(
                          FontAwesomeIcons.pen,
                          color: MoldifyColors.accentColor,
                          size: 18
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: const Text(
            "Please add up to 5 clear photos for better review.",
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'Bricolage-Grotesque-Regular'
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._photos.asMap().entries.map((entry) {
          int index = entry.key;
          File photo = entry.value;
          double progress = _progress[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MoldifyColors.taupe,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                      photo,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // File name
                      Text(
                        photo.path.split('/').last,
                        style: TextStyle(
                          fontFamily: 'Montserrat-ExtraBold',
                          color: MoldifyColors.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // File size
                      Text(
                        _formatFileSize(photo.lengthSync()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Bricolage-Grotesque-Regular',
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: MoldifyColors.backgroundColor,
                                color: MoldifyColors.accentColor,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MoldifyColors.MoldifyBlack,
                              fontFamily: 'Bricolage-Grotesque-Regular',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
