import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:specifier/views/auth/handler/auth_handler.dart';
import '../models/user_Model.dart';
import '../services/auth_services.dart';
import '../services/firestore_service.dart';
import '../services/species_initializer.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to FirebaseAuth's user changes
    firebaseUser.value = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) async{
      firebaseUser.value = user;
      if(user != null) {
        loadUserData(user);

        await SpeciesInitializer().importSpeciesIfNeeded();
      }
    });
  }

  void updateUser(User newUser) {
    firebaseUser.value = newUser;
  }

  // Load user data from Firestore
  Future<void> loadUserData(User user) async {
    isLoading.value = true;
    try {
      // Attempt to fetch user model from Firestore
      userModel.value = await _firestoreService.getUser(user.uid);

    } catch (e) {
      // Handle error in loading user data
      errorMessage.value = 'Failed to load user data';
      // Optionally sign out if user data can't be loaded
      await signOut();
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      // Navigation handled by auth state changes listener
    } catch (e) {
      errorMessage.value = _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Register with email and password
  Future<void> register(String email, String password, String name) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.registerWithEmailAndPassword(email, password, name);
      Get.offAll(() => AuthHandler());
    } catch (e) {
      errorMessage.value = _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.signInWithGoogle();
      // Navigation handled by auth state changes listener
    } catch (e) {
      errorMessage.value = _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    isLoading.value = true;

    try {
      await _authService.signOut();
      // Navigation handled by auth state changes listener
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.resetPassword(email);
    } catch (e) {
      errorMessage.value = _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Update Firebase Auth profile
      await _authService.updateProfile(
        displayName: name,
        photoURL: photoUrl,
      );

      // Update Firestore user
      if (userModel.value != null) {
        UserModel updatedUser = userModel.value!.copyWith(
          name: name ?? userModel.value!.name,
          photoUrl: photoUrl ?? userModel.value!.photoUrl,
        );

        await _firestoreService.updateUser(updatedUser);
        userModel.value = updatedUser;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Handle Firebase Auth errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    }
    return error.toString();
  }
}