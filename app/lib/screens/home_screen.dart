import 'dart:async';
import 'dart:io';
import 'dart:ui';
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
import '../widgets/modern_glass_card.dart';
import '../widgets/mesh_background.dart';
import '../theme/app_theme.dart';
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
      _stopTimer();
      notifier.setRecording(false);
      notifier.setAnalyzing(true);
      notifier.setStatus('Finalizing stream...');
      _wsChannel?.sink.add('FINISH');
      await _audioSubscription?.cancel();
      await audioService.stopRecording();
    } else {
      try {
        final hasPermission = await audioService.checkPermission();
        if (hasPermission) {
          notifier.setStatus(null);
          _wsChannel = ApiService.connectStreaming();
          _wsSubscription = _wsChannel!.stream.listen(
            (message) {
              final data = jsonDecode(message);
              if (data['status'] == 'success') {
                final result = AnalysisResult.fromJson(data);
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
          );

          final audioStream = await audioService.startStreaming();
          _audioSubscription = audioStream.listen((chunk) {
            _wsChannel?.sink.add(chunk);
          });

          notifier.setRecording(true);
          notifier.setStatus('Live Signal Acquisition Active');
          _startTimer();
        } else {
          notifier.setStatus('Microphone access denied');
        }
      } catch (e) {
        notifier.setStatus('Link failure: ${e.toString()}');
        notifier.setAnalyzing(false);
      }
    }
  }

  Future<void> _runAnalysis(String path) async {
    final notifier = ref.read(recordingProvider.notifier);
    notifier.setAnalyzing(true);
    notifier.setStatus('Analyzing acoustic signature...');

    try {
      String cleanPath = path;
      if (cleanPath.startsWith('file://')) {
        cleanPath = Uri.parse(cleanPath).toFilePath();
      }

      final result = await ApiService.analyzeAudio(cleanPath);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
        );
        notifier.setStatus('Analysis complete');
      }
    } catch (e) {
      notifier.setStatus('Analysis failed: ${e.toString()}');
    } finally {
      if (mounted) notifier.setAnalyzing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.5),
              title: Text(
                'RESP-AI',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  letterSpacing: 3.0,
                  color: AppTheme.primaryIndigo,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Reset session',
                  icon: const Icon(
                    LucideIcons.refreshCw,
                    size: 18,
                    color: AppTheme.primaryIndigo,
                  ),
                  onPressed: () => ref.read(recordingProvider.notifier).reset(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: MeshBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 50),
                    _buildStatusTag(recordingState),
                    const SizedBox(height: 30),
                    _buildMainActionArea(recordingState),
                    const SizedBox(height: 40),
                    _buildStatusCard(recordingState),
                    const SizedBox(height: 60),
                    _buildFooterInfo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(RecordingState state) {
    String text = "READY FOR SIGNAL";
    Color color = AppTheme.textSecondary;
    IconData icon = LucideIcons.power;

    if (state.isRecording) {
      text = "SIGNAL ACQUISITION LIVE";
      color = AppTheme.errorRose;
      icon = LucideIcons.activity;
    } else if (state.isAnalyzing) {
      text = "COMPUTING BIOMARKERS";
      color = AppTheme.primaryIndigo;
      icon = LucideIcons.cpu;
    } else if (state.recordedFilePath != null) {
      text = "SIGNAL READY FOR ANALYSIS";
      color = AppTheme.accentEmerald;
      icon = LucideIcons.checkCircle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16)
              .animate(
                onPlay: (c) => state.isRecording || state.isAnalyzing
                    ? c.repeat(reverse: true)
                    : null,
              )
              .fade(duration: 800.ms, curve: Curves.easeInOut),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryIndigo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.1)),
          ),
          child: const Text(
            'ACOUSTIC INTELLIGENCE LAB',
            style: TextStyle(
              color: AppTheme.primaryIndigo,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        Text(
          'Lung Health\nPrecision Screening',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 42, height: 1.0),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 20),
        Text(
          'AI-powered respiratory biomarker detection system. Transforming sound into clinical insights.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 17,
            height: 1.5,
            color: AppTheme.textSecondary,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildMainActionArea(RecordingState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      child: Column(
        key: ValueKey('${state.recordedFilePath != null}-${state.isRecording}'),
        children: [
          if (state.recordedFilePath == null || state.isRecording)
            _buildInteractiveMicrophone(state)
          else
            _buildBentoAnalysisPanel(state),
        ],
      ),
    );
  }

  Widget _buildInteractiveMicrophone(RecordingState state) {
    return Column(
      children: [
        GestureDetector(
          onTap: !state.isAnalyzing ? _toggleRecording : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (state.isRecording
                                  ? AppTheme.errorRose
                                  : AppTheme.primaryIndigo)
                              .withOpacity(0.02),
                      border: Border.all(
                        color:
                            (state.isRecording
                                    ? AppTheme.errorRose
                                    : AppTheme.primaryIndigo)
                                .withOpacity(0.05),
                        width: 2,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => state.isRecording ? c.repeat() : null)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  ),
              ModernGlassCard(
                    borderRadius: 110,
                    padding: EdgeInsets.zero,
                    opacity: 0.7,
                    blur: 40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: state.isRecording
                              ? [AppTheme.errorRose, const Color(0xFF9F1239)]
                              : [
                                  AppTheme.primaryIndigo,
                                  const Color(0xFF3730A3),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (state.isRecording
                                        ? AppTheme.errorRose
                                        : AppTheme.primaryIndigo)
                                    .withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Icon(
                        state.isRecording
                            ? LucideIcons.square
                            : LucideIcons.mic,
                        size: 54,
                        color: Colors.white,
                      ),
                    ),
                  )
                  .animate(target: state.isRecording ? 1 : 0)
                  .shimmer(duration: 3.seconds, color: Colors.white24),
              if (state.isRecording)
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      _formatDuration(state.recordingDuration),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ).animate().scale().fadeIn(),
                ),
            ],
          ),
        ),
        if (state.isRecording) ...[
          const SizedBox(height: 60),
          _buildAcousticViz(),
        ],
        if (!state.isRecording &&
            !state.isAnalyzing &&
            state.recordedFilePath == null) ...[
          const SizedBox(height: 60),
          _buildDropZonePrompt(),
        ],
      ],
    );
  }

  Widget _buildDropZonePrompt() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderMedium, width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.uploadCloud,
              color: AppTheme.primaryIndigo,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              'IMPORT SIGNAL FILE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryIndigo,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms),
    );
  }

  Widget _buildAcousticViz() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          20,
          (index) =>
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 5,
                    height: 10 + (math.Random().nextDouble() * 40),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRose.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleY(
                    begin: 0.2,
                    end: 1.8,
                    duration: (500 + math.Random().nextInt(800)).ms,
                    curve: Curves.easeInOut,
                  ),
        ),
      ),
    );
  }

  Widget _buildBentoAnalysisPanel(RecordingState state) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  LucideIcons.activity,
                  color: AppTheme.accentEmerald,
                  size: 32,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATIONARY SIGNAL READY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accentEmerald,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.recordedFilePath!.split('/').last,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, color: AppTheme.textTertiary),
                onPressed: () => ref.read(recordingProvider.notifier).reset(),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: state.isAnalyzing
                ? null
                : () => _runAnalysis(state.recordedFilePath!),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 72),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: state.isAnalyzing
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('START AI DIAGNOSTICS'),
                      SizedBox(width: 16),
                      Icon(LucideIcons.arrowRight, size: 20),
                    ],
                  ),
          ),
        ],
      ),
    ).animate().fadeIn().moveY(begin: 30, end: 0);
  }

  Widget _buildStatusCard(RecordingState state) {
    if (state.statusMessage == null) return const SizedBox.shrink();
    final isError =
        state.statusMessage!.toLowerCase().contains('error') ||
        state.statusMessage!.toLowerCase().contains('failed');

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isError
            ? AppTheme.errorRose.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isError
              ? AppTheme.errorRose.withOpacity(0.2)
              : AppTheme.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.isAnalyzing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primaryIndigo,
              ),
            ),
          if (state.isAnalyzing) const SizedBox(width: 16),
          Flexible(
            child: Text(
              state.statusMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isError ? AppTheme.errorRose : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).animate(key: ValueKey(state.statusMessage)).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.shieldCheck,
              color: AppTheme.textTertiary,
              size: 16,
            ),
            const SizedBox(width: 10),
            Text(
              'ADVANCED SIGNAL ENCRYPTION ACTIVE',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Experimental medical device. Not intended for self-diagnosis. Acoustic patterns are analyzed via temporal deep neural networks.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: AppTheme.textTertiary,
            height: 1.6,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }
}
