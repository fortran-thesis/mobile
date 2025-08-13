import 'package:flutter/material.dart';
import 'package:moldify/core/features/authentication/services/test_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Session Cookie'),
                  content: Text(authProvider.cookie ?? 'No cookie'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              final String sessionValue = "lol";
              String message;
              try {
                final result = await TestService().getSecure(sessionValue);
                message = 'Status: ${result['success']}\nBody: ${result['data']}\nError: ${result['error'] ?? 'None'}';
              } catch (e) {
                message = 'Error: $e';
              }
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Test Endpoint Result'),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.clearCookie();
              Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome! Your session cookie is:\n${authProvider.cookie ?? "No cookie"}'),
      ),
    );
  }
}
