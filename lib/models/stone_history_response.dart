class StoneHistoryResponse {
  final bool success;
  final String message;
  final StoneHistoryData? data;

  StoneHistoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StoneHistoryResponse.fromJson(Map<String, dynamic> json) {
    return StoneHistoryResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? StoneHistoryData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class StoneHistoryData {
  final List<StoneSubmissionSummary> submissions;

  StoneHistoryData({
    required this.submissions,
  });

  factory StoneHistoryData.fromJson(Map<String, dynamic> json) {
    return StoneHistoryData(
      submissions: (json['submissions'] as List)
          .map((e) => StoneSubmissionSummary.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submissions': submissions.map((e) => e.toJson()).toList(),
    };
  }
}

class StoneSubmissionSummary {
  final int id;
  final String stoneName;
  final String status;
  final String scanType;
  final String locale;
  final String createdAt;
  final int processingTimeMs;
  final String imageUrl;
  final double confidence;
  final String elementChakra;
  final String zodiacCompatibility;

  StoneSubmissionSummary({
    required this.id,
    required this.stoneName,
    required this.status,
    required this.scanType,
    required this.locale,
    required this.createdAt,
    required this.processingTimeMs,
    required this.imageUrl,
    required this.confidence,
    required this.elementChakra,
    required this.zodiacCompatibility,
  });

  factory StoneSubmissionSummary.fromJson(Map<String, dynamic> json) {
    return StoneSubmissionSummary(
      id: json['id'] as int,
      stoneName: json['stone_name'] as String,
      status: json['status'] as String,
      scanType: json['scan_type'] as String,
      locale: json['locale'] as String,
      createdAt: json['created_at'] as String,
      processingTimeMs: json['processing_time_ms'] as int,
      imageUrl: json['image_url'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      elementChakra: json['element_chakra'] as String,
      zodiacCompatibility: json['zodiac_compatibility'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stone_name': stoneName,
      'status': status,
      'scan_type': scanType,
      'locale': locale,
      'created_at': createdAt,
      'processing_time_ms': processingTimeMs,
      'image_url': imageUrl,
      'confidence': confidence,
      'element_chakra': elementChakra,
      'zodiac_compatibility': zodiacCompatibility,
    };
  }
}