import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';
import 'auth_controller.dart';

class AchievementsController extends GetxController {
  final AchievementService _achievementService = AchievementService();
  final AuthController authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AchievementModel> achievements = <AchievementModel>[].obs;
  final RxList<AchievementModel> recentlyUnlocked = <AchievementModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
  }

  // Load user achievements
  Future<void> loadAchievements() async {
    if (authController.userModel.value == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      achievements.value = await _achievementService.getUserAchievements(
        authController.userModel.value!.uid,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Check and update achievements based on activity
  Future<void> checkAchievements(String activityType, {int count = 1}) async {
    if (authController.userModel.value == null) return;

    try {
      List<AchievementModel> unlocked = await _achievementService.checkAndUpdateAchievements(
        authController.userModel.value!.uid,
        activityType,
        count: count,
      );

      if (unlocked.isNotEmpty) {
        recentlyUnlocked.value = unlocked;
        _showAchievementUnlockedDialog(unlocked);
        await loadAchievements(); // Refresh achievements list
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Show achievement unlocked dialog
  void _showAchievementUnlockedDialog(List<AchievementModel> unlocked) {
    if (unlocked.isEmpty) return;

    Get.dialog(
      AlertDialog(
        title: Text('Achievement Unlocked!'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: unlocked.length,
            itemBuilder: (context, index) {
              final achievement = unlocked[index];
              return ListTile(
                leading: Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 40,
                ),
                title: Text(achievement.title),
                subtitle: Text(achievement.description),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  // Get unlocked achievements count
  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  // Get total achievements count
  int get totalCount => achievements.length;

  // Get achievement progress percentage
  double get overallProgress {
    if (achievements.isEmpty) return 0.0;
    return unlockedCount / totalCount;
  }
}

