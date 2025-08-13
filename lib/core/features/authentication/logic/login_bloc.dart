import '../services/auth_service.dart';

class LoginBloc {
  final AuthService authService;
  LoginBloc(this.authService);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await authService.login(username, password);
    // handle result, update state, etc.
    return result; // or your own logic
  }

  Future<Map<String, dynamic>> loginOAuth(String token) async {
    final result = await authService.loginOAuth(token);
    // handle result, update state, etc.
    return result; // or your own logic
  }
}