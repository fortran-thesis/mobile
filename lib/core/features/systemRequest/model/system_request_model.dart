class SystemRequestResponse {
  final bool success;
  final String message;

  SystemRequestResponse({
    required this.success,
    required this.message,
  });

  factory SystemRequestResponse.fromJson(Map<String, dynamic> json) {
    return SystemRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
