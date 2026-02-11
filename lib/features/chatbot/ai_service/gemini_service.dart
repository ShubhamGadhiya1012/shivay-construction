import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyAVpRdkXnXngZjIsUL4ZeiwSJSj7pEbkzE';

  Future<String> sendMessage(String message) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent",
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              'x-goog-api-key': apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": message},
                  ],
                },
              ],
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            "No response from Gemini";
      } else if (response.statusCode == 429) {
        return _handleQuotaError();
      } else {
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        return '⚠️ Request timed out. Please check your internet connection and try again.';
      }
      return '⚠️ Network error. Please check your connection and try again.';
    }
  }

  String _handleQuotaError() {
    try {
      final now = DateTime.now();
      final unlockTime = DateTime(now.year, now.month, now.day + 1, 12, 30, 0);
      final secondsUntilReset = unlockTime.difference(now).inSeconds;

      final hoursUntilReset = secondsUntilReset ~/ 3600;
      final minutesUntilReset = (secondsUntilReset % 3600) ~/ 60;

      final unlockDate =
          '${unlockTime.day.toString().padLeft(2, '0')}-${unlockTime.month.toString().padLeft(2, '0')}-${unlockTime.year}';

      final hour12 = unlockTime.hour == 0
          ? 12
          : (unlockTime.hour > 12 ? unlockTime.hour - 12 : unlockTime.hour);
      final amPm = unlockTime.hour >= 12 ? 'PM' : 'AM';
      final unlockTimeStr =
          '${hour12.toString().padLeft(2, '0')}:${unlockTime.minute.toString().padLeft(2, '0')} $amPm';

      String timeRemaining;
      if (hoursUntilReset > 0) {
        timeRemaining = '$hoursUntilReset hours and $minutesUntilReset minutes';
      } else if (minutesUntilReset > 0) {
        timeRemaining = '$minutesUntilReset minutes';
      } else {
        timeRemaining = 'Less than a minute';
      }

      return """⏳ Daily Quota Limit Reached

Your AI quota has been exhausted for today.

📅 Unlock Date: $unlockDate
⏰ Unlock Time: $unlockTimeStr
⌛ Time Remaining: $timeRemaining

💡 Tip: Switch to Chatbot mode for app-specific queries, or try again after the quota unlocks.""";
    } catch (e) {
      return """⏳ Daily Quota Limit Reached

Your AI quota has been exhausted for today.

The quota will unlock tomorrow at 12:30 PM.

💡 Tip: Switch to Chatbot mode for app-specific queries.""";
    }
  }
}
