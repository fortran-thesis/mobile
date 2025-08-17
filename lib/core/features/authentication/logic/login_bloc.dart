import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth_service.dart';

class LoginBloc {
  final AuthService authService;
  LoginBloc(this.authService);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await authService.login(username, password);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Login failed',
        'sessionValue': null,
      };
    }
    final cookieString = result['cookie'];
    String? sessionValue;
    if (cookieString != null) {
      sessionValue = cookieString.split(';').first.split('=').last;
    }
    return {
      'success': true,
      'error': null,
      'sessionValue': sessionValue,
    };
  }

  Future<Map<String, dynamic>> loginOAuth(String token) async {
    final result = await authService.loginOAuth(token);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Google sign-in failed',
        'sessionValue': null,
      };
    }
    final cookieString = result['cookie'];
    String? sessionValue;
    if (cookieString != null) {
      sessionValue = cookieString.split(';').first.split('=').last;
    }
    return {
      'success': true,
      'error': null,
      'sessionValue': sessionValue,
    };
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return {
          'success': false,
          'error': 'Google sign-in cancelled by user',
          'sessionValue': null,
        };
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final token = await userCredential.user?.getIdToken(true);
      if (token == null) {
        return {
          'success': false,
          'error': 'Failed to get Google token',
          'sessionValue': null,
        };
      }
      final result = await loginOAuth(token);
      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Google sign-in failed: $e',
        'sessionValue': null,
      };
    }
  }

  Future<Map<String, dynamic>> loginWithUsernamePassword(String username, String password) async {
    try {
      final result = await login(username, password);
      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Login failed: $e',
        'sessionValue': null,
      };
    }
  }
}