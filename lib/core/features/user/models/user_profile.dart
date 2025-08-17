class UserProfile {
  final String id;
  final String username;
  final String role;
  final bool isBanned;
  final String email;
  final String photoUrl;
  final bool disabled;

  UserProfile({
    required this.id,
    required this.username,
    required this.role,
    required this.isBanned,
    required this.email,
    required this.photoUrl,
    required this.disabled,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final user = data['user'];
    final details = data['details'];
    return UserProfile(
      id: data['id'],
      username: user['username'],
      role: user['role'],
      isBanned: user['is_banned'],
      email: details['email'],
      photoUrl: details['photo_url'],
      disabled: details['disabled'],
    );
  }
}