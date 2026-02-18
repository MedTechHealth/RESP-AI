import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/analysis_result.dart';

class ApiService {
  // Desktop/iOS can use localhost, Android Emulator needs 10.0.2.2
  static String get _baseUrl {
    return 'http://127.0.0.1:8000';
  }

  static String get _wsUrl {
    return 'ws://127.0.0.1:8000/api/ws-analyze';
  }

  static Future<AnalysisResult> analyzeAudio(String filePath) async {
    final uri = Uri.parse('$_baseUrl/api/analyze');
    final request = http.MultipartRequest('POST', uri);

    // Add audio file
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return AnalysisResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to analyze audio: ${response.body}');
      }
    } catch (e) {
      // If localhost fails, try 10.0.2.2 for Android Emulator as a fallback
      if (e.toString().contains('Connection refused') &&
          _baseUrl.contains('127.0.0.1')) {
        final fallbackUri = Uri.parse('http://10.0.2.2:8000/api/analyze');
        final fallbackRequest = http.MultipartRequest('POST', fallbackUri);
        fallbackRequest.files.add(
          await http.MultipartFile.fromPath('file', filePath),
        );
        final fallbackStreamedResponse = await fallbackRequest.send();
        final fallbackResponse = await http.Response.fromStream(
          fallbackStreamedResponse,
        );
        if (fallbackResponse.statusCode == 200) {
          return AnalysisResult.fromJson(jsonDecode(fallbackResponse.body));
        }
      }
      rethrow;
    }
  }

  /// NEW: Connect to the streaming WebSocket endpoint
  static WebSocketChannel connectStreaming() {
    // Try primary WS URL
    try {
      return WebSocketChannel.connect(Uri.parse(_wsUrl));
    } catch (e) {
      // Fallback for Android emulator
      return WebSocketChannel.connect(
        Uri.parse('ws://10.0.2.2:8000/api/ws-analyze'),
      );
    }
  }
}
