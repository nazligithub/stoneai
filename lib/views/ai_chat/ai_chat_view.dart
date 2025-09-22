import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math';
import 'ai_chat_viewmodel.dart';
import '../../constants/crystal_colors.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../viewmodels/stone_app_provider.dart';
import '../paywall/paywall_view.dart';

class AIChatView extends StatelessWidget {
  const AIChatView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get initial message from route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final initialMessage = args?['initialMessage'] as String?;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ChangeNotifierProvider(
        create: (_) => AIChatViewModel(),
        child: _AIChatViewContent(initialMessage: initialMessage),
      ),
    );
  }
}

class _AIChatViewContent extends StatefulWidget {
  final String? initialMessage;

  const _AIChatViewContent({this.initialMessage});

  @override
  State<_AIChatViewContent> createState() => _AIChatViewContentState();
}

class _AIChatViewContentState extends State<_AIChatViewContent> 
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Send initial message if provided
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final chatViewModel = Provider.of<AIChatViewModel>(context, listen: false);
        chatViewModel.sendMessage(widget.initialMessage!);
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AIChatViewModel, StoneAppProvider>(
      builder: (context, chatViewModel, appProvider, child) {
        // Check if user is premium for AI chat access
        if (!appProvider.isPremiumUser) {
          // Navigate to paywall with proper animation and close this screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop(); // Close AI chat
            StoneNavigationHelper.goToPaywall();
          });

          // Show loading while navigating
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[50]!,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => StoneNavigationHelper.goBack(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: CrystalColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: CrystalColors.primaryBlue,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Image.asset(
                          'assets/chat/chat.png',
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ai_chat.title'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: CrystalColors.textPrimary,
                                ),
                              ),
                              Text(
                                'ai_chat.status'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Messages or Welcome Screen
                  Expanded(
                    child: chatViewModel.messages.isEmpty
                        ? _buildWelcomeScreen(chatViewModel)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16.w),
                            itemCount: chatViewModel.messages.length + (chatViewModel.isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == chatViewModel.messages.length && chatViewModel.isLoading) {
                                return _buildTypingIndicator();
                              }
                              final message = chatViewModel.messages[index];
                              return _buildMessageBubble(message);
                            },
                          ),
                  ),
                  
                  // Input area
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'ai_chat.input_placeholder'.tr(),
                                hintStyle: GoogleFonts.poppins(
                                  color: CrystalColors.textSecondary,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 12.h,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: chatViewModel.isLoading
                              ? null
                              : () async {
                                  final message = _messageController.text.trim();
                                  if (message.isNotEmpty) {
                                    _messageController.clear();
                                    chatViewModel.sendMessage(message);
                                    _scrollToBottom();
                                    // Scroll again after typing indicator appears
                                    await Future.delayed(Duration(milliseconds: 100));
                                    _scrollToBottom();
                                  }
                                },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: chatViewModel.isLoading
                                  ? CrystalColors.textSecondary
                                  : const Color(0xFF4A90A4),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: chatViewModel.isLoading
                                ? Center(
                                    child: SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen(AIChatViewModel chatViewModel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          
          // AI Icon
          Image.asset(
            'assets/chat/chat.png',
            width: 80,
            height: 80,
          ),
          
          SizedBox(height: 24.h),
          
          // Welcome Text
          Text(
            'ai_chat.welcome_title'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CrystalColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 12.h),
          
          Text(
            'ai_chat.welcome_message'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: CrystalColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 32.h),
          
          // Suggestion Buttons
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSuggestionButton(
                      'ai_chat.suggestions.diamond_info'.tr(),
                      () => chatViewModel.sendMessage('ai_chat.suggestion_messages.diamond_properties'.tr()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSuggestionButton(
                      'ai_chat.suggestions.what_is_amethyst'.tr(),
                      () => chatViewModel.sendMessage('ai_chat.suggestion_messages.amethyst_properties'.tr()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSuggestionButton(
                      'ai_chat.suggestions.stone_cleaning'.tr(),
                      () => chatViewModel.sendMessage('ai_chat.suggestion_messages.stone_cleaning_guide'.tr()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSuggestionButton(
                      'ai_chat.suggestions.chakra_stones'.tr(),
                      () => chatViewModel.sendMessage('ai_chat.suggestion_messages.chakra_stones_guide'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CrystalColors.primaryBlue.withValues(alpha: 0.1),
              CrystalColors.primaryBlue.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CrystalColors.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CrystalColors.primaryBlue.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: CrystalColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A90A4).withValues(alpha: 0.1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/chat/chat.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF4A90A4)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _parseMessage(message.text),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isUser ? Colors.white : CrystalColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A90A4).withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: const Color(0xFF4A90A4),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CrystalColors.primaryBlue.withValues(alpha: 0.1),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/chat/chat.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4.w),
                _buildTypingDot(1),
                SizedBox(width: 4.w),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        double delay = index * 0.3;
        double animationValue = (_typingAnimationController.value + delay) % 1.0;
        double opacity = (sin(animationValue * 2 * pi) + 1) / 2;
        opacity = 0.3 + (opacity * 0.7);
        
        return Container(
          width: 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: CrystalColors.textSecondary.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _parseMessage(String message) {
    // Clean message with better formatting preservation
    return message
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1') // Bold markdown
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1') // Italic markdown
        .replaceAll(RegExp(r'^• ', multiLine: true), '• ') // Keep bullet points
        .replaceAll(RegExp(r'^\* ', multiLine: true), '• ') // Convert asterisk to bullet
        .replaceAll(RegExp(r'^- ', multiLine: true), '• ') // Convert dash to bullet
        .replaceAll(RegExp(r'^\d+\. ', multiLine: true), '• ') // Convert numbered lists to bullets
        .replaceAll(RegExp(r'^###\s+(.+)', multiLine: true), r'$1') // H3 headers
        .replaceAll(RegExp(r'^##\s+(.+)', multiLine: true), r'$1') // H2 headers
        .replaceAll(RegExp(r'^#\s+(.+)', multiLine: true), r'$1') // H1 headers
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Limit consecutive line breaks
        .trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}