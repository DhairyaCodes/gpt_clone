import 'package:flutter/material.dart';
import 'package:gpt_clone/models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isUser ? null : Theme.of(context).colorScheme.secondary.withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isUser ? Colors.blueAccent : Colors.green,
            child: Text(isUser ? "You" : "AI", style: const TextStyle(color: Colors.white)),
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.4,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(message.imageUrl!),
                      ),
                    ),
                  ),
                if (message.text.isNotEmpty)
                  Text(message.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}