import 'package:flutter/material.dart';

class LowLightWarning extends StatelessWidget {
  final VoidCallback? onTryAgain;

  const LowLightWarning({
    super.key,
    this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber.shade800,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Low Light Detected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'The image appears to be taken in low light conditions. For better identification accuracy, try:',
            style: TextStyle(
              color: Colors.amber.shade900,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTip('Taking the photo in a well-lit environment'),
                _buildTip('Using additional lighting sources'),
                _buildTip('Enabling flash on your camera'),
              ],
            ),
          ),
          if (onTryAgain != null) ...[
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTryAgain,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber.shade800,
                ),
              ),
            ),
          ],
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
          Text('• ', style: TextStyle(color: Colors.amber.shade800)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

