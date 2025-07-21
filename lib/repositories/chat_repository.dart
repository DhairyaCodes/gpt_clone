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
      final response =
          await _dio.get('/conversations/messages/$conversationId');
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
    required List<String> imageUrls,
    required String userId,
    required String model,
  }) async {
    final historyJson = history.map((message) {
      final parts = <Map<String, dynamic>>[];
      if (message.text.isNotEmpty) {
        parts.add({'text': message.text});
      }

      for (final url in message.imageUrls) {
        parts.add({'imageUrl': url});
      }
      return {'role': message.role, 'parts': parts};
    }).toList();

    final data = {
      'model': model,
      'message': message,
      'conversationId': conversationId,
      'history': historyJson,
      'userId': userId,
      if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
    };

    return _dio.post(
      '/chat',
      data: data,
      options: Options(responseType: ResponseType.stream),
    );
  }

  Future<List<String>> uploadImages(List<String> filePaths) async {
    try {
      final formData = FormData();

      for (final path in filePaths) {
        final fileName = path.split('/').last;
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(path, filename: fileName),
        ));
      }

      final response = await _dio.post('/chat/upload', data: formData);
      return List<String>.from(response.data['imageUrls']);
    } catch (e) {
      print("Error uploading images: $e");
      return [];
    }
  }
}
