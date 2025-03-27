// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import '../../../controllers/auth_controller.dart';
// import '../../../core/routes/app_pages.dart';
// import '../../../core/utils/logs.dart';
// import '../../../widgets/circular_loader/circular_loader.dart';
// import '../../../widgets/snackbar/custom_snackbar.dart';
// import '../controller/auth_controller.dart';
//
// class AuthHelpers {
//   static final AuthController _authController = Get.find<AuthController>();
//
//   static Future<void> handleEmailVerification({required User user}) async {
//     if (!user.emailVerified) {
//       Get.offAllNamed(Routes.emailVerificationScreen, arguments: user);
//     } else {
//       Get.offAllNamed(Routes.initialScreen);
//     }
//   }
//
//   static Future<void> checkEmailVerification(
//       {required User currentUser}) async {
//     await currentUser.reload().then((value) {
//       final user = FirebaseAuth.instance.currentUser;
//
//       if (user?.emailVerified ?? false) {
//         Get.offAllNamed(Routes.initialScreen);
//       }
//     });
//   }
//
//   static setTimerForAutoRedirect() {
//     const Duration timerPeriod = Duration(seconds: 5);
//     Timer.periodic(
//       timerPeriod,
//       (timer) async {
//         await FirebaseAuth.instance.currentUser?.reload().then((value) {
//           final user = FirebaseAuth.instance.currentUser;
//
//           if (user?.emailVerified ?? false) {
//             timer.cancel();
//
//             Get.offAllNamed(Routes.successfulVerificationScreen);
//           }
//         });
//       },
//     );
//   }
//
//   static Future<String?> getCurrentUserToken() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         String? token = await user.getIdToken();
//         return token;
//       } else {
//         return null;
//       }
//     } catch (e) {
//       DevLogs.logError('Error getting user token: $e');
//       return null;
//     }
//   }
//
//   static void validateAndSubmitLoginForm({required String password,required String email, }) async {
//     if (password.isEmpty) {
//       CustomSnackBar.showErrorSnackbar(message: 'Password is required.');
//       return;
//     }
//
//     if (password.length < 8) {
//       CustomSnackBar.showErrorSnackbar(message: 'Password too Short');
//       return;
//     }
//
//     if (!GetUtils.isEmail(email)) {
//       CustomSnackBar.showErrorSnackbar(message: 'Please input a valid email');
//       return;
//     }
//
//     Get.showOverlay(
//       asyncFunction: () => _authController.login(email: email, password: password),
//       loadingWidget: CustomLoader(
//         message: 'Logging in',
//       ),
//     );
//   }
//
//   static void validateAndSubmitSignUpForm({required String username, required String password,required String email}) async {
//     if (!GetUtils.isEmail(email)) {
//       CustomSnackBar.showErrorSnackbar(message: 'Please input a valid email');
//       return;
//     }
//
//     if (password.isEmpty) {
//       CustomSnackBar.showErrorSnackbar(message: 'Password is required.');
//       return;
//     }
//
//     if (username.isEmpty) {
//       CustomSnackBar.showErrorSnackbar(message: 'Username is required.');
//       return;
//     }
//
//     if (password.length < 8) {
//       CustomSnackBar.showErrorSnackbar(message: 'Password too Short');
//       return;
//     }
//
//
//     Get.showOverlay(
//       asyncFunction: () => _authController.signUp(
//           email: email.trim(),
//           password: password.trim(),
//           username: username.trim()
//       ),
//       loadingWidget: CustomLoader(
//         message: 'Signing up',
//       ),
//     );
//   }
//
//   static void validatePasswordUpdate({required String oldPass,required String newPass, required String confirmPass }) async {
//     if (oldPass.isEmpty) {
//       CustomSnackBar.showErrorSnackbar(message: 'Password is required.');
//       return;
//     }
//
//     if (oldPass.length < 8) {
//       CustomSnackBar.showErrorSnackbar(message: 'Old Password too Short');
//       return;
//     }
//
//     if (newPass.length < 8) {
//       CustomSnackBar.showErrorSnackbar(message: 'New Password too Short');
//       return;
//     }
//
//     if (newPass == oldPass) {
//       CustomSnackBar.showErrorSnackbar(message: 'Old password is the same as the new Password');
//       return;
//     }
//
//     if (newPass != confirmPass) {
//       CustomSnackBar.showErrorSnackbar(message: 'Passwords don`t match');
//       return;
//     }
//
//     Get.showOverlay(
//       asyncFunction: () => _authController.updatePassword(
//         newPassword: confirmPass.trim(),
//         currentPassword: oldPass.trim(),
//       ),
//       loadingWidget: const CustomLoader(
//         message: 'Changing Password',
//       ),
//     );
//
//   }
//
//   static void signOut() async {
//     Get.showOverlay(
//       asyncFunction: () => _authController.signOut().then((value) => Get.offAllNamed(Routes.initialScreen)),
//       loadingWidget: const CustomLoader(
//         message: 'Signing out',
//       ),
//     );
//
//   }
// }
