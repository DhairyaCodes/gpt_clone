import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/providers/auth_providers.dart';
import 'package:gpt_clone/providers/chat_providers.dart';

class ChatHistoryPanel extends ConsumerWidget {
  const ChatHistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsyncValue = ref.watch(conversationsProvider);
    final currentUser = ref.watch(authStateChangesProvider).value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            // New Chat Button
            Container(
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
                  fillColor: Colors.red,
                  hint: Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              height: 8,
            ),
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
              isThreeLine: false,
              onTap: () {
                ref.read(chatStateProvider.notifier).startNewChat();
                Navigator.of(context).pop(); // Close drawer
              },
            ),
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
              // onTap: () {
              //   ref.read(chatStateProvider.notifier).startNewChat();
              //   Navigator.of(context).pop(); // Close drawer
              // },
            ),

            Expanded(
              child: conversationsAsyncValue.when(
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return Center(
                      child: Text(
                        "Start a Chat!",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return ListTile(
                        title: Text(
                          conversation.title,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          ref
                              .read(selectedConversationProvider.notifier)
                              .state = conversation.id;
                          ref
                              .read(chatStateProvider.notifier)
                              .loadConversation(conversation.id);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Could not load chats.',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Invalidate the provider to retry the fetch
                          ref.invalidate(conversationsProvider);
                        },
                        style: ButtonStyle(
                          // side: WidgetStatePropertyAll(
                          //   BorderSide(
                          //     color: Theme.of(context).colorScheme.primary,
                          //   ),
                          // ),
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
            Divider(color: Theme.of(context).colorScheme.tertiary, height: 1),

            if (currentUser != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(currentUser.photoURL ?? ''),
                  radius: 14,
                ),
                title: Text(
                  currentUser.displayName ?? 'User',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.more_horiz,
                    color: Theme.of(context).colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}
