import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moldify/core/utils/logger.dart';

import '../services/auth_service.dart';

class AuthBloc {
  final AuthService authService;
  AuthBloc(this.authService);

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
    AppLogger.d(token);
    final result = await authService.loginOAuth(token);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Google sign-in failed',
        'sessionValue': null,
      };
    }
    final sessionValue = result['sessionValue'];
    return {
      'success': true,
      'error': null,
      'sessionValue': sessionValue,
    };
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      AppLogger.d('GoogleSignIn email: ${googleUser?.email}');
      if (googleUser == null) {
        AppLogger.d('loginWithGoogle: Google sign-in cancelled by user');
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
      AppLogger.d('loginWithGoogle: Google token = $token');
      if (token == null) {
        AppLogger.d('loginWithGoogle: Failed to get Google token');
        return {
          'success': false,
          'error': 'Failed to get Google token',
          'sessionValue': null,
        };
      }
      final result = await loginOAuth(token);
      AppLogger.d('loginWithGoogle: loginOAuth result = $result');
      return result;
    } catch (e) {
      AppLogger.e('loginWithGoogle: Exception', error: e);
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

  Future<Map<String, dynamic>> registerUser(String username, String email, String password, String firstName, String lastName, String address, String phoneNumber, String occupation) async {
    final result = await authService.registerUser(username, email, password, firstName, lastName, address, phoneNumber, occupation);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Registration failed',
      };
    }
    return {
      'success': true,
      'data': result['data'],
      'error': null,
    };
  }

  Future<Map<String, dynamic>> forgotUsername(String email) async {
    final result = await authService.forgotUsername(email);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Forgot username failed',
      };
    }
    return {
      'success': true,
      'data': result['data'],
      'error': null,
    };
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final result = await authService.forgotPassword(email);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Forgot password failed',
      };
    }
    return {
      'success': true,
      'data': result['data'],
      'error': null,
    };
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final result = await authService.verifyCode(email, code);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Verification failed',
      };
    }
    return {
      'success': true,
      'data': result['data'],
      'error': null,
    };
  }

  Future<Map<String,dynamic>> verifiedForgotUsername({required String token}) async {
    final result = await authService.verifiedForgotUsername(token);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Verification failed',
      };
    }
    return {
      'success': true,
      'data': result['data'],
      'error': null,
    };
  }

  Future<Map<String,dynamic>> verifiedForgotPassword(String token, String newPass) async {
    final result = await authService.verifiedForgotPassword(token, newPass);
    if (!result['success']) {
      return {
        'success': false,
        'error': result['error'] ?? 'Verification failed',
      };
    }
    return {
      'success': true,
      'data': result['data'],
      'error': null,
    };
  }
}