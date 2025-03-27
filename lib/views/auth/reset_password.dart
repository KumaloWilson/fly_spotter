import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              Obx(() {
                if (authController.errorMessage.isNotEmpty) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      authController.errorMessage.value,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 30),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () async {
                  await authController.resetPassword(emailController.text.trim());
                  if (authController.errorMessage.isEmpty) {
                    Get.snackbar(
                      'Success',
                      'Password reset link sent to your email',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: authController.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Send Reset Link'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

