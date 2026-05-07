import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  final String apiKey;

  OpenAIService({required this.apiKey});

  Future<String> sendChatMessage(List<Message> messages) async {
    final uri = Uri.parse('$_baseUrl/chat/completions');
    final systemMessage = {
      'role': 'system',
      'content': 'You are a helpful, friendly, and knowledgeable AI assistant. Provide clear, concise, and accurate responses.',
    };
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        systemMessage,
        ...messages.where((m) => !m.isLoading).map((m) => m.toApiMap()).toList(),
      ],
      'temperature': 0.7,
      'max_tokens': 1024,
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      final error = jsonDecode(response.body);
      final msg = error['error']?['message'] ?? 'Unknown error occurred';
      throw Exception('OpenAI API Error: $msg');
    }
  }

  Future<String> generateImage(String prompt) async {
    final uri = Uri.parse('$_baseUrl/images/generations');
    final body = jsonEncode({
      'model': 'dall-e-3',
      'prompt': prompt,
      'n': 1,
      'size': '1024x1024',
      'quality': 'standard',
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['url'] as String;
    } else {
      final error = jsonDecode(response.body);
      final msg = error['error']?['message'] ?? 'Unknown error occurred';
      throw Exception('OpenAI API Error: $msg');
    }
  }
}