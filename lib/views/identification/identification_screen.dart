import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/identification_controller.dart';
import 'camera_screen.dart';
import 'identification_tips_screen.dart';

class IdentificationScreen extends StatefulWidget {
  @override
  State<IdentificationScreen> createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  final IdentificationController identificationController = Get.find<IdentificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identify Fly'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (identificationController.errorMessage.isNotEmpty) {
                return Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    identificationController.errorMessage.value,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
            Obx(() {
              if (identificationController.selectedImage.value == null) {
                return _buildImageSelectionUI();
              } else {
                return _buildIdentificationResultsUI();
              }
            }),
          ],
        ),
      ),
    );
  }

// Fix for the _buildImageSelectionUI method
  Widget _buildImageSelectionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: Icon(Icons.lightbulb_outline),
              tooltip: 'Tips for better identification',
              onPressed: () => Get.to(() => IdentificationTipsScreen()),
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                icon: Icons.camera_alt,
                title: 'Camera',
                onTap: () => Get.to(() => CameraScreen()),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: _buildOptionCard(
                icon: Icons.photo_library,
                title: 'Gallery',
                onTap: () => identificationController.pickImageFromGallery(),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Text(
          'Recent Identifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),

        Container(
          height: 300, // Set a fixed height or use MediaQuery to get a dynamic height
          child: Obx(() {
            if (identificationController.identificationHistory.isEmpty) {
              return Center(
                child: Text(
                  'No identifications yet',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: identificationController.identificationHistory.length,
              itemBuilder: (context, index) {
                final item = identificationController.identificationHistory[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(item.species.name),
                    subtitle: Text(
                      'Confidence: ${(item.confidenceScore * 100).toStringAsFixed(1)}%',
                    ),
                    trailing: Text(
                      _formatDate(item.timestamp),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // Modify the _buildIdentificationResultsUI method to handle low light and confidence threshold
  Widget _buildIdentificationResultsUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => identificationController.isLoading.value
            ? Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Analyzing image...'),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                identificationController.selectedImage.value!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Show low light warning if detected
            if (identificationController.isLowLight.value)
              _buildWarningCard(
                icon: Icons.wb_sunny,
                title: 'Low Light Detected',
                message: 'For better identification accuracy, please take a photo in a well-lit environment.',
                actionText: 'Try Again',
                onAction: () => identificationController.clearSelectedImage(),
              ),

            if (!identificationController.isLowLight.value) ...[
              Text(
                'Identification Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // No flies detected
              if (identificationController.identificationResults.isEmpty)
                _buildWarningCard(
                  icon: Icons.search_off,
                  title: 'No Flies Detected',
                  message: 'We couldn\'t identify any flies in this image. Please try with a clearer image.',
                  actionText: 'Try Again',
                  onAction: () => identificationController.clearSelectedImage(),
                ),

              // Low confidence results
              if (identificationController.identificationResults.isNotEmpty &&
                  identificationController.identificationResults[0]['confidence'] < identificationController.confidenceThreshold.value)
                _buildWarningCard(
                  icon: Icons.error_outline,
                  title: 'Low Confidence Result',
                  message: 'We\'re not very confident about this identification (${(identificationController.identificationResults[0]['confidence'] * 100).toStringAsFixed(1)}%). Try with a clearer image for better results.',
                  actionText: 'Try Again',
                  onAction: () => identificationController.clearSelectedImage(),
                  showResults: true,
                ),

              // High confidence results
              if (identificationController.identificationResults.isNotEmpty &&
                  identificationController.identificationResults[0]['confidence'] >= identificationController.confidenceThreshold.value)
                _buildResultsList(),
            ],

            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => identificationController.clearSelectedImage(),
              icon: Icon(Icons.refresh),
              label: Text('Try Another Image'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        ),
      ],
    );
  }

// Add this new widget for warning cards
  Widget _buildWarningCard({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    bool showResults = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.amber.shade800,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            // Show results if requested (for low confidence)
            if (showResults && identificationController.identificationResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Possible Match:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildResultsList(),
                  SizedBox(height: 8),
                  Divider(),
                ],
              ),

            TextButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.refresh),
              label: Text(actionText),
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: identificationController.identificationResults.length,
      itemBuilder: (context, index) {
        final result = identificationController.identificationResults[index];
        final confidence = result['confidence'] * 100;
        final label = result['label'].toString().split(' ').sublist(1).join(' ');

        return Card(
          margin: EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(confidence),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${confidence.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: confidence / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor(confidence)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) {
      return Colors.green;
    } else if (confidence >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

