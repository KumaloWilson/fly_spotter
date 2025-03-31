import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:specifier/services/supabase_service.dart';
import 'package:specifier/utiils/app_theme.dart';
import 'package:specifier/views/splash/splash.dart';
import 'controllers/archievements_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/identification_controller.dart';
import 'controllers/map_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SupabaseManager.initialize();
  await GetStorage.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize controllers
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(IdentificationController(), permanent: true);
  Get.put(AchievementsController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(MapController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: 'FlySpotter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
      home: SplashScreen(),
    ));
  }
}


