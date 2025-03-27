import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:specifier/views/home/home.dart';

import '../../../controllers/auth_controller.dart';
import '../login_screen.dart';
class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();


    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        }

        if (authSnapshot.hasError) {
          return _buildErrorScreen(context, 'Failed to fetch user state.');
        }

        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            authController.updateUser(user);

            if (!user.emailVerified) {
              //await AuthHelpers.handleEmailVerification(user: user);
            }
          });

          return const HomeScreen();
        }


        return LoginScreen();
      },
    );

  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          message,
        ),
      ),
    );
  }
}
