import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:specifier/utiils/logs.dart';
import '../../controllers/identification_controller.dart';

class IdentificationScreen extends StatefulWidget {
  const IdentificationScreen({super.key});

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
                DevLogs.logError(identificationController.errorMessage.toString());

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

  Widget _buildImageSelectionUI() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Take a photo or select an image of a fly to identify',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  onTap: () => identificationController.pickImageFromCamera(),
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
          Expanded(
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
                shrinkWrap: true,
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
                        '${_formatDate(item.timestamp)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

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
            Text(
              'Identification Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            identificationController.identificationResults.isEmpty
                ? Text('No flies detected in this image')
                : _buildResultsList(),
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