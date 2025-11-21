import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/usage/gemini_service.dart';

class AIStudyAssistantPage extends StatefulWidget {
  const AIStudyAssistantPage({super.key});

  @override
  State<AIStudyAssistantPage> createState() => _AIStudyAssistantPageState();
}

class _AIStudyAssistantPageState extends State<AIStudyAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial welcome message
    _messages.add(ChatMessage(
      text: "Ask me anything! I'm an AI tutor trained to help with your studies.",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    // Add placeholder for AI response
    String aiResponse = '';
    int aiMessageIndex = _messages.length;
    _messages.add(ChatMessage(text: '', isUser: false, isLoading: true));

    try {
      // Stream the response
      await for (final chunk in _geminiService.generateStream(text)) {
        aiResponse += chunk;
        setState(() {
          _messages[aiMessageIndex] = ChatMessage(
            text: aiResponse,
            isUser: false,
            isLoading: false,
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages[aiMessageIndex] = ChatMessage(
          text: 'Sorry, I encountered an error: ${e.toString()}',
          isUser: false,
          isLoading: false,
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI Tutor', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _AssistantBubble(
                  message: _messages[index],
                );
              },
            ),
          ),
          _ChatComposer(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });
}

class _AssistantBubble extends StatelessWidget {
  final ChatMessage message;
  
  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bg = message.isUser ? Colors.purple[300] : Colors.white;
    final color = message.isUser ? Colors.white : Colors.black87;
    final align = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (!message.isUser)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: message.isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[400]!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thinking...',
                      style: AppTextStyles.body.copyWith(color: color),
                    ),
                  ],
                )
              : Text(
                  message.text,
                  style: AppTextStyles.body.copyWith(color: color),
                ),
        ),
      ],
    );
  }
}

class _ChatComposer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _ChatComposer({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<_ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<_ChatComposer> {
  bool _obscureText = false;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      color: const Color(0xFFFFF9E6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: !widget.isLoading,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: widget.isLoading ? 'AI is responding...' : 'Ask me anything...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: _toggleObscureText,
                ),
              ),
              onSubmitted: (_) => widget.onSend(),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            mini: true,
            backgroundColor: widget.isLoading ? Colors.grey : Colors.teal[400],
            onPressed: widget.isLoading ? null : widget.onSend,
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
