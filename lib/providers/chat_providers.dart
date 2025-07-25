import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/models/conversation.dart';
import 'package:gpt_clone/models/message.dart';
import 'package:gpt_clone/providers/auth_providers.dart';
import 'package:gpt_clone/repositories/chat_repository.dart';

final conversationsProvider =
    FutureProvider<List<ConversationSnippet>>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return []; // Return empty if no user

  final chatRepository = ref.read(chatRepositoryProvider);
  return chatRepository.getConversationList(user.uid);
});

final selectedConversationProvider = StateProvider<String?>((ref) => null);

final modelsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  return [
    {'name': 'Gemini Flash', 'code': 'gemini-1.5-flash-latest'},
    {'name': 'Gemini Pro', 'code': 'gemini-1.5-pro-latest'}
  ];
});

final selectedModelProvider =
    StateProvider<String>((ref) => 'gemini-1.5-flash-latest');

final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, Conversation?>((ref) {
  return ChatStateNotifier(ref);
});

class ChatStateNotifier extends StateNotifier<Conversation?> {
  final Ref _ref;
  ChatStateNotifier(this._ref) : super(null);

  void startNewChat() {
    state = null;
    _ref.invalidate(conversationsProvider);
  }

  Future<void> loadConversation(String conversationId) async {
    // state = null;
    try {
      final conversation = await _ref
          .read(chatRepositoryProvider)
          .getConversationMessages(conversationId);
      state = conversation;
    } catch (e) {
      print("Error loading conversation: $e");
      rethrow; // Propagate to UI
    }
  }

  Future<void> sendMessage({
    required String message,
    required List<String> imageUrls,
  }) async {
    final selectedModel = _ref.read(selectedModelProvider);
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final userMessage = Message(
      role: 'user',
      text: message,
      timestamp: DateTime.now(),
      imageUrls: imageUrls,
    );

    String conversationIdForRequest;
    List<Message> historyForRequest = [];
    if (state == null) {
      conversationIdForRequest = 'new';
      state = Conversation(
        id: 'temp_id',
        title: 'New Conversation',
        messages: [userMessage],
        modelUsed: selectedModel,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        isLoading: true,
      );
    } else {
      conversationIdForRequest = state!.id;
      historyForRequest = state!.messages;

      if (historyForRequest.last.role == 'user') {
        historyForRequest.removeLast();
        // historyForRequest.removeLast();
      }

      state = state!.copyWith(
          messages: [...historyForRequest, userMessage],
          isLoading: true,
          isError: false);
    }

    final aiLoadingMessage = Message(
      role: 'model',
      text: '',
      timestamp: DateTime.now(),
      imageUrls: [],
    );
    state = state!.copyWith(messages: [...state!.messages, aiLoadingMessage]);

    try {
      final Response<ResponseBody> streamResponse =
          await _ref.read(chatRepositoryProvider).sendMessage(
                message: message,
                conversationId: conversationIdForRequest,
                history: historyForRequest,
                imageUrls: imageUrls,
                model: selectedModel,
                userId: user.uid,
              );

      if (conversationIdForRequest == 'new') {
        final newId = streamResponse.headers.value('x-conversation-id');
        if (newId != null) {
          state = state!.copyWith(id: newId);
          _ref.invalidate(conversationsProvider);
        }
      }

      streamResponse.data!.stream.listen(
        (Uint8List uint8list) {
          final chunk = utf8.decode(uint8list, allowMalformed: true);
          final lastMessage = state!.messages.last;

          final updatedText = lastMessage.text + chunk;
          final updatedMessage = lastMessage.copyWith(text: updatedText);

          final updatedMessages = List<Message>.from(state!.messages);
          updatedMessages.last = updatedMessage;
          state = state!.copyWith(messages: updatedMessages);
        },
        onDone: () {
          state = state!.copyWith(isLoading: false);
          _ref.invalidate(conversationsProvider);
          _ref.read(selectedConversationProvider.notifier).state = state!.id;
        },
        onError: (error) {
          state = state!.copyWith(isLoading: false, isError: true);
          _ref.invalidate(conversationsProvider);
          // final updatedMessages = List<Message>.from(state!.messages);
          // final lastMessage = updatedMessages.last;
          // final errorMessage = lastMessage.copyWith(text: '');
          // updatedMessages[updatedMessages.length - 1] = errorMessage;

          final updatedMessages = List<Message>.from(state!.messages);
          updatedMessages.removeLast();
          state = state!.copyWith(messages: updatedMessages);

          print("Stream error: $error");

          throw Exception("Could not stream response. Please try again!");
        },
      );
    } catch (e) {
      print("Send message error: $e");
      state = state!.copyWith(isLoading: false, isError: true);

      // final updatedMessages = List<Message>.from(state!.messages);
      // final lastMessage = updatedMessages.last;
      // final errorMessage = lastMessage.copyWith(text: '');
      // updatedMessages[updatedMessages.length - 1] = errorMessage;

      final updatedMessages = List<Message>.from(state!.messages);
      updatedMessages.removeLast();
      state = state!.copyWith(messages: updatedMessages);

      throw Exception("Could not send message. Please try again!");
    }
  }
}

extension on Message {
  Message copyWith({String? text}) {
    return Message(
      role: role,
      text: text ?? this.text,
      imageUrls: imageUrls,
      timestamp: timestamp,
    );
  }
}

extension on Conversation {
  Conversation copyWith(
      {String? id, List<Message>? messages, bool? isLoading, bool? isError}) {
    return Conversation(
        id: id ?? this.id,
        title: title,
        messages: messages ?? this.messages,
        modelUsed: modelUsed,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
        isLoading: isLoading ?? this.isLoading,
        isError: isError ?? this.isError);
  }
}
