enum MessageRole { user, assistant }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  factory Message.user(String content) => Message(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    content: content,
    role: MessageRole.user,
    timestamp: DateTime.now(),
  );

  factory Message.loading() => Message(
    id: 'loading',
    content: '',
    role: MessageRole.assistant,
    timestamp: DateTime.now(),
    isLoading: true,
  );

  factory Message.assistant(String content) => Message(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    content: content,
    role: MessageRole.assistant,
    timestamp: DateTime.now(),
  );

  Map<String, dynamic> toApiMap() => {
    'role': role == MessageRole.user ? 'user' : 'assistant',
    'content': content,
  };
}