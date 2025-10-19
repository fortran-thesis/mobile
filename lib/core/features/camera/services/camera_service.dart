import 'dart:convert';
import 'package:moldify/core/constants/api_url.dart';
import 'package:moldify/services/api_service.dart';
import 'package:http/http.dart' as http;

class CameraService {
	final ApiService _apiService = ApiService(baseUrl: ApiUrl.modelUrl);

		/// Sends an image to the ML model API for identification as multipart/form-data.
		/// [imageBytes] is the raw bytes of the image file.
		/// [filename] is the name of the file to send.
		/// Returns a map with success, data, and error fields.
		Future<Map<String, dynamic>> identifyImage({required List<int> imageBytes, required String filename, String? sessionCookie}) async {
			print('CameraService: identifyImage called (multipart)');
			print('Image bytes length: ${imageBytes.length}');
			final uri = Uri.parse(ApiUrl.modelUrl + '/predict');
			final request = http.MultipartRequest('POST', uri);
			request.files.add(
				http.MultipartFile.fromBytes('image', imageBytes, filename: filename),
			);
			if (sessionCookie != null) {
				request.headers['Cookie'] = 'session=$sessionCookie';
			}
			// Add any additional headers if needed
			final streamedResponse = await request.send();
			final response = await http.Response.fromStream(streamedResponse);
			print('Response status: ${response.statusCode}');
			print('Response body: "${response.body}"');
			final Map<String, dynamic> jsonResponse = response.body.isNotEmpty ? json.decode(response.body) : {};
			return {
			  'predicted_class': jsonResponse['predicted_class'],
			  'probability': jsonResponse['probability'],
			  'all_probabilities': jsonResponse['all_probabilities'],
			  //'success': jsonResponse['success'] ?? false,
			  //'data': jsonResponse['data'],
			  //'error': jsonResponse['error'],
			};
		}
}
