import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/archievements_controller.dart';
import '../../widgets/achievement_badge.dart';
import 'package:flutter/services.dart';

class AchievementsScreen extends StatefulWidget {

  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementsController achievementsController = Get.find<AchievementsController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Obx(() {
        if (achievementsController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildProgressHeader(context),
            Expanded(
              child: achievementsController.achievements.isEmpty
                  ? _buildEmptyState()
                  : _buildAchievementsList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressCircle(context),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${achievementsController.unlockedCount} / ${achievementsController.totalCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Achievements Unlocked',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: achievementsController.overallProgress,
                strokeWidth: 8,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          Center(
            child: Text(
              '${(achievementsController.overallProgress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: achievementsController.achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievementsController.achievements[index];
        IconData iconData;

        // Convert string icon name to IconData
        switch (achievement.iconName) {
          case 'bug_report':
            iconData = Icons.bug_report;
            break;
          case 'search':
            iconData = Icons.search;
            break;
          case 'verified':
            iconData = Icons.verified;
            break;
          case 'category':
            iconData = Icons.category;
            break;
          case 'calendar_today':
            iconData = Icons.calendar_today;
            break;
          default:
            iconData = Icons.emoji_events;
        }

        return AchievementBadge(
          title: achievement.title,
          description: achievement.description,
          icon: iconData,
          isUnlocked: achievement.isUnlocked,
          progress: achievement.progressPercentage,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No achievements yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start identifying flies to earn achievements!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => achievementsController.loadAchievements(),
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

