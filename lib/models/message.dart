class Message {
  final String role;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.text,
    this.imageUrl,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String textContent = '';
    String? imageUrlContent;

    if (json['parts'] != null) {
      for (var part in json['parts']) {
        if (part['text'] != null) {
          textContent += part['text'];
        }
        if (part['imageUrl'] != null) {
          imageUrlContent = part['imageUrl'];
        }
      }
    }

    return Message(
      role: json['role'],
      text: textContent,
      imageUrl: imageUrlContent,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}