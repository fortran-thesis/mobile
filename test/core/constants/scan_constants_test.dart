import 'package:flutter_test/flutter_test.dart';
import 'package:moldify/core/constants/scan_constants.dart';

void main() {
  test('low confidence threshold is set to 85 percent', () {
    expect(ScanConstants.lowConfidenceThreshold, 85.0);
  });
}
