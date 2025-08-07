import 'package:flutter/material.dart';
import '../../services/stone_api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDisposed = false;
  
  late final StoneApiService _apiService;
  String? _sessionId;

  AIChatViewModel() {
    final userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('Initializing AIChatViewModel with userId: $userId');
    final currentLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _apiService = StoneApiService(userId: userId, locale: currentLocale);
    // No initial message - will show welcome screen instead
  }

  Future<void> sendMessage(String text) async {
    if (_isDisposed || text.trim().isEmpty) return;

    // Add user message
    _messages.add(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    _isLoading = true;
    _safeNotifyListeners();

    try {
      debugPrint('Sending message: "$text"');
      debugPrint('Session ID: $_sessionId');
      
      // Send message to API - Try without context to get broader responses
      final chatResponse = await _apiService.sendChatMessage(
        message: text,
        context: null,
        sessionId: _sessionId,
      );

      if (_isDisposed) return;

      debugPrint('=== CHAT RESPONSE PROCESSING ===');
      debugPrint('Success: ${chatResponse.success}');
      debugPrint('Message: ${chatResponse.message}');
      debugPrint('Data: ${chatResponse.data}');
      
      if (chatResponse.success && chatResponse.data != null) {
        // Update session ID if provided
        if (chatResponse.data!.sessionId != null) {
          _sessionId = chatResponse.data!.sessionId;
        }

        _messages.add(
          ChatMessage(
            text: chatResponse.data!.message,
            isUser: false,
            timestamp: chatResponse.data!.timestamp ?? DateTime.now(),
          ),
        );
      } else {
        // Handle API error response
        _messages.add(
          ChatMessage(
            text: chatResponse.message.isNotEmpty 
                ? chatResponse.message 
                : 'Üzgünüm, şu anda bir sorun yaşıyorum. Lütfen daha sonra tekrar deneyin.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }

    } catch (e) {
      debugPrint('AI Chat error: $e');
      _messages.add(
        ChatMessage(
          text: 'Üzgünüm, şu anda bir teknik sorun yaşıyorum. Lütfen daha sonra tekrar deneyin.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }


  void clearMessages() {
    _messages.clear();
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _apiService.dispose();
    super.dispose();
  }
}