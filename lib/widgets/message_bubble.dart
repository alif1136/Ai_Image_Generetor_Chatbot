import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});
  bool get isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _avatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(child: _bubble(context)),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _userAvatar(),
        ],
      ),
    );
  }

  Widget _avatar() => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
  );

  Widget _userAvatar() => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
        color: AppTheme.userBubble.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
    child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 18),
  );

  Widget _bubble(BuildContext context) {
    if (message.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.aiBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18),
            bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
          ),
        ),
        child: const SpinKitThreeBounce(color: AppTheme.primary, size: 18),
      );
    }
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.content));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.userBubble : AppTheme.aiBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
          ),
        ),
        child: isUser
            ? Text(message.content,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4))
            : MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: AppTheme.onSurface, fontSize: 15, height: 1.5),
            code: const TextStyle(color: AppTheme.accent,
                backgroundColor: Color(0xFF1A1A2E), fontSize: 13),
            codeblockDecoration: BoxDecoration(
                color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(8)),
            h1: const TextStyle(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700),
            h2: const TextStyle(color: AppTheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
            h3: const TextStyle(color: AppTheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
            listBullet: const TextStyle(color: AppTheme.primary),
            strong: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}