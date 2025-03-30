import 'package:flutter/material.dart';

class CameraQualityOverlay extends StatelessWidget {
  final bool isLowLight;
  final VoidCallback onTakePicture;

  const CameraQualityOverlay({
    super.key,
    required this.isLowLight,
    required this.onTakePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: isLowLight ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.amber,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Low light detected. For better results, move to a brighter area.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

