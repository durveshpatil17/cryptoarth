class ChatMessage {
  final String id;
  final String role;
  final String content;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}
