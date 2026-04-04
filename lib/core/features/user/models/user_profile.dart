import 'package:moldify/core/utils/logger.dart';

class UserProfile {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String address;
  final String phoneNumber;
  final String role;
  final bool isBanned;
  final String email;
  final String photoUrl;
  final bool disabled;
  final String? occupation;

  UserProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phoneNumber,
    required this.role,
    required this.isBanned,
    required this.email,
    required this.photoUrl,
    required this.disabled,
    this.occupation,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    AppLogger.d('Raw JSON: $json');
    final user = data['user'];
    final details = data['details'];
    // Defensive parsing: some backends may return null or different types
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    String safeString(dynamic v) => v == null ? '' : v.toString();

    // normalize/convert legacy role strings to current app roles
    final rawRole = safeString(user['role']).toLowerCase();
    String mappedRole;
    if (rawRole == 'user') {
      mappedRole = 'farmer';
    } else if (rawRole == 'curator') {
      mappedRole = 'mycologist';
    } else {
      mappedRole = rawRole;
    }

    return UserProfile(
      id: safeString(data['id']),
      username: safeString(user['username']),
      role: mappedRole,
      isBanned: parseBool(user['is_banned']),
      email: safeString(details['email']),
      photoUrl: safeString(details?['photo_url']),
      disabled: parseBool(details['disabled']),
      firstName: safeString(user['first_name']),
      lastName: safeString(user['last_name']),
      address: safeString(user['address']),
      phoneNumber: safeString(details?['phone_number']),
      occupation: user['occupation'] != null ? safeString(user['occupation']) : null,
    );
  }
}