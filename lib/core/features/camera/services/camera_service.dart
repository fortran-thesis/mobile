import 'dart:convert';
import 'package:moldify/core/config/cache_config.dart';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';

class CameraService {
  final ApiService _moldApi = ApiService(baseUrl: '${ApiUrl.baseUrl}/api/v1/molds');
  final ApiService _modelApi = ApiService(baseUrl: ApiUrl.modelUrl);

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

		// Build request body
		final Map<String, dynamic> requestBody = {
			'image_b64': imageBase64,
			'characteristics': characteristics ?? {},
		};

		try {
			final response = await _modelApi.post(
				'/v2/predict',
				headers: {'Content-Type': 'application/json'},
				body: requestBody,
				sessionCookie: sessionCookie,
			);

			if (response.statusCode == 200) {
				final Map<String, dynamic> jsonResponse = response.data as Map<String, dynamic>;

				final List<dynamic> probabilities = jsonResponse['probabilities'] ?? [];
				final bool usedAnn = jsonResponse['used_ann'] ?? false;
				final bool multimodalMetaPresent = jsonResponse['multimodal_meta_present'] ?? false;
				final List<dynamic>? annProbabilities = jsonResponse['ann_probabilities'];

				final List<String> classNames = [
					'Alternaria',
					'Aspergillus_flavi',
					'Aspergillus_niger',
					'Penicillium',
					'Fusarium',
					'Rhizopus',
				];

				String predictedClass = '';
				double maxProbability = 0.0;

				if (probabilities.isNotEmpty) {
					for (int i = 0; i < probabilities.length && i < classNames.length; i++) {
						final prob = (probabilities[i] as num).toDouble();
						if (prob > maxProbability) {
							maxProbability = prob;
							predictedClass = classNames[i];
						}
					}
				}

				return {
					'predicted_class': predictedClass,
					'probability': maxProbability,
					'all_probabilities': probabilities,
					'used_ann': usedAnn,
					'multimodal_meta_present': multimodalMetaPresent,
					'ann_probabilities': annProbabilities,
				};
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
}
