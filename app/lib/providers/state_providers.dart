import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordingState {
  final bool isRecording;
  final bool isAnalyzing;
  final String? statusMessage;
  final String? recordedFilePath;
  final int recordingDuration;

  RecordingState({
    this.isRecording = false,
    this.isAnalyzing = false,
    this.statusMessage,
    this.recordedFilePath,
    this.recordingDuration = 0,
  });

  RecordingState copyWith({
    bool? isRecording,
    bool? isAnalyzing,
    String? statusMessage,
    String? recordedFilePath,
    int? recordingDuration,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      statusMessage: statusMessage ?? this.statusMessage,
      recordedFilePath: recordedFilePath ?? this.recordedFilePath,
      recordingDuration: recordingDuration ?? this.recordingDuration,
    );
  }
}

class RecordingNotifier extends Notifier<RecordingState> {
  @override
  RecordingState build() => RecordingState();

  void setRecording(bool isRecording) {
    state = state.copyWith(isRecording: isRecording);
  }

  void setAnalyzing(bool isAnalyzing) {
    state = state.copyWith(isAnalyzing: isAnalyzing);
  }

  void setStatus(String? message) {
    state = state.copyWith(statusMessage: message);
  }

  void setRecordedFile(String? path) {
    state = state.copyWith(recordedFilePath: path);
  }

  void setDuration(int duration) {
    state = state.copyWith(recordingDuration: duration);
  }

  void reset() {
    state = RecordingState();
  }
}

final recordingProvider = NotifierProvider<RecordingNotifier, RecordingState>(
  () {
    return RecordingNotifier();
  },
);
