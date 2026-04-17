// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/chatbot/ai_service/gemini_service.dart';
import 'package:shivay_construction/features/chatbot/repo/chatbot_repo.dart';
import 'package:shivay_construction/features/chatbot/screens/screenshot_viewer_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? screenshots;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.screenshots,
    this.isTyping = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = true;
  final bool _useGemini = false;
  late AnimationController _overlayController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  IconData _overlayIcon = Icons.rocket;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadChatbotData();
    _sendWelcomeMessage();
  }

  void _initializeAnimations() {
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut),
    );

    _overlayController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatbotData() async {
    await _chatbotService.loadChatbotData();
    setState(() {
      _isLoading = false;
    });
  }

  void _sendWelcomeMessage() {
    final welcomeMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "👋 Hello! I'm your app assistant.\n\nI can help you with:\n• Login & Registration\n• Masters (Party, Site, Item, Godown, Category, etc.)\n• Entries (Opening Stock, Indent, Purchase Order, GRN, Site Transfer, Repair, DLR)\n• Reports & Stock Reports\n• User Settings & Authorization\n• And much more!\n\nJust ask me anything about the app!",
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, welcomeMsg);
    });
  }

  void _triggerOverlay(IconData icon) {
    setState(() {
      _overlayIcon = icon;
      _showOverlay = true;
    });
    _overlayController.forward(from: 0.0);
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    if (_isLoading) {
      _showSnackBar("Please wait, loading Chatbot data...");
      return;
    }

    _textController.clear();
    FocusScope.of(context).unfocus();

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    _scrollToBottom();

    final typingMessage = ChatMessage(
      id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
    );

    setState(() {
      _messages.insert(0, typingMessage);
    });

    try {
      String botAnswer;
      List<String> screenshots = [];

      if (_useGemini) {
        await Future.delayed(const Duration(milliseconds: 500));
        botAnswer = await _geminiService.sendMessage(text);
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        final response = _chatbotService.getAnswer(text);

        if (response != null) {
          botAnswer = response['answer'] ?? '';
          screenshots = List<String>.from(response['screenshots'] ?? []);
        } else {
          botAnswer =
              "🤔 I couldn't find an answer in my Chatbot database.\n\nTry rephrasing your question or use more specific keywords.\n\nYou can also switch to AI mode using the toggle above for general queries.";
        }
      }

      setState(() {
        _messages.removeWhere((m) => m.id == typingMessage.id);
        _messages.insert(
          0,
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: botAnswer,
            isUser: false,
            timestamp: DateTime.now(),
            screenshots: screenshots.isNotEmpty ? screenshots : null,
          ),
        );
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.id == typingMessage.id);
        _messages.insert(
          0,
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: "⚠️ Sorry, I encountered an error: ${e.toString()}",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyles.kRegularOutfit(
            fontSize: FontSizes.k14FontSize,
            color: kColorWhite,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kColorPrimary,
      ),
    );
  }

  void _showQuickSuggestions() {
    final bool tablet = AppScreenUtils.isTablet(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tablet ? 24 : 20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: tablet
                  ? AppPaddings.combined(vertical: 12, horizontal: 0)
                  : AppPaddings.combined(vertical: 10, horizontal: 0),
              width: tablet ? 50 : 40,
              height: tablet ? 5 : 4,
              decoration: BoxDecoration(
                color: kColorGrey,
                borderRadius: BorderRadius.circular(tablet ? 3 : 2),
              ),
            ),
            Padding(
              padding: tablet ? AppPaddings.p20 : AppPaddings.p16,
              child: Text(
                'Quick Suggestions',
                style: TextStyles.kBoldOutfit(
                  color: kColorTextPrimary,
                  fontSize: tablet
                      ? FontSizes.k20FontSize
                      : FontSizes.k18FontSize,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 20, vertical: 8)
                    : AppPaddings.combined(horizontal: 16, vertical: 8),
                children: [
                  _buildSuggestionChip('How do I login to the app?'),
                  _buildSuggestionChip('How to add opening stock?'),
                  _buildSuggestionChip('How to add indent?'),
                  _buildSuggestionChip('How to create purchase order?'),
                  _buildSuggestionChip('How to add GRN?'),
                  _buildSuggestionChip('How to create direct GRN?'),
                  _buildSuggestionChip('How to view stock reports?'),
                  _buildSuggestionChip('How to manage user authorization?'),
                  tablet ? AppSpaces.v24 : AppSpaces.v20,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Padding(
      padding: tablet
          ? AppPaddings.custom(bottom: 10)
          : AppPaddings.custom(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _handleSubmitted(text);
        },
        borderRadius: BorderRadius.circular(tablet ? 14 : 12),
        child: Container(
          padding: tablet
              ? AppPaddings.combined(horizontal: 16, vertical: 14)
              : AppPaddings.p12,
          decoration: BoxDecoration(
            color: kColorLightGrey,
            borderRadius: BorderRadius.circular(tablet ? 14 : 12),
            border: Border.all(color: kColorGrey),
          ),
          child: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: kColorPrimary,
                size: tablet ? 22 : 20,
              ),
              tablet ? AppSpaces.h12 : AppSpaces.h10,
              Expanded(
                child: Text(
                  text,
                  style: TextStyles.kRegularOutfit(
                    color: kColorTextPrimary,
                    fontSize: tablet
                        ? FontSizes.k15FontSize
                        : FontSizes.k14FontSize,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: kColorDarkGrey,
                size: tablet ? 16 : 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: kColorWhite,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: kColorWhite,
            iconTheme: const IconThemeData(color: kColorTextPrimary),
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back_ios,
                size: tablet ? 25 : 20,
                color: kColorPrimary,
              ),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "App Assistant",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.kBoldOutfit(
                    color: kColorTextPrimary,
                    fontSize: tablet
                        ? FontSizes.k20FontSize
                        : FontSizes.k18FontSize,
                  ),
                ),
                AppSpaces.v2,
                Text(
                  _useGemini ? "AI Mode" : "Chatbot Mode",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.kRegularOutfit(
                    color: kColorDarkGrey,
                    fontSize: tablet
                        ? FontSizes.k14FontSize
                        : FontSizes.k12FontSize,
                  ),
                ),
              ],
            ),
            actions: [
              // Switch(
              //   value: _useGemini,
              //   onChanged: (value) {
              //     setState(() {
              //       _useGemini = value;
              //       _triggerOverlay(
              //         _useGemini ? Icons.auto_awesome : Icons.support_agent,
              //       );
              //     });
              //   },
              //   activeColor: kColorPrimary,
              //   inactiveThumbColor: kColorDarkGrey.withOpacity(0.5),
              //   trackColor: WidgetStateProperty.resolveWith((states) {
              //     if (states.contains(WidgetState.selected)) {
              //       return kColorPrimary.withOpacity(0.5);
              //     }
              //     return Colors.grey.shade300;
              //   }),
              // ),
              IconButton(
                icon: Icon(
                  Icons.lightbulb_outline,
                  color: kColorSecondary,
                  size: tablet ? 26 : 24,
                ),
                onPressed: _showQuickSuggestions,
                tooltip: 'Quick Suggestions',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: kColorRed,
                  size: tablet ? 26 : 24,
                ),
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _sendWelcomeMessage();
                    _triggerOverlay(Icons.delete_forever);
                  });
                },
                tooltip: 'Clear Chat',
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: kColorPrimary),
                      tablet ? AppSpaces.v20 : AppSpaces.v16,
                      Text(
                        'Loading Chatbot data...',
                        style: TextStyles.kRegularOutfit(
                          color: kColorDarkGrey,
                          fontSize: tablet
                              ? FontSizes.k16FontSize
                              : FontSizes.k14FontSize,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: Text(
                                'No messages yet',
                                style: TextStyles.kRegularOutfit(
                                  color: kColorDarkGrey,
                                  fontSize: tablet
                                      ? FontSizes.k18FontSize
                                      : FontSizes.k16FontSize,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: tablet
                                  ? AppPaddings.combined(
                                      horizontal: 16,
                                      vertical: 12,
                                    )
                                  : AppPaddings.combined(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                if (message.isTyping) {
                                  return _buildTypingIndicator(tablet);
                                }
                                return _buildMessageBubble(message, tablet);
                              },
                            ),
                    ),
                    _buildInputArea(tablet),
                  ],
                ),
        ),
        if (_showOverlay)
          Positioned.fill(
            child: Center(
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    _overlayIcon,
                    size: tablet ? 100 : 80,
                    color: kColorPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool tablet) {
    final isUser = message.isUser;
    final hasScreenshots =
        message.screenshots != null && message.screenshots!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: tablet ? 10 : 8,
        left: isUser ? (tablet ? 60 : 50) : 0,
        right: isUser ? 0 : (tablet ? 60 : 50),
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              margin: EdgeInsets.only(right: tablet ? 10 : 8),
              child: CircleAvatar(
                backgroundColor: kColorPrimary.withOpacity(0.1),
                radius: tablet ? 18 : 16,
                child: Icon(
                  Icons.support_agent,
                  color: kColorPrimary,
                  size: tablet ? 20 : 18,
                ),
              ),
            ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isUser ? kColorPrimary : const Color(0xFFE1E8ED),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(tablet ? 16 : 14),
                  topRight: Radius.circular(tablet ? 16 : 14),
                  bottomLeft: Radius.circular(
                    isUser ? (tablet ? 16 : 14) : (tablet ? 4 : 2),
                  ),
                  bottomRight: Radius.circular(
                    isUser ? (tablet ? 4 : 2) : (tablet ? 16 : 14),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kColorBlack.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: tablet ? 14 : 12,
                vertical: tablet ? 12 : 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: TextStyles.kRegularOutfit(
                      color: isUser ? kColorWhite : kColorTextPrimary,
                      fontSize: tablet
                          ? FontSizes.k16FontSize
                          : FontSizes.k15FontSize,
                    ).copyWith(height: 1.4),
                  ),
                  if (hasScreenshots) ...[
                    SizedBox(height: tablet ? 10 : 8),
                    SizedBox(
                      width: double.infinity,
                      height: tablet ? 36 : 32,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(
                            () => ScreenshotViewerScreen(
                              screenshots: message.screenshots!,
                            ),
                          );
                        },
                        icon: Icon(Icons.photo_library, size: tablet ? 16 : 14),
                        label: Text(
                          'View Screenshots',
                          style: TextStyles.kRegularOutfit(
                            fontSize: tablet
                                ? FontSizes.k14FontSize
                                : FontSizes.k12FontSize,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kColorWhite,
                          foregroundColor: kColorPrimary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              tablet ? 10 : 8,
                            ),
                            side: BorderSide(
                              color: kColorPrimary.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: EdgeInsets.only(left: tablet ? 10 : 8),
              child: CircleAvatar(
                backgroundColor: kColorPrimary,
                radius: tablet ? 18 : 16,
                child: Icon(
                  Icons.person,
                  color: kColorWhite,
                  size: tablet ? 20 : 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool tablet) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: tablet ? 10 : 8,
        right: tablet ? 60 : 50,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(right: tablet ? 10 : 8),
            child: CircleAvatar(
              backgroundColor: kColorPrimary.withOpacity(0.1),
              radius: tablet ? 18 : 16,
              child: Icon(
                Icons.support_agent,
                color: kColorPrimary,
                size: tablet ? 20 : 18,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tablet ? 18 : 16,
              vertical: tablet ? 14 : 12,
            ),
            constraints: BoxConstraints(maxWidth: tablet ? 280 : 250),
            decoration: BoxDecoration(
              color: kColorLightGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(tablet ? 16 : 14),
                topRight: Radius.circular(tablet ? 16 : 14),
                bottomLeft: Radius.circular(tablet ? 4 : 2),
                bottomRight: Radius.circular(tablet ? 16 : 14),
              ),
              boxShadow: [
                BoxShadow(
                  color: kColorBlack.withOpacity(0.05),
                  blurRadius: tablet ? 6 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0, tablet),
                SizedBox(width: tablet ? 8 : 6),
                _buildTypingDot(1, tablet),
                SizedBox(width: tablet ? 8 : 6),
                _buildTypingDot(2, tablet),
                SizedBox(width: tablet ? 14 : 12),
                Flexible(
                  child: Text(
                    _useGemini ? 'AI is thinking...' : 'Typing...',
                    style: TextStyles.kRegularOutfit(
                      color: kColorDarkGrey.withOpacity(0.8),
                      fontSize: tablet
                          ? FontSizes.k15FontSize
                          : FontSizes.k14FontSize,
                    ).copyWith(fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, bool tablet) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        final offset = (value + index / 3) % 1.0;
        final scale = 0.6 + (0.4 * (1 - (offset - 0.5).abs() * 2));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: tablet ? 12 : 10,
            height: tablet ? 12 : 10,
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.4 + offset * 0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kColorPrimary.withOpacity(0.3),
                  blurRadius: tablet ? 5 : 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(bool tablet) {
    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        boxShadow: [
          BoxShadow(
            color: kColorBlack.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: tablet
          ? AppPaddings.combined(horizontal: 16, vertical: 12)
          : AppPaddings.combined(horizontal: 12, vertical: 10),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(tablet ? 26 : 24),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: tablet ? 18 : 16,
                  vertical: tablet ? 4 : 2,
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about the app...',
                    hintStyle: TextStyles.kRegularOutfit(
                      color: kColorDarkGrey,
                      fontSize: tablet
                          ? FontSizes.k16FontSize
                          : FontSizes.k15FontSize,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: tablet ? 12 : 10,
                    ),
                  ),
                  style: TextStyles.kRegularOutfit(
                    color: kColorTextPrimary,
                    fontSize: tablet
                        ? FontSizes.k16FontSize
                        : FontSizes.k15FontSize,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleSubmitted,
                ),
              ),
            ),
            SizedBox(width: tablet ? 12 : 10),
            Container(
              decoration: BoxDecoration(
                color: kColorPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kColorPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _handleSubmitted(_textController.text),
                icon: Icon(
                  Icons.send_rounded,
                  color: kColorWhite,
                  size: tablet ? 24 : 22,
                ),
                padding: EdgeInsets.all(tablet ? 12 : 10),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
