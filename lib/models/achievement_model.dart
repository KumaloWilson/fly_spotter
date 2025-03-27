class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int requiredCount;
  final String type; // 'identification', 'species', 'login', etc.
  final bool isUnlocked;
  final int currentProgress;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requiredCount,
    required this.type,
    this.isUnlocked = false,
    this.currentProgress = 0,
  });

  double get progressPercentage {
    if (isUnlocked) return 1.0;
    if (requiredCount <= 0) return 0.0;
    return currentProgress / requiredCount;
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? 'bug_report',
      requiredCount: json['requiredCount'] ?? 0,
      type: json['type'] ?? '',
      isUnlocked: json['isUnlocked'] ?? false,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'requiredCount': requiredCount,
      'type': type,
      'isUnlocked': isUnlocked,
      'currentProgress': currentProgress,
    };
  }

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? requiredCount,
    String? type,
    bool? isUnlocked,
    int? currentProgress,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      requiredCount: requiredCount ?? this.requiredCount,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}

