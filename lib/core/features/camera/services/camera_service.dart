import 'dart:convert';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class CameraService {
  final ApiService _moldApi = ApiService(baseUrl: '${ApiUrl.baseUrl}/api/v1/molds');
  final ApiService _modelApi = ApiService(baseUrl: ApiUrl.model);

	/// Gets detailed mold information for a specific genus
	Future<Map<String, dynamic>> getMoldDetails({required String genus, String? sessionCookie}) async {
		try {
			final response = await _moldApi.get(
				'/$genus',
				headers: {'Content-Type': 'application/json'},
				sessionCookie: sessionCookie,
				cacheOptions: CacheConfig.staticData,
			);
			if (response.statusCode == 200) {
				return response.data as Map<String, dynamic>;
			} else {
				return {'error': 'Failed to fetch mold details: ${response.statusCode}'};
			}
		} catch (e) {
			return {'error': 'Error: $e'};
		}
	}

	/// Sends an image to the ML model API for identification as JSON with base64 encoded image.
	Future<Map<String, dynamic>> identifyImage({
		required List<int> imageBytes,
		required String filename,
		String? sessionCookie,
		Map<String, dynamic>? characteristics,
	}) async {
		// Convert image bytes to base64
		final String imageBase64 = base64Encode(imageBytes);

		// Build request body — forwarded to the API proxy at /api/v1/model/predict
		final Map<String, dynamic> requestBody = {
			'image_b64': imageBase64,
			if (characteristics != null && characteristics.isNotEmpty)
				'characteristics': characteristics,
		};

		try {
			final response = await _modelApi.post(
				'/predict',
				headers: {'Content-Type': 'application/json'},
				body: requestBody,
				sessionCookie: sessionCookie,
			);

			if (response.statusCode == 200) {
				final Map<String, dynamic> json = response.data as Map<String, dynamic>;

				// The proxy injects _model_source so we know exactly which endpoint
				// responded and which shape to parse.
				final String source = json['_model_source']?.toString() ?? '';

				if (source == 'fusion') {
					return _parseFusionResponse(json);
				} else if (source == 'legacy') {
					return _parseLegacyResponse(json);
				} else {
					// Unknown/missing tag — attempt fusion shape then legacy as last resort.
					if (json.containsKey('fusion')) return _parseFusionResponse(json);
					if (json.containsKey('predicted_class')) return _parseLegacyResponse(json);
					return {
						'predicted_class': null,
						'probability': null,
						'all_probabilities': null,
						'error': 'Unrecognised response format from model API',
					};
				}
			} else {
				return {
					'predicted_class': null,
					'probability': null,
					'all_probabilities': null,
					'error': 'API error: ${response.statusCode}',
				};
			}
		} catch (e) {
			return {
				'predicted_class': null,
				'probability': null,
				'all_probabilities': null,
				'error': 'Exception: $e',
			};
		}
	}

	/// Combines image identification + mold details lookup in a single API call.
	/// Endpoint: POST /api/v1/model/predict-with-details
	/// Returns prediction + matching mold information from CMS.
	Future<Map<String, dynamic>> identifyImageWithMoldDetails({
		required List<int> imageBytes,
		required String filename,
		String? sessionCookie,
		Map<String, dynamic>? characteristics,
	}) async {
		// Convert image bytes to base64
		final String imageBase64 = base64Encode(imageBytes);

		// Build request body — Same as identifyImage but to the combined endpoint
		final Map<String, dynamic> requestBody = {
			'image_b64': imageBase64,
			if (characteristics != null && characteristics.isNotEmpty)
				'characteristics': characteristics,
		};

		try {
			final response = await _modelApi.post(
				'/predict-with-details',
				headers: {'Content-Type': 'application/json'},
				body: requestBody,
				sessionCookie: sessionCookie,
			);

			if (response.statusCode == 200) {
				final Map<String, dynamic> json = response.data as Map<String, dynamic>;

				// Extract prediction result
				final Map<String, dynamic>? fusionPred = json['fusion'] as Map<String, dynamic>?;
				final Map<String, dynamic>? moldDetail = json['mold_detail'] as Map<String, dynamic>?;

				// Parse prediction using existing parser
				final Map<String, dynamic> predictionResult = fusionPred != null
					? _parseSubResult(fusionPred, json)
					: {
						'predicted_class': null,
						'probability': null,
						'all_probabilities': null,
						'error': 'No prediction in response',
					};

				// Return combined result with mold details attached
				return {
					...predictionResult,
					'mold_detail': moldDetail,
					'from_combined_endpoint': true,
				};
			} else {
				return {
					'predicted_class': null,
					'probability': null,
					'all_probabilities': null,
					'mold_detail': null,
					'error': 'API error: ${response.statusCode}',
				};
			}
		} catch (e) {
			return {
				'predicted_class': null,
				'probability': null,
				'all_probabilities': null,
				'mold_detail': null,
				'error': 'Exception: $e',
			};
		}
	}

	// ── Response parsers ────────────────────────────────────────────────────

	/// Parses a v3 fusion response.
	///
	/// Shape: `{ fusion: { predicted_class, confidence (0–100), probabilities: [{class_name, probability}] },
	///           cnn: {...}, used_fusion: bool, used_ann: bool }`
	static const List<String> _fusionClassOrder = [
		'Alternaria_spp',
		'Aspergillus_section_Flavi',
		'Aspergillus_section_Nigri',
		'Fusarium_spp',
		'Penicillium_spp',
		'Rhizopus_spp',
	];

	Map<String, dynamic> _parseFusionResponse(Map<String, dynamic> json) {
		final Map<String, dynamic>? result = json['fusion'] as Map<String, dynamic>?;
		if (result == null) {
			// Fusion key absent but source said fusion — degrade to CNN sub-object
			return _parseSubResult(json['cnn'] as Map<String, dynamic>?, json);
		}
		return _parseSubResult(result, json);
	}

	/// Parses a v2 legacy response.
	///
	/// Shape A (structured): `{ predicted_class, confidence (0–100), probabilities: [{class_name, probability}] }`
	/// Shape B (flat floats): `{ probabilities: [0.1, 0.9, ...] }` — maps against [_fusionClassOrder].
	Map<String, dynamic> _parseLegacyResponse(Map<String, dynamic> json) {
		// v2 puts results at top level; if absent try 'cnn' sub-object
		if (json.containsKey('predicted_class')) {
			return _parseSubResult(json, json);
		}
		return _parseSubResult(json['cnn'] as Map<String, dynamic>?, json);
	}

	/// Shared parser for a single result object (`fusion`, `cnn`, or top-level).
	Map<String, dynamic> _parseSubResult(
		Map<String, dynamic>? result,
		Map<String, dynamic> root,
	) {
		if (result == null) {
			return {
				'predicted_class': null,
				'probability': null,
				'all_probabilities': null,
				'error': 'Unexpected response format from model API',
			};
		}

		final String predictedClass = result['predicted_class']?.toString() ?? '';
		// confidence is 0–100; normalise to 0–1 for backwards UI compatibility
		final double confidence = ((result['confidence'] as num?) ?? 0.0).toDouble();
		final double probability = confidence / 100.0;

		final dynamic rawProbs = result['probabilities'];
		final Map<String, double> allProbabilities;

		if (rawProbs is List && rawProbs.isNotEmpty) {
			if (rawProbs.first is Map) {
				// Structured list: [{ class_name, probability }, ...]
				allProbabilities = {
					for (final entry in rawProbs.cast<Map<String, dynamic>>())
						(entry['class_name']?.toString() ?? ''): ((entry['probability'] as num?) ?? 0.0).toDouble(),
				};
			} else {
				// Flat float list indexed by class order (legacy v2 format)
				allProbabilities = {
					for (int i = 0; i < rawProbs.length && i < _fusionClassOrder.length; i++)
						_fusionClassOrder[i]: ((rawProbs[i] as num?) ?? 0.0).toDouble(),
				};
			}
		} else {
			allProbabilities = {};
		}

		return {
			'predicted_class': predictedClass,
			'probability': probability,
			'all_probabilities': allProbabilities,
			'used_ann': root['used_ann'] ?? false,
			'used_fusion': root['used_fusion'] ?? false,
			'model_source': root['_model_source'] ?? 'unknown',
		};
	}
}
