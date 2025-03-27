import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final double progress;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: () {
            // Show achievement details
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 60,
                      color: isUnlocked ? theme.primaryColor : Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(description),
                    SizedBox(height: 16),
                    if (!isUnlocked && progress > 0)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          ),
                          SizedBox(height: 8),
                          Text('${(progress * 100).toInt()}% completed'),
                        ],
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? theme.primaryColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isUnlocked ? theme.primaryColor : Colors.grey,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                      if (!isUnlocked && progress > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isUnlocked)
                  Icon(
                    Icons.check_circle,
                    color: theme.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

