import 'dart:convert';
import 'package:flutter/services.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();

  factory ChatbotService() {
    return _instance;
  }

  ChatbotService._internal();

  List<Map<String, dynamic>> _chatbotData = [];
  bool _isLoaded = false;

  Future<void> loadChatbotData() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/chatbot_data.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      _chatbotData = jsonData.cast<Map<String, dynamic>>();
      _isLoaded = true;
    } catch (e) {
      _chatbotData = [];
    }
  }

  Map<String, dynamic>? getAnswer(String userMessage) {
    if (!_isLoaded || _chatbotData.isEmpty) {
      return null;
    }

    final message = userMessage.toLowerCase().trim();

    // 1. Exact question matching
    for (var botData in _chatbotData) {
      final questions = botData['questions'] as List<dynamic>?;
      if (questions != null) {
        for (var question in questions) {
          final q = question.toString().toLowerCase().trim();
          if (message == q) {
            return _buildResponse(botData); // Changed this line
          }
        }
      }
    }

    // 2. Contains matching
    for (var botData in _chatbotData) {
      final questions = botData['questions'] as List<dynamic>?;
      if (questions != null) {
        for (var question in questions) {
          final q = question.toString().toLowerCase().trim();
          if (message.length > q.length && message.contains(q)) {
            return _buildResponse(botData); // Changed this line
          }
          if (q.length > message.length &&
              q.contains(message) &&
              message.length > 5) {
            return _buildResponse(botData); // Changed this line
          }
        }
      }
    }

    // 3. Feature name matching
    for (var botData in _chatbotData) {
      final feature = botData['feature']?.toString().toLowerCase().trim() ?? '';
      if (feature.isNotEmpty) {
        if (message.contains(feature) || feature.contains(message)) {
          return _buildResponse(botData); // Changed this line
        }
      }
    }

    // 4. Keyword matching
    final keywords = _extractKeywords(message);
    if (keywords.isNotEmpty) {
      for (var botData in _chatbotData) {
        final feature =
            botData['feature']?.toString().toLowerCase().trim() ?? '';
        final featureKeywords = _extractKeywords(feature);
        final matchingKeywords = keywords
            .where((kw) => featureKeywords.contains(kw))
            .toList();

        if (matchingKeywords.length >= 2) {
          return _buildResponse(botData); // Changed this line
        }
        if (keywords.length == 1 && featureKeywords.contains(keywords[0])) {
          return _buildResponse(botData); // Changed this line
        }
      }
    }

    return null;
  }

  // Add this new helper method
  Map<String, dynamic> _buildResponse(Map<String, dynamic> botData) {
    final List<String> screenshots = [];

    if (botData['screenshots'] != null) {
      screenshots.addAll(
        (botData['screenshots'] as List).map((screenshot) {
          // Remove "assets/" prefix if present
          String path = screenshot.toString().replaceFirst('assets/', '');

          return 'http://160.187.80.215:8080/$path';
        }),
      );
    }

    return {'answer': botData['answer'], 'screenshots': screenshots};
  }

  List<String> _extractKeywords(String text) {
    final stopWords = [
      'how',
      'what',
      'where',
      'when',
      'why',
      'who',
      'do',
      'does',
      'is',
      'are',
      'the',
      'a',
      'an',
      'to',
      'i',
      'my',
      'can',
      'should',
      'will',
    ];
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    return words.where((w) => w.length > 2 && !stopWords.contains(w)).toList();
  }

  List<String> getAllFeatures() {
    return _chatbotData.map((data) => data['feature'].toString()).toList();
  }

  List<String> searchFeatures(String query) {
    final q = query.toLowerCase();
    return _chatbotData
        .where((data) => data['feature'].toString().toLowerCase().contains(q))
        .map((data) => data['feature'].toString())
        .toList();
  }
}
