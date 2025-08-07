class ChatResponse {
  final bool success;
  final String message;
  final ChatData? data;

  ChatResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ChatData.fromJson(json['data']) : null,
    );
  }
}

class ChatData {
  final String message;
  final String userId;
  final String? sessionId;
  final DateTime? timestamp;

  ChatData({
    required this.message,
    required this.userId,
    this.sessionId,
    this.timestamp,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      message: json['message'] ?? '',
      userId: json['userId'] ?? '',
      sessionId: json['session_id'],
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp']) 
          : null,
    );
  }
}