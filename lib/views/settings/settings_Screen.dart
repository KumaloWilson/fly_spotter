import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/profile_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.dark_mode),
                  title: Text('Dark Mode'),
                  trailing: Obx(() => Switch(
                    value: themeController.isDarkMode.value,
                    onChanged: (value) => themeController.toggleTheme(),
                    activeColor: Theme.of(context).primaryColor,
                  )),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildSectionHeader('Identification'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.save_alt),
                  title: Text('Save Identifications'),
                  subtitle: Text('Automatically save all identifications'),
                  trailing: Obx(() {
                    bool saveEnabled = profileController.currentUser?.preferences['saveIdentifications'] ?? true;
                    return Switch(
                      value: saveEnabled,
                      onChanged: (value) => profileController.updatePreferences({
                        'saveIdentifications': value,
                      }),
                      activeColor: Theme.of(context).primaryColor,
                    );
                  }),
                ),
                ListTile(
                  leading: Icon(Icons.image_search),
                  title: Text('Confidence Threshold'),
                  subtitle: Text('Minimum confidence level to show results'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => _showConfidenceThresholdDialog(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildSectionHeader('About'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('App Version'),
                  trailing: Text('1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Privacy Policy'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Terms of Service'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to terms of service
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildSectionHeader('Data'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Clear Identification History',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _showClearHistoryDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showConfidenceThresholdDialog(BuildContext context) {
    double threshold = profileController.currentUser?.preferences['confidenceThreshold'] ?? 0.5;

    Get.dialog(
      AlertDialog(
        title: Text('Confidence Threshold'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set the minimum confidence level to show identification results.'),
            SizedBox(height: 20),
            Obx(() {
              threshold = profileController.currentUser?.preferences['confidenceThreshold'] ?? 0.5;
              return Column(
                children: [
                  Slider(
                    value: threshold,
                    min: 0.1,
                    max: 0.9,
                    divisions: 8,
                    label: '${(threshold * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      profileController.updatePreferences({
                        'confidenceThreshold': value,
                      });
                    },
                  ),
                  Text('${(threshold * 100).toStringAsFixed(0)}%'),
                ],
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Clear History'),
        content: Text('Are you sure you want to clear your identification history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear history logic would go here
              Get.back();
              Get.snackbar(
                'Success',
                'Identification history cleared',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

