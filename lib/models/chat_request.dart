class ChatRequest {
  final String message;
  final String? context;
  final String? sessionId;
  final String? locale;

  ChatRequest({
    required this.message,
    this.context,
    this.sessionId,
    this.locale,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (context != null) 'context': context,
      if (sessionId != null) 'session_id': sessionId,
      if (locale != null) 'locale': locale,
    };
  }
}