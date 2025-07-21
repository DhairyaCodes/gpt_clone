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
            child: Text(isUser ? "You" : "AI", style: const TextStyle(color: Colors.white, fontSize: 12)),
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUser && message.imageUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      height: screenHeight * 0.3,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: message.imageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              message.imageUrls[index],
                              width: 180,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 80),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
