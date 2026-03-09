class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

class UserDto {
  final String username;
  final String password;

  UserDto({required this.username, required this.password});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(username: json['username'] as String,
                   password: json['password'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'username': username,
    'password': password};
  }
}
