enum ChatRole { user, assistant }

enum MessageStatus { pending, delivered, failed }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.status = MessageStatus.delivered,
    this.responseTimeMs,
  });

  final ChatRole role;
  final String content;
  final MessageStatus status;
  final int? responseTimeMs;

  ChatMessage withStatus(MessageStatus status) => ChatMessage(
    role: role,
    content: content,
    status: status,
    responseTimeMs: responseTimeMs,
  );

  Map<String, String> toHistoryJson() => {
    'role': role == ChatRole.user ? 'user' : 'model',
    'text': content,
  };
}

class ChatReply {
  const ChatReply({required this.reply, this.responseTimeMs});

  final String reply;
  final int? responseTimeMs;

  factory ChatReply.fromJson(Object? data) {
    if (data is! Map<String, dynamic> || data['success'] != true) {
      throw const FormatException('Respons API tidak valid.');
    }
    final reply = data['reply'];
    final duration = data['response_time_ms'];
    if (reply is! String ||
        reply.trim().isEmpty ||
        (duration != null && (duration is! int || duration < 0))) {
      throw const FormatException('Isi respons API tidak valid.');
    }
    return ChatReply(reply: reply.trim(), responseTimeMs: duration as int?);
  }
}
