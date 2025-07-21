import 'package:gpt_clone/models/message.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final String modelUsed;
  final DateTime createdAt;
  final DateTime modifiedAt;

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.modelUsed,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((messageJson) => Message.fromJson(messageJson))
          .toList(),
      modelUsed: json['modelUsed'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
    );
  }
}

class ConversationSnippet {
    final String id;
    final String title;
    final DateTime createdAt;

    ConversationSnippet({required this.id, required this.title, required this.createdAt});

    factory ConversationSnippet.fromJson(Map<String, dynamic> json) {
        return ConversationSnippet(
            id: json['_id'],
            title: json['title'],
            createdAt: DateTime.parse(json['createdAt']),
        );
    }
}