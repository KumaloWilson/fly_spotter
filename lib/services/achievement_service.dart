import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/achievement_model.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Collection references
  CollectionReference get _achievementsCollection => _firestore.collection('achievements');
  CollectionReference get _userAchievementsCollection => _firestore.collection('user_achievements');

  // Get all achievements
  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      QuerySnapshot snapshot = await _achievementsCollection.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return AchievementModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw 'Failed to get achievements: $e';
    }
  }

  // Get user achievements
  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      // Get all achievements
      List<AchievementModel> allAchievements = await getAllAchievements();

      // Get user's achievement progress
      DocumentSnapshot userAchievementsDoc = await _userAchievementsCollection.doc(userId).get();

      if (!userAchievementsDoc.exists) {
        // Initialize user achievements if they don't exist
        await _initializeUserAchievements(userId, allAchievements);
        return allAchievements;
      }

      Map<String, dynamic> userAchievementsData = userAchievementsDoc.data() as Map<String, dynamic>;

      // Update achievements with user progress
      return allAchievements.map((achievement) {
        if (userAchievementsData.containsKey(achievement.id)) {
          Map<String, dynamic> userProgress = userAchievementsData[achievement.id];
          return achievement.copyWith(
            isUnlocked: userProgress['isUnlocked'] ?? false,
            currentProgress: userProgress['currentProgress'] ?? 0,
          );
        }
        return achievement;
      }).toList();
    } catch (e) {
      throw 'Failed to get user achievements: $e';
    }
  }

  // Initialize user achievements
  Future<void> _initializeUserAchievements(String userId, List<AchievementModel> achievements) async {
    try {
      Map<String, dynamic> initialData = {};

      for (var achievement in achievements) {
        initialData[achievement.id] = {
          'isUnlocked': false,
          'currentProgress': 0,
        };
      }

      await _userAchievementsCollection.doc(userId).set(initialData);
    } catch (e) {
      throw 'Failed to initialize user achievements: $e';
    }
  }

  // Update achievement progress
  Future<void> updateAchievementProgress(String userId, String achievementId, int progress) async {
    try {
      DocumentSnapshot userAchievementsDoc = await _userAchievementsCollection.doc(userId).get();

      if (!userAchievementsDoc.exists) {
        List<AchievementModel> allAchievements = await getAllAchievements();
        await _initializeUserAchievements(userId, allAchievements);
      }

      // Get the achievement details
      DocumentSnapshot achievementDoc = await _achievementsCollection.doc(achievementId).get();
      if (!achievementDoc.exists) throw 'Achievement not found';

      Map<String, dynamic> achievementData = achievementDoc.data() as Map<String, dynamic>;
      int requiredCount = achievementData['requiredCount'] ?? 0;

      // Update user's achievement progress
      await _userAchievementsCollection.doc(userId).update({
        '$achievementId.currentProgress': progress,
        '$achievementId.isUnlocked': progress >= requiredCount,
      });
    } catch (e) {
      throw 'Failed to update achievement progress: $e';
    }
  }

  // Check and update achievements based on user activity
  Future<List<AchievementModel>> checkAndUpdateAchievements(
      String userId,
      String activityType,
      {int count = 1}
      ) async {
    try {
      List<AchievementModel> unlockedAchievements = [];
      List<AchievementModel> userAchievements = await getUserAchievements(userId);

      // Filter achievements by activity type
      List<AchievementModel> relevantAchievements = userAchievements
          .where((a) => a.type == activityType && !a.isUnlocked)
          .toList();

      for (var achievement in relevantAchievements) {
        int newProgress = achievement.currentProgress + count;
        await updateAchievementProgress(userId, achievement.id, newProgress);

        // Check if achievement was unlocked
        if (newProgress >= achievement.requiredCount) {
          unlockedAchievements.add(achievement.copyWith(
            isUnlocked: true,
            currentProgress: newProgress,
          ));
        }
      }

      return unlockedAchievements;
    } catch (e) {
      throw 'Failed to check achievements: $e';
    }
  }

  // Create default achievements (for admin use)
  Future<void> createDefaultAchievements() async {
    try {
      List<AchievementModel> defaultAchievements = [
        AchievementModel(
          id: _uuid.v4(),
          title: 'Beginner Entomologist',
          description: 'Identify your first fly',
          iconName: 'bug_report',
          requiredCount: 1,
          type: 'identification',
        ),
        AchievementModel(
          id: _uuid.v4(),
          title: 'Fly Hunter',
          description: 'Identify 10 flies',
          iconName: 'search',
          requiredCount: 10,
          type: 'identification',
        ),
        AchievementModel(
          id: _uuid.v4(),
          title: 'Expert Entomologist',
          description: 'Identify 50 flies',
          iconName: 'verified',
          requiredCount: 50,
          type: 'identification',
        ),
        AchievementModel(
          id: _uuid.v4(),
          title: 'Species Collector',
          description: 'Identify 5 different species of flies',
          iconName: 'category',
          requiredCount: 5,
          type: 'species',
        ),
        AchievementModel(
          id: _uuid.v4(),
          title: 'Dedicated User',
          description: 'Use the app for 7 consecutive days',
          iconName: 'calendar_today',
          requiredCount: 7,
          type: 'login',
        ),
      ];

      // Add achievements to Firestore
      for (var achievement in defaultAchievements) {
        await _achievementsCollection.doc(achievement.id).set(achievement.toJson());
      }
    } catch (e) {
      throw 'Failed to create default achievements: $e';
    }
  }
}

