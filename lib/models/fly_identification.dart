class FlySpecies {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String? imageUrl;
  final Map<String, String> characteristics;

  FlySpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    this.imageUrl,
    this.characteristics = const {},
  });

  factory FlySpecies.fromJson(Map<String, dynamic> json) {
    return FlySpecies(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      characteristics: Map<String, String>.from(json['characteristics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'imageUrl': imageUrl,
      'characteristics': characteristics,
    };
  }
}

class IdentificationResult {
  final String id;
  final DateTime timestamp;
  final FlySpecies species;
  final double confidenceScore;
  final String imageUrl;
  final String userId;
  final Map<String, dynamic> additionalData;

  IdentificationResult({
    required this.id,
    required this.timestamp,
    required this.species,
    required this.confidenceScore,
    required this.imageUrl,
    required this.userId,
    this.additionalData = const {},
  });

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      id: json['id'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      species: FlySpecies.fromJson(json['species'] ?? {}),
      confidenceScore: json['confidenceScore'] ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? '',
      additionalData: json['additionalData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'species': species.toJson(),
      'confidenceScore': confidenceScore,
      'imageUrl': imageUrl,
      'userId': userId,
      'additionalData': additionalData,
    };
  }
}

