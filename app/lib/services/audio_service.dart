import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final _record = AudioRecorder();

  Future<String> getRecordingsDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, 'recordings');
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return path;
  }

  Future<void> _cleanupRecordings() async {
    try {
      final path = await getRecordingsDirectory();
      final dir = Directory(path);
      if (await dir.exists()) {
        final files = dir.listSync();
        for (var file in files) {
          if (file is File && file.path.endsWith('.wav')) {
            try {
              await file.delete();
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint("Error cleaning up: $e");
    }
  }

  Future<bool> checkPermission() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return await _record.hasPermission();
    }
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    try {
      if (await checkPermission()) {
        await _cleanupRecordings();
        final dir = await getTemporaryDirectory();

        // Use a static path to minimize entropy during testing
        final path = p.join(dir.path, 'resp_ai_recording.wav');

        debugPrint("CRITICAL: Starting recording to: $path");

        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        );

        if (await _record.isRecording()) {
          await _record.stop();
        }

        await _record.start(config, path: path);
      } else {
        throw Exception("Microphone permission not granted");
      }
    } catch (e) {
      debugPrint("CRITICAL Error starting recording: $e");
      rethrow;
    }
  }

  /// NEW: Stream audio data directly for WebSocket transfer
  Future<Stream<List<int>>> startStreaming() async {
    if (await checkPermission()) {
      if (await _record.isRecording()) {
        await _record.stop();
      }

      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000, // Match AI backend sample rate
        numChannels: 1,
      );

      return await _record.startStream(config);
    } else {
      throw Exception("Microphone permission not granted");
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _record.stop();
      debugPrint("CRITICAL: Recorder stopped. Raw path returned: $path");

      // Mandatory wait for OS flush
      await Future.delayed(const Duration(milliseconds: 1000));

      String? cleanPath = path;
      if (cleanPath != null && cleanPath.startsWith('file://')) {
        cleanPath = Uri.parse(cleanPath).toFilePath();
      }

      // Check provided path
      if (cleanPath != null) {
        final file = File(cleanPath);
        if (await file.exists() && await file.length() > 0) {
          debugPrint("CRITICAL: Verified file at $cleanPath");
          return cleanPath;
        }
      }

      // Fallback: search temp directory for ANY wav file created recently
      debugPrint("CRITICAL: Primary path failed. Searching fallback...");
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (var f in files) {
        if (f is File && f.path.endsWith('.wav')) {
          final size = await f.length();
          if (size > 0) {
            debugPrint("CRITICAL: Discovered fallback recording at ${f.path}");
            return f.path;
          }
        }
      }

      return cleanPath; // Return the original path if fallback discovery fails
    } catch (e) {
      debugPrint("CRITICAL Error stopping recording: $e");
      return null;
    }
  }

  Future<bool> isRecording() async {
    return await _record.isRecording();
  }

  void dispose() {
    _record.dispose();
  }
}
