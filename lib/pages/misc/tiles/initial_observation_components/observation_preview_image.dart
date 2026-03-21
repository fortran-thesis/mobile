import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

/// Reusable preview image renderer for observation cards.
///
/// Supports three path types to keep UI fetch-ready and flexible:
/// 1. Asset path: starts with `assets/`
/// 2. Remote URL: starts with `http://` or `https://`
/// 3. Local file path: any other non-empty path
///
/// Parameters:
/// - [imagePath]: Required source path for image rendering.
/// - [fit]: How the image should be inscribed into its box.
class ObservationPreviewImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ObservationPreviewImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = imagePath.trim();
    final isAsset = normalized.startsWith('assets/');
    final isRemote =
        normalized.startsWith('http://') || normalized.startsWith('https://');

    if (isAsset) {
      return Image.asset(
        normalized,
        fit: fit,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );
    }

    if (isRemote) {
      return Image.network(
        normalized,
        fit: fit,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const _ImageFallback(showLoader: true);
        },
      );
    }

    return Image.file(
      File(normalized),
      fit: fit,
      errorBuilder: (_, __, ___) => const _ImageFallback(),
    );
  }
}

/// Shared fallback widget for failed/slow image loading states.
class _ImageFallback extends StatelessWidget {
  final bool showLoader;

  const _ImageFallback({this.showLoader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MoldifyColors.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: showLoader
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              Icons.broken_image_outlined,
              size: 28,
              color: MoldifyColors.primaryColor,
            ),
    );
  }
}
