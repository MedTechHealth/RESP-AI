import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../providers/state_providers.dart';
import '../models/analysis_result.dart';
import 'result_screen.dart';

final audioServiceProvider = Provider((ref) => AudioService());

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;
  StreamSubscription? _audioSubscription;

  @override
  void dispose() {
    _timer?.cancel();
    _wsSubscription?.cancel();
    _audioSubscription?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    ref.read(recordingProvider.notifier).setDuration(0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = ref.read(recordingProvider);
      ref
          .read(recordingProvider.notifier)
          .setDuration(currentState.recordingDuration + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3'],
    );

    if (result != null && result.files.single.path != null) {
      ref
          .read(recordingProvider.notifier)
          .setRecordedFile(result.files.single.path);
      ref
          .read(recordingProvider.notifier)
          .setStatus('File selected: ${result.files.single.name}');
    }
  }

  void _toggleRecording() async {
    final audioService = ref.read(audioServiceProvider);
    final recordingState = ref.read(recordingProvider);
    final notifier = ref.read(recordingProvider.notifier);

    if (recordingState.isRecording) {
      // STOP RECORDING
      _stopTimer();
      notifier.setRecording(false);
      notifier.setAnalyzing(true);
      notifier.setStatus('Streaming to AI engine...');

      // Tell backend we are done
      _wsChannel?.sink.add('FINISH');

      // Stop audio stream
      await _audioSubscription?.cancel();
      // record.stop() is still needed to stop the hardware
      await audioService.stopRecording();
    } else {
      // START RECORDING (Streaming)
      try {
        final hasPermission = await audioService.checkPermission();
        if (hasPermission) {
          notifier.setStatus(null);

          // 1. Connect WebSocket
          _wsChannel = ApiService.connectStreaming();

          // 2. Listen for results
          _wsSubscription = _wsChannel!.stream.listen(
            (message) {
              final data = jsonDecode(message);
              if (data['status'] == 'success') {
                final result = AnalysisResult.fromJson(data);

                // Close the channel immediately after getting the result
                _wsChannel?.sink.close();

                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(result: result),
                    ),
                  );
                  notifier.setStatus('Analysis complete');
                  notifier.setAnalyzing(false);
                }
              } else if (data['error'] != null) {
                notifier.setStatus('Error: ${data['error']}');
                notifier.setAnalyzing(false);
                _wsChannel?.sink.close();
              }
            },
            onError: (e) {
              notifier.setStatus('Stream error: $e');
              notifier.setAnalyzing(false);
            },
            onDone: () {
              debugPrint("WebSocket Stream Closed");
            },
          );

          // 3. Start Audio Stream
          final audioStream = await audioService.startStreaming();
          _audioSubscription = audioStream.listen((chunk) {
            _wsChannel?.sink.add(chunk);
          });

          notifier.setRecording(true);
          notifier.setStatus('Streaming Live to AI... Breath deeply');
          _startTimer();
        } else {
          notifier.setStatus('Microphone permission denied');
        }
      } catch (e) {
        notifier.setStatus('Connection error: ${e.toString()}');
        notifier.setAnalyzing(false);
      }
    }
  }

  Future<void> _runAnalysis(String path) async {
    final notifier = ref.read(recordingProvider.notifier);

    notifier.setAnalyzing(true);
    notifier.setStatus('Finalizing recording disk data...');

    try {
      String cleanPath = path;
      try {
        if (cleanPath.startsWith('file://')) {
          cleanPath = Uri.parse(cleanPath).toFilePath();
        }
      } catch (e) {
        debugPrint("URI Parse error: $e");
      }

      final targetFile = File(cleanPath);
      debugPrint("Checking file at: $cleanPath");

      // Polling for file to exist
      int retries = 25; // 5 seconds (25 * 200ms)
      while (retries > 0) {
        if (await targetFile.exists()) {
          // Additional check: ensure it's not a 0-byte file
          if (await targetFile.length() > 0) break;
        }
        debugPrint("File not ready, retrying ($retries)...");
        await Future.delayed(const Duration(milliseconds: 200));
        retries--;
      }

      if (!await targetFile.exists() || await targetFile.length() == 0) {
        throw Exception(
          "Recording file is missing or empty. This is usually due to OS-level disk sync latency. Try recording again.",
        );
      }

      notifier.setStatus('Analyzing acoustic signature...');
      final result = await ApiService.analyzeAudio(cleanPath);

      if (mounted && ref.read(recordingProvider).recordedFilePath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
        );
        notifier.setStatus('Analysis complete');
      }
    } catch (e) {
      if (mounted && ref.read(recordingProvider).recordedFilePath != null) {
        notifier.setStatus('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        notifier.setAnalyzing(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'RESP-AI',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            fontSize: 26,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              tooltip: 'Reset App',
              icon: const Icon(
                LucideIcons.rotateCcw,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () => ref.read(recordingProvider.notifier).reset(),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 60),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _buildMainActionArea(recordingState),
                  ),
                  const SizedBox(height: 40),
                  _buildStatusCard(recordingState),
                  const SizedBox(height: 80),
                  _buildDisclaimerText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.shieldAlert, color: Colors.amber, size: 14),
              SizedBox(width: 10),
              Text(
                'RESEARCH PROTOTYPE • NOT A MEDICAL DEVICE',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.stethoscope,
            color: Colors.white,
            size: 40,
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        const Text(
          'Respiratory Risk Assessment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 12),
        const Text(
          'Acoustic signal processing for lung health screening',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildMainActionArea(RecordingState state) {
    return Column(
      key: ValueKey('${state.recordedFilePath != null}-${state.isRecording}'),
      children: [
        if (state.recordedFilePath == null || state.isRecording)
          _buildMicrophoneButton(state)
        else
          _buildFilePreview(state),
        const SizedBox(height: 32),
        if (!state.isRecording &&
            !state.isAnalyzing &&
            state.recordedFilePath == null)
          TextButton.icon(
            onPressed: () {
              ref.read(recordingProvider.notifier).setStatus(null);
              _pickFile();
            },
            icon: const Icon(LucideIcons.uploadCloud, size: 20),
            label: const Text(
              'Upload Existing Audio',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildMicrophoneButton(RecordingState state) {
    final bool canInteract = !state.isAnalyzing;
    return GestureDetector(
      onTap: canInteract ? _toggleRecording : null,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated ripple when recording
              if (state.isRecording)
                ...[1, 2, 3].map(
                  (i) =>
                      Container(
                            width: 160 + (i * 50),
                            height: 160 + (i * 50),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueAccent.withValues(
                                  alpha: 0.15,
                                ),
                                width: 1,
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.6, 1.6),
                            duration: 2.seconds,
                            curve: Curves.easeOut,
                          )
                          .fadeOut(),
                ),

              // Inner halo
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      (state.isRecording ? Colors.red : const Color(0xFF2563EB))
                          .withValues(alpha: 0.05),
                  border: Border.all(
                    color:
                        (state.isRecording
                                ? Colors.red
                                : const Color(0xFF2563EB))
                            .withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
              ),

              // Main button
              Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: state.isRecording
                            ? [Colors.red.shade400, Colors.red.shade700]
                            : [
                                const Color(0xFF3B82F6),
                                const Color(0xFF1D4ED8),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (state.isRecording
                                      ? Colors.red
                                      : const Color(0xFF2563EB))
                                  .withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      state.isRecording ? LucideIcons.square : LucideIcons.mic,
                      size: 48,
                      color: Colors.white,
                    ),
                  )
                  .animate(target: state.isRecording ? 1 : 0)
                  .shimmer(duration: 2.seconds, color: Colors.white24),

              if (state.isRecording)
                Positioned(
                  bottom: -15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _formatDuration(state.recordingDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ).animate().scale().fadeIn(),
            ],
          ),
          if (state.isRecording) ...[
            const SizedBox(height: 48),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  12,
                  (index) =>
                      Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 5,
                            height: 10 + (math.Random().nextDouble() * 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleY(
                            begin: 0.4,
                            end: 1.4,
                            duration: (300 + math.Random().nextInt(400)).ms,
                            curve: Curves.easeInOut,
                          ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilePreview(RecordingState state) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 550),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.activity,
                  color: Colors.blueAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'READY FOR ANALYSIS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 12,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.recordedFilePath!.split('/').last,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ref.read(recordingProvider.notifier).reset();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      LucideIcons.xCircle,
                      color: Colors.white38,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: state.isAnalyzing
                ? null
                : () => _runAnalysis(state.recordedFilePath!),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 12,
              shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.6),
            ),
            child: state.isAnalyzing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'ANALYZING...',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'START AI ANALYSIS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(RecordingState state) {
    if (state.statusMessage == null) return const SizedBox.shrink();

    final isError =
        state.statusMessage!.toLowerCase().contains('error') ||
        state.statusMessage!.toLowerCase().contains('failed') ||
        state.statusMessage!.toLowerCase().contains('exception');

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 0.1)
            : (state.isRecording
                  ? Colors.red.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError
              ? Colors.red.withValues(alpha: 0.3)
              : (state.isRecording
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.isAnalyzing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blueAccent,
              ),
            ),
          if (state.isAnalyzing) const SizedBox(width: 16),
          Expanded(
            child: Text(
              state.statusMessage!,
              textAlign: isError ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: isError
                    ? Colors.redAccent
                    : (state.isRecording ? Colors.redAccent : Colors.white70),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isError) ...[
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(recordingProvider.notifier).setStatus(null),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    LucideIcons.x,
                    color: Colors.white38,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate(key: ValueKey(state.statusMessage)).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildDisclaimerText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'RESEARCH PROTOTYPE • FOR SCREENING PURPOSES ONLY • NOT A CLINICAL DIAGNOSTIC DEVICE',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white24,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
