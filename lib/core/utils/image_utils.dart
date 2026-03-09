import 'package:flutter/material.dart';

/// Returns an Image widget from a URL, or null if the URL is null or empty.
Image? imageFromUrlOrNull(String? url) {
  final normalized = url?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return Image.network(normalized);
}
