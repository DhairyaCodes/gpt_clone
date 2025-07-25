import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/providers/auth_providers.dart';
import 'package:gpt_clone/providers/chat_providers.dart';
import 'package:gpt_clone/widgets/theme_slider.dart';

class ChatHistoryPanel extends ConsumerWidget {
  const ChatHistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsyncValue = ref.watch(conversationsProvider);
    final currentUser = ref.watch(authStateChangesProvider).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Stack(
        children: [
          ListView(
            children: [
              // Search bar

              const SizedBox(height: 76),

              // New Chat Button
              ListTile(
                leading: Icon(
                  Icons.edit_note_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                titleAlignment: ListTileTitleAlignment.center,
                title: Text(
                  'New chat',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  ref.read(chatStateProvider.notifier).startNewChat();
                  ref.read(selectedConversationProvider.notifier).state = null;
                  Navigator.of(context).pop(); // Close drawer
                },
              ),

              // Static Chats label
              ListTile(
                leading: Icon(
                  Icons.message_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                title: Text(
                  'Chats',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Chat History
              conversationsAsyncValue.when(
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "Start a Chat!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: conversations.map((conversation) {
                      final isSelected = conversation.id ==
                          ref.watch(selectedConversationProvider);
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: isSelected
                            ? Theme.of(context).colorScheme.tertiaryFixedDim
                            : Colors.transparent,
                        title: Text(
                          conversation.title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          try {
                            await ref
                                .read(chatStateProvider.notifier)
                                .loadConversation(conversation.id);
                            ref
                                .read(selectedConversationProvider.notifier)
                                .state = conversation.id;
                            Navigator.of(context).pop();
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to load conversation. Please try again!'),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Could not load chats.',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(conversationsProvider);
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.primary),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).colorScheme.secondary,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SafeArea(
                bottom: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryFixedDim,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  height: 56,
                  alignment: Alignment.center,
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        size: 28,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      hint: Text(
                        "Search",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                      enabled: false,
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        color: Theme.of(context).colorScheme.tertiaryFixedDim,
                        height: 1,
                      ),
                      // if (currentUser != null)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://res.cloudinary.com/dcwhinypr/image/upload/v1753128912/dp1_zrgayz.jpg'),
                          radius: 18,
                        ),
                        title: Text(
                          'Dhairya',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        trailing: Icon(Icons.more_horiz),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
