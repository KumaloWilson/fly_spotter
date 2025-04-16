class FlyInformation {
  final String speciesName;
  final String description;
  final String habitat;
  final String diet;
  final String lifecycle;
  final String significance;
  final String funFact;
  final DateTime timestamp;

  FlyInformation({
    required this.speciesName,
    required this.description,
    this.habitat = '',
    this.diet = '',
    this.lifecycle = '',
    this.significance = '',
    this.funFact = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory FlyInformation.fromJson(Map<String, dynamic> json) {
    return FlyInformation(
      speciesName: json['speciesName'] ?? '',
      description: json['description'] ?? '',
      habitat: json['habitat'] ?? '',
      diet: json['diet'] ?? '',
      lifecycle: json['lifecycle'] ?? '',
      significance: json['significance'] ?? '',
      funFact: json['funFact'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesName': speciesName,
      'description': description,
      'habitat': habitat,
      'diet': diet,
      'lifecycle': lifecycle,
      'significance': significance,
      'funFact': funFact,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a placeholder for when API calls fail
  factory FlyInformation.placeholder(String speciesName) {
    return FlyInformation(
      speciesName: speciesName,
      description: 'Information about this fly species is currently unavailable.',
      habitat: '',
      diet: '',
      lifecycle: '',
      significance: '',
      funFact: '',
    );
  }
}
