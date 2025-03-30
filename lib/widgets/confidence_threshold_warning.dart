import 'package:flutter/material.dart';

class ConfidenceThresholdWarning extends StatelessWidget {
  final VoidCallback onNewImage;
  final VoidCallback onTryAgain;
  final double confidence;
  final double threshold;

  const ConfidenceThresholdWarning({
    super.key,
    required this.onNewImage,
    required this.onTryAgain,
    required this.confidence,
    this.threshold = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade800,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Low Confidence Identification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'The identification confidence is ${(confidence * 100).toStringAsFixed(1)}%, which is below our ${(threshold * 100).toInt()}% threshold. This result has not been saved.',
            style: TextStyle(
              color: Colors.orange.shade900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'For better results, try:',
            style: TextStyle(
              color: Colors.orange.shade900,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTip('Taking a clearer photo of the fly'),
                _buildTip('Capturing the fly from a different angle'),
                _buildTip('Ensuring the fly is in focus and well-lit'),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onNewImage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                ),
                child: Text('New Image'),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.orange.shade800)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

