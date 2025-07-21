import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/repositories/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login), // Replace with a Google icon later
          label: const Text('Sign in with Google'),
          onPressed: () {
            ref.read(authRepositoryProvider).signInWithGoogle();
          },
        ),
      ),
    );
  }
}