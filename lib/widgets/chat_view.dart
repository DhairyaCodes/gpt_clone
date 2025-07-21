import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/providers/chat_providers.dart';
import 'package:gpt_clone/screens/new_chat.dart';
import 'package:gpt_clone/widgets/chat_input_field.dart';
import 'package:gpt_clone/widgets/message_bubble.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(chatStateProvider);

    return Column(
      children: [
        Expanded(
          child: conversation == null || conversation.messages.isEmpty
              ? const EmptyChatView()
              : ListView.builder(
                  itemCount: conversation.messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = conversation.messages.reversed.toList()[index];
                    return MessageBubble(message: message);
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatInputField(
              key: ValueKey(conversation?.id ?? 'new_chat_key'),
              onSendMessage: (message, {imageUrl}) async {
                await ref.read(chatStateProvider.notifier).sendMessage(message, imageUrl: imageUrl);
              },
            ),
          ),
        ),
      ],
    );
  }
}