class CameraModelResult {
  final String predictedClass;
  final double probability;
  final Map<String, double> allProbabilities;

  CameraModelResult({
    required this.predictedClass,
    required this.probability,
    required this.allProbabilities,
  });

  factory CameraModelResult.fromJson(Map<String, dynamic> json) {
    final allProbsRaw = json['all_probabilities'] as Map<String, dynamic>? ?? {};
    final allProbs = allProbsRaw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    return CameraModelResult(
      predictedClass: json['predicted_class'] ?? '',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      allProbabilities: allProbs,
    );
  }
}
