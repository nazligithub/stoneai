class UserStatsResponse {
  final bool success;
  final String message;
  final UserStatsData? data;

  UserStatsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserStatsResponse.fromJson(Map<String, dynamic> json) {
    return UserStatsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? UserStatsData.fromJson(json['data']) : null,
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

class UserStatsData {
  final int totalScans;
  final int successfulScans;
  final int failedScans;
  final int avgProcessingTimeMs;
  final int uniqueStonesFound;
  final List<TopStone> topStones;

  UserStatsData({
    required this.totalScans,
    required this.successfulScans,
    required this.failedScans,
    required this.avgProcessingTimeMs,
    required this.uniqueStonesFound,
    required this.topStones,
  });

  factory UserStatsData.fromJson(Map<String, dynamic> json) {
    return UserStatsData(
      totalScans: json['total_scans'] as int,
      successfulScans: json['successful_scans'] as int,
      failedScans: json['failed_scans'] as int,
      avgProcessingTimeMs: json['avg_processing_time_ms'] as int,
      uniqueStonesFound: json['unique_stones_found'] as int,
      topStones: (json['top_stones'] as List)
          .map((e) => TopStone.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_scans': totalScans,
      'successful_scans': successfulScans,
      'failed_scans': failedScans,
      'avg_processing_time_ms': avgProcessingTimeMs,
      'unique_stones_found': uniqueStonesFound,
      'top_stones': topStones.map((e) => e.toJson()).toList(),
    };
  }
}

class TopStone {
  final String stoneName;
  final int scanCount;
  final double avgConfidence;

  TopStone({
    required this.stoneName,
    required this.scanCount,
    required this.avgConfidence,
  });

  factory TopStone.fromJson(Map<String, dynamic> json) {
    return TopStone(
      stoneName: json['stone_name'] as String,
      scanCount: json['scan_count'] as int,
      avgConfidence: (json['avg_confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stone_name': stoneName,
      'scan_count': scanCount,
      'avg_confidence': avgConfidence,
    };
  }
}