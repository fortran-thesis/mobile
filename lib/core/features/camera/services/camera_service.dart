import 'dart:convert';
import 'package:moldify/core/constants/api_url.dart';
import 'package:http/http.dart' as http;

class CameraService {

	/// Gets detailed mold information for a specific genus
	/// [genus] is the mold genus name (e.g., 'Aspergillus')
	/// Returns a map with mold details including taxonomy, fungicides, etc.
	Future<Map<String, dynamic>> getMoldDetails({required String genus, String? sessionCookie}) async {
		print('CameraService: getMoldDetails called for genus=$genus');
		final uri = Uri.parse('${ApiUrl.baseUrl}/api/v1/molds/$genus');
		final headers = <String, String>{'Content-Type': 'application/json'};
		if (sessionCookie != null) {
			headers['Cookie'] = 'session=$sessionCookie';
		}
		try {
			final response = await http.get(uri, headers: headers);
			print('Response status: ${response.statusCode}');
			print('Response body: "${response.body}"');
			if (response.statusCode == 200) {
				final Map<String, dynamic> jsonResponse = json.decode(response.body);
				return jsonResponse;
			} else {
				return {'error': 'Failed to fetch mold details: ${response.statusCode}'};
			}
		} catch (e) {
			print('Error fetching mold details: $e');
			return {'error': 'Error: $e'};
		}
	}

	/// Sends an image to the ML model API for identification as JSON with base64 encoded image.
	/// [imageBytes] is the image data as bytes.
	/// [filename] is the name of the file (for logging purposes).
	/// Returns a map with predicted_class, probability, probabilities array, and metadata.
	Future<Map<String, dynamic>> identifyImage({
		required List<int> imageBytes, 
		required String filename, 
		String? sessionCookie,
		Map<String, dynamic>? characteristics,
	}) async {
		print('CameraService: identifyImage called (JSON with base64)');
		print('Image bytes length: ${imageBytes.length}');
		print('Url: ${ApiUrl.modelUrl}/v2/predict');
		
		// Convert image bytes to base64
		final String imageBase64 = base64Encode(imageBytes);
		print('Base64 encoded image length: ${imageBase64.length}');
		
		final uri = Uri.parse('${ApiUrl.modelUrl}/v2/predict');
		
		// Build request body
		final Map<String, dynamic> requestBody = {
			'image_b64': imageBase64,
		};
		
		// Add characteristics if provided (empty object if not)
		if (characteristics != null && characteristics.isNotEmpty) {
			requestBody['characteristics'] = characteristics;
			print('Including characteristics: $characteristics');
		} else {
			requestBody['characteristics'] = {};
			print('No characteristics provided, sending empty object');
		}
		
		// Set headers
		final headers = <String, String>{
			'Content-Type': 'application/json',
		};
		if (sessionCookie != null) {
			headers['Cookie'] = 'session=$sessionCookie';
		}
		
		try {
			// Send POST request with JSON body
			final response = await http.post(
				uri,
				headers: headers,
				body: json.encode(requestBody),
			);
			
			print('Response status: ${response.statusCode}');
			print('Response body: "${response.body}"');
			
			if (response.statusCode == 200) {
				final Map<String, dynamic> jsonResponse = json.decode(response.body);
				
				// Parse the new response format
				// Response: {probabilities: [0.02, 0.92, 0.04, 0.01, 0.01, 0.0], used_ann: true, multimodal_meta_present: true, ann_probabilities: [0.15, 0.85]}
				// Order: [Alternaria, Aspergillus flavi, Aspergillus niger, Penicillium, Fusarium, Rhizopus]
				// ANN order: [Alternaria, Aspergillus flavi]
				
				final List<dynamic> probabilities = jsonResponse['probabilities'] ?? [];
				final bool usedAnn = jsonResponse['used_ann'] ?? false;
				final bool multimodalMetaPresent = jsonResponse['multimodal_meta_present'] ?? false;
				final List<dynamic>? annProbabilities = jsonResponse['ann_probabilities'];
				
				// Class names in order
				final List<String> classNames = [
					'Alternaria',
					'Aspergillus_flavi',
					'Aspergillus_niger',
					'Penicillium',
					'Fusarium',
					'Rhizopus',
				];
				
				// Find the class with highest probability
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
				
				print('Predicted class: $predictedClass with probability: $maxProbability');
				print('Used ANN: $usedAnn, Multimodal meta present: $multimodalMetaPresent');
				
				return {
					'predicted_class': predictedClass,
					'probability': maxProbability,
					'all_probabilities': probabilities,
					'used_ann': usedAnn,
					'multimodal_meta_present': multimodalMetaPresent,
					'ann_probabilities': annProbabilities,
				};
			} else {
				print('Error: API returned status ${response.statusCode}');
				return {
					'predicted_class': null,
					'probability': null,
					'all_probabilities': null,
					'error': 'API error: ${response.statusCode}',
				};
			}
		} catch (e, stackTrace) {
			print('Exception in identifyImage: $e');
			print('Stack trace: $stackTrace');
			return {
				'predicted_class': null,
				'probability': null,
				'all_probabilities': null,
				'error': 'Exception: $e',
			};
		}
	}
}
