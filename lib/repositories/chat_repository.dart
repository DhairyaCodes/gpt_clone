import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_clone/models/conversation.dart';
import 'package:gpt_clone/models/message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

class ChatRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:5000/api',
    ),
  );

  Future<List<ConversationSnippet>> getConversationList(String userId) async {
    try {
      final response = await _dio.get('/conversations/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => ConversationSnippet.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching conversation list: $e");
      return [];
    }
  }

  Future<Conversation?> getConversationMessages(String conversationId) async {
    try {
      final response = await _dio.get('/conversations/messages/$conversationId');
      return Conversation.fromJson(response.data);
    } catch (e) {
      print("Error fetching messages: $e");
      return null;
    }
  }

  Future<Response<ResponseBody>> sendMessage({
    required String message,
    required String conversationId,
    required List<Message> history,
    String? imageUrl,
    required String userId, 
    required String model,
  }) async {
    final historyJson = history.map((m) => {
      'role': m.role,
      'parts': [{'text': m.text}]
    }).toList();

    final data = {
      'model': model,
      'message': message,
      'conversationId': conversationId,
      'history': historyJson,
      'userId': userId,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };

    return _dio.post(
      '/chat',
      data: data,
      options: Options(responseType: ResponseType.stream),
    );
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post('/chat/upload', data: formData);
      return response.data['imageUrl'];
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}