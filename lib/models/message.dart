class Message {
  final String role;
  final String text;
  final List<String> imageUrls;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.text,
    required this.imageUrls,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String textContent = '';
    List<String> imageUrls = [];

    if (json['parts'] != null) {
      for (var part in json['parts']) {
        if (part['text'] != null) {
          textContent += part['text'];
        }
        if (part['imageUrls'] != null && part['imageUrls'] is List) {
          imageUrls.addAll(List<String>.from(part['imageUrls']));
        }
      }
    }

    return Message(
      role: json['role'],
      text: textContent,
      imageUrls: imageUrls,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}