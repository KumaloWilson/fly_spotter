import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_card.dart';

class IdentificationTipsScreen extends StatelessWidget {
  const IdentificationTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tips for Better Identification'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            _buildTipCard(
              context,
              icon: Icons.wb_sunny,
              title: 'Good Lighting',
              description: 'Take photos in well-lit environments. Natural daylight works best for accurate identification.',
            ),
            _buildTipCard(
              context,
              icon: Icons.center_focus_strong,
              title: 'Clear Focus',
              description: 'Make sure the fly is in focus. Tap on the fly on your screen to focus before taking the photo.',
            ),
            _buildTipCard(
              context,
              icon: Icons.photo_size_select_large,
              title: 'Close-Up Shot',
              description: 'Get as close as possible to the fly without losing focus. The fly should fill a good portion of the frame.',
            ),
            _buildTipCard(
              context,
              icon: Icons.filter_none,
              title: 'Multiple Angles',
              description: 'If possible, take photos from different angles to increase chances of accurate identification.',
            ),
            _buildTipCard(
              context,
              icon: Icons.filter_hdr,
              title: 'Clean Background',
              description: 'Try to have a simple, contrasting background to make the fly stand out clearly.',
            ),
            _buildTipCard(
              context,
              icon: Icons.flash_on,
              title: 'Use Flash Carefully',
              description: 'In low light, use flash but be careful of reflections. Natural light is always preferable.',
            ),
            _buildTipCard(
              context,
              icon: Icons.stay_current_portrait,
              title: 'Hold Steady',
              description: 'Keep your phone steady to avoid blur. Use both hands or rest against a stable surface if needed.',
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(Icons.camera_alt),
                label: Text('Start Identifying'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

