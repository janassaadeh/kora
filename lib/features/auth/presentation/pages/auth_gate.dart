import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kora/core/common/app_loader.dart';

import 'package:kora/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:kora/features/main_shell/presentation/screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: AppLoader()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return MainScreen(); // logged in
        } else {
          return const SignInScreen(); // not logged in
        }
      },
    );
  }
}