import 'package:flutter/material.dart';
import 'package:lms_project/features/usage/gemini_provider.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:typewritertext/typewritertext.dart';

class AiAssistantView extends StatefulWidget {
  const AiAssistantView({
    super.key,
    required this.title,
    required this.bottomNavigation,
    required this.welcomeMessage,
    this.hintText = 'Ask me anything...',
    this.connectingLabel = 'Connecting to tutor...',
    this.typingLabel = 'Assistant is typing...',
  });

  final String title;
  final Widget bottomNavigation;
  final String welcomeMessage;
  final String hintText;
  final String connectingLabel;
  final String typingLabel;

  @override
  State<AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<AiAssistantView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: widget.welcomeMessage,
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
    final gemini = context.read<GeminiProvider>();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    String aiResponse = '';
    final int aiMessageIndex = _messages.length;
    setState(() {
      _messages.add(
        _ChatMessage(
          text: '',
          isUser: false,
          isLoading: true,
          isStreaming: true,
        ),
      );
    });

    try {
      await for (final chunk in gemini.stream(text)) {
        aiResponse += chunk;
        setState(() {
          _messages[aiMessageIndex] = _ChatMessage(
            text: aiResponse,
            isUser: false,
            isLoading: false,
            isStreaming: true,
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages[aiMessageIndex] = _ChatMessage(
          text: 'Sorry, I encountered an error: ${e.toString()}',
          isUser: false,
          isLoading: false,
          isStreaming: false,
        );
      });
    } finally {
      setState(() {
        if (aiResponse.isNotEmpty && aiMessageIndex < _messages.length) {
          _messages[aiMessageIndex] = _ChatMessage(
            text: aiResponse,
            isUser: false,
            isLoading: false,
            isStreaming: false,
          );
        }
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
        title: Text(widget.title, style: AppTextStyles.h1Teal),
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
                  typingLabel: widget.typingLabel,
                  connectingLabel: widget.connectingLabel,
                );
              },
            ),
          ),
          _ChatComposer(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: _isLoading,
            hintText: _isLoading ? 'AI is responding...' : widget.hintText,
          ),
        ],
      ),
      bottomNavigationBar: widget.bottomNavigation,
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isStreaming;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.isStreaming = false,
  });
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({
    required this.message,
    required this.typingLabel,
    required this.connectingLabel,
  });

  final _ChatMessage message;
  final String typingLabel;
  final String connectingLabel;

  @override
  Widget build(BuildContext context) {
    final bg = message.isUser ? Colors.purple[300] : Colors.white;
    final color = message.isUser ? Colors.white : Colors.black87;
    final align =
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

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
          child: message.isUser
              ? Text(
                  message.text,
                  style: AppTextStyles.body.copyWith(color: color),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isLoading && message.text.isEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.teal[400]!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            connectingLabel,
                            style: AppTextStyles.body.copyWith(color: color),
                          ),
                        ],
                      )
                    else
                      MarkdownBlock(
                        data: message.text,
                        selectable: true,
                      ),
                    if (message.isStreaming)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TypeWriter.text(
                          typingLabel,
                          duration: const Duration(milliseconds: 35),
                          repeat: true,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: Colors.teal[300],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ChatComposer extends StatefulWidget {
  const _ChatComposer({
    required this.controller,
    required this.onSend,
    required this.isLoading,
    required this.hintText,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final String hintText;

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
                hintText: widget.hintText,
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
