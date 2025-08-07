import 'stone_model.dart';

class IdentificationResult {
  final String id;
  final List<StoneMatch> matches;
  final String analysisType;
  final DateTime timestamp;
  final double confidenceScore;
  final String? notes;
  final Map<String, dynamic>? analysisData;

  IdentificationResult({
    required this.id,
    required this.matches,
    required this.analysisType,
    required this.timestamp,
    required this.confidenceScore,
    this.notes,
    this.analysisData,
  });

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      id: json['id'] as String,
      matches: (json['matches'] as List<dynamic>)
          .map((match) => StoneMatch.fromJson(match))
          .toList(),
      analysisType: json['analysis_type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      notes: json['notes'] as String?,
      analysisData: json['analysis_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matches': matches.map((match) => match.toJson()).toList(),
      'analysis_type': analysisType,
      'timestamp': timestamp.toIso8601String(),
      'confidence_score': confidenceScore,
      'notes': notes,
      'analysis_data': analysisData,
    };
  }

  StoneMatch? get topMatch => matches.isNotEmpty ? matches.first : null;
  
  bool get hasHighConfidence => confidenceScore >= 0.8;
  
  List<StoneMatch> get highConfidenceMatches => 
      matches.where((match) => match.confidence >= 0.7).toList();
}

class StoneMatch {
  final StoneModel stone;
  final double confidence;
  final List<String> matchingFeatures;
  final String? reasoning;

  StoneMatch({
    required this.stone,
    required this.confidence,
    required this.matchingFeatures,
    this.reasoning,
  });

  factory StoneMatch.fromJson(Map<String, dynamic> json) {
    return StoneMatch(
      stone: StoneModel.fromJson(json['stone']),
      confidence: (json['confidence'] as num).toDouble(),
      matchingFeatures: List<String>.from(json['matching_features']),
      reasoning: json['reasoning'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stone': stone.toJson(),
      'confidence': confidence,
      'matching_features': matchingFeatures,
      'reasoning': reasoning,
    };
  }

  String get confidencePercentage => '${(confidence * 100).toInt()}%';
  
  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;
}