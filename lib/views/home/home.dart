import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/archievements_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/achievement_model.dart';
import '../achievements/achievement_screen.dart';
import '../encyclopedia/species_guide.dart';
import '../identification/identification_screen.dart';
import '../map/map.dart';
import '../profile/profile_screen.dart';
import '../../widgets/custom_card.dart';
import '../settings/settings_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final AchievementsController achievementsController = Get.find<AchievementsController>();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    IdentificationScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Identify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final AchievementsController achievementsController = Get.find<AchievementsController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildWelcomeCard(context),
              SizedBox(height: 24),
              _buildFeatureGrid(context),
              SizedBox(height: 24),
              _buildRecentIdentificationsSection(context),
              SizedBox(height: 24),
              _buildAchievementsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text(
          'Hello, ${authController.userModel.value?.name ?? 'User'}!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )),
        Obx(() => GestureDetector(
          onTap: () => Get.to(() => ProfileScreen()),
          child: authController.userModel.value?.photoUrl != null
              ? CircleAvatar(
            backgroundImage: NetworkImage(authController.userModel.value!.photoUrl!),
            radius: 24,
          )
              : CircleAvatar(
            child: Icon(Icons.person),
            radius: 24,
          ),
        )),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(20),
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'FlySpotter',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Identify fly species using our advanced AI technology',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.to(() => IdentificationScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Start Identifying'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.map,
          title: 'Map View',
          description: 'See where flies were identified',
          onTap: () => Get.to(() => MapScreen()),
        ),
        _buildFeatureCard(
          context,
          icon: Icons.book,
          title: 'Species Guide',
          description: 'Learn different fly species',
          onTap: () => Get.to(() => SpeciesGuideScreen()),
        ),
        _buildFeatureCard(
          context,
          icon: Icons.emoji_events,
          title: 'Achievements',
          description: 'Track your progress',
          onTap: () => Get.to(() => AchievementsScreen()),
        ),
        _buildFeatureCard(
          context,
          icon: Icons.offline_bolt,
          title: 'Offline Mode',
          description: 'Use the app without internet',
          onTap: () {
            Get.snackbar(
              'Offline Mode',
              'Your identifications will be saved locally and synced when you\'re back online',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
      }) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentIdentificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Identifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all identifications
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Obx(() {
          if (authController.userModel.value?.identificationHistory.isEmpty ?? true) {
            return CustomCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No identifications yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start by identifying a fly!',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Get.to(() => IdentificationScreen()),
                      child: Text('Identify Now'),
                    ),
                  ],
                ),
              ),
            );
          }

          // This would normally show the history items
          // For now, just a placeholder with improved UI
          return Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(right: 12),
                  child: CustomCard(
                    padding: EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.bug_report,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'House Fly',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Confidence: 95%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => AchievementsScreen()),
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Obx(() {
          if (achievementsController.achievements.isEmpty) {
            return CustomCard(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No achievements yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start identifying flies to earn achievements!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show a few achievements
          List<AchievementModel> displayAchievements = achievementsController.achievements
              .take(3)
              .toList();

          return Column(
            children: displayAchievements.map((achievement) {
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: achievement.isUnlocked
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: achievement.isUnlocked ? null : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              achievement.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: achievement.isUnlocked ? Colors.grey[600] : Colors.grey,
                              ),
                            ),
                            if (!achievement.isUnlocked && achievement.progressPercentage > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: LinearProgressIndicator(
                                  value: achievement.progressPercentage,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (achievement.isUnlocked)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

