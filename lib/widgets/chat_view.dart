import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gpt_clone/providers/chat_providers.dart';
import 'package:gpt_clone/screens/new_chat.dart';
import 'package:gpt_clone/widgets/chat_input_field.dart';
import 'package:gpt_clone/widgets/error_box.dart';
import 'package:gpt_clone/widgets/loading_widget.dart';
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

    final messages = conversation?.messages ?? [];

    final messageWidgets = [
      ...messages.map((message) => MessageBubble(message: message)),
      if (conversation?.isError == true) const ErrorBox(),
      if (conversation?.isLoading == true) const LoadingWidget(),
      const SizedBox(height: 12), // Spacer at end
    ];

    final revMessageWidgets = messageWidgets.reversed.toList();

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const EmptyChatView()
              : ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemBuilder: (context, index) {
                    return revMessageWidgets[index];
                  },
                  itemCount: revMessageWidgets.length,
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatInputField(
              key: ValueKey(conversation?.id ?? 'new_chat_key'),
              onSendMessage: ({required message, required imageUrls}) async {
                await ref
                    .read(chatStateProvider.notifier)
                    .sendMessage(message: message, imageUrls: imageUrls);
              },
            ),
          ),
        ),
      ],
    );
  }
}
