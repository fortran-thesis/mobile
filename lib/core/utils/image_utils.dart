import 'package:flutter/material.dart';

/// Returns an Image widget from a URL, or null if the URL is null or empty.
Image? imageFromUrlOrNull(String? url) {
  if (url == null || url.isEmpty) return null;
  return Image.network(url);
}

