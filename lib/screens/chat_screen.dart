import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/message.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/api_key_banner.dart';

class ChatScreen extends StatefulWidget {
  final String Function() getApiKey;
  final VoidCallback onGoToSettings;

  const ChatScreen({super.key, required this.getApiKey, required this.onGoToSettings});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;

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
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final apiKey = widget.getApiKey();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add your OpenAI API key in Settings'), backgroundColor: AppTheme.error),
      );
      return;
    }
    setState(() {
      _messages.add(Message.user(text));
      _messages.add(Message.loading());
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final service = OpenAIService(apiKey: apiKey);
      final response = await service.sendChatMessage(_messages.where((m) => !m.isLoading).toList());
      setState(() {
        _messages.removeWhere((m) => m.isLoading);
        _messages.add(Message.assistant(response));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.removeWhere((m) => m.isLoading);
        _messages.add(Message.assistant('Error: ${e.toString().replaceFirst('Exception: ', '')}'));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat', style: TextStyle(color: AppTheme.onSurface)),
        content: const Text('Are you sure you want to clear the conversation?',
            style: TextStyle(color: AppTheme.onSurfaceMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceMuted))),
          TextButton(
            onPressed: () { setState(() => _messages.clear()); Navigator.pop(ctx); },
            child: const Text('Clear', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = widget.getApiKey().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('AI Chat'),
        ]),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: _clearChat),
        ],
      ),
      body: Column(
        children: [
          if (!hasKey) ApiKeyBanner(onGoToSettings: widget.onGoToSettings),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => MessageBubble(message: _messages[i]),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final suggestions = ['Explain quantum computing', 'Write a poem about the ocean',
      'Help me debug my code', 'Tell me a fun fact'];
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppTheme.primary),
        ),
        const SizedBox(height: 20),
        const Text('Start a Conversation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
        const SizedBox(height: 8),
        const Text('Ask me anything — powered by GPT-4',
            style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceMuted)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
          children: suggestions.map((s) => ActionChip(
            label: Text(s, style: const TextStyle(fontSize: 12, color: AppTheme.onSurface)),
            backgroundColor: AppTheme.surfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
            onPressed: () { _controller.text = s; _sendMessage(); },
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.surfaceVariant, width: 1)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1, maxLines: 4,
            style: const TextStyle(color: AppTheme.onSurface, fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Message AI...',
              prefixIcon: Icon(Icons.edit_outlined, color: AppTheme.onSurfaceMuted, size: 20),
            ),
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: _isLoading ? AppTheme.surfaceVariant : AppTheme.primary,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isLoading ? null : _sendMessage,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _isLoading
                  ? const SpinKitThreeBounce(color: AppTheme.primary, size: 16)
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}