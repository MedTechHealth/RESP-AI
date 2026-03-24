import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/analysis_result.dart';
import '../providers/state_providers.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/breath_halo_button.dart';
import '../widgets/mesh_background.dart';
import '../widgets/modern_glass_card.dart';
import 'result_screen.dart';

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  WebSocketChannel? _wsChannel;
  StreamSubscription<dynamic>? _wsSubscription;
  StreamSubscription<List<int>>? _audioSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  @override
  void dispose() {
    _timer?.cancel();
    _wsSubscription?.cancel();
    _audioSubscription?.cancel();
    _amplitudeSubscription?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    ref.read(recordingProvider.notifier).setDuration(0);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final RecordingState currentState = ref.read(recordingProvider);
      ref
          .read(recordingProvider.notifier)
          .setDuration(currentState.recordingDuration + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final String mins = (seconds / 60).floor().toString().padLeft(2, '0');
    final String secs = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['wav', 'mp3'],
    );

    if (result != null && result.files.single.path != null) {
      ref
          .read(recordingProvider.notifier)
          .setRecordedFile(result.files.single.path);
      ref
          .read(recordingProvider.notifier)
          .setStatus('Sample ready: ${result.files.single.name}');
    }
  }

  Future<void> _toggleRecording() async {
    final AudioService audioService = ref.read(audioServiceProvider);
    final RecordingState recordingState = ref.read(recordingProvider);
    final RecordingNotifier notifier = ref.read(recordingProvider.notifier);

    if (recordingState.isRecording) {
      _stopTimer();
      notifier.setRecording(false);
      notifier.setAnalyzing(true);
      notifier.setStatus('Finalizing live respiratory stream...');
      _wsChannel?.sink.add('FINISH');
      await _audioSubscription?.cancel();
      await _amplitudeSubscription?.cancel();
      await audioService.stopRecording();
      return;
    }

    try {
      final bool hasPermission = await audioService.checkPermission();
      if (!hasPermission) {
        notifier.setStatus('Microphone access was denied.');
        return;
      }

      notifier.setStatus(
        'Live capture engaged. Listening for respiratory signal...',
      );
      _wsChannel = ApiService.connectStreaming();
      _wsSubscription = _wsChannel!.stream.listen(
        (dynamic message) {
          final Map<String, dynamic> data =
              jsonDecode(message as String) as Map<String, dynamic>;
          if (data['status'] == 'success') {
            final AnalysisResult result = AnalysisResult.fromJson(data);
            _wsChannel?.sink.close();
            if (!mounted) {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => ResultScreen(result: result),
              ),
            );
            notifier.setStatus('Analysis complete.');
            notifier.setAnalyzing(false);
          } else if (data['error'] != null) {
            notifier.setStatus('Analysis error: ${data['error']}');
            notifier.setAnalyzing(false);
            _wsChannel?.sink.close();
          }
        },
        onError: (Object error) {
          notifier.setStatus('Streaming link failure: $error');
          notifier.setAnalyzing(false);
        },
      );

      final Stream<List<int>> audioStream = await audioService.startStreaming();
      _audioSubscription = audioStream.listen((List<int> chunk) {
        _wsChannel?.sink.add(chunk);
      });

      _amplitudeSubscription = audioService.onAmplitudeChanged().listen((amp) {
        // amp.current is in dB, from -160 to 0.
        // We want to map it to a 0.0 to 1.0 range for the ripple distortion.
        // -160 dB is effectively silence, -30 dB is quite loud.
        double normalized = (amp.current + 160) / 160;
        // Increase sensitivity for clinical breath sounds
        normalized = (normalized * 2.0).clamp(0.0, 1.2);
        notifier.setAmplitude(normalized);
      });

      notifier.setRecording(true);
      notifier.setAnalyzing(false);
      _startTimer();
    } catch (error) {
      notifier.setStatus('Unable to start capture: $error');
      notifier.setAnalyzing(false);
    }
  }

  Future<void> _runAnalysis(String path) async {
    final RecordingNotifier notifier = ref.read(recordingProvider.notifier);
    notifier.setAnalyzing(true);
    notifier.setStatus('Processing uploaded respiratory sample...');

    try {
      String cleanPath = path;
      if (cleanPath.startsWith('file://')) {
        cleanPath = Uri.parse(cleanPath).toFilePath();
      }

      final AnalysisResult result = await ApiService.analyzeAudio(cleanPath);

      if (!mounted) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ResultScreen(result: result),
        ),
      );
      notifier.setStatus('Analysis complete.');
    } catch (error) {
      notifier.setStatus('Analysis failed: $error');
    } finally {
      if (mounted) {
        notifier.setAnalyzing(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final RecordingState recordingState = ref.watch(recordingProvider);
    final bool useWideLayout = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.glass.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Icon(LucideIcons.stethoscope, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'RESP-AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Clinical Console',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => ref.read(recordingProvider.notifier).reset(),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text(
                'Reset session',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: MeshBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: useWideLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: _buildMainColumn(
                              context,
                              recordingState,
                              useWideLayout,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: _buildSideRail(
                              context,
                              recordingState,
                              useWideLayout,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildMainColumn(
                                context,
                                recordingState,
                                useWideLayout,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusPanel(
                            context,
                            recordingState,
                          ).animate().fadeIn(delay: 180.ms, duration: 450.ms),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainColumn(
    BuildContext context,
    RecordingState state,
    bool useWideLayout,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (useWideLayout) ...<Widget>[
          _buildHeroPanel(
            context,
            state,
          ).animate().fadeIn(duration: 450.ms).moveY(begin: 12, end: 0),
          const SizedBox(height: 20),
        ],
        Expanded(
          flex: useWideLayout ? 1 : 0,
          child: _buildCapturePanel(context, state, useWideLayout)
              .animate()
              .fadeIn(delay: 100.ms, duration: 450.ms)
              .moveY(begin: 12, end: 0),
        ),
        if (useWideLayout) ...<Widget>[
          const SizedBox(height: 20),
          _buildStatusPanel(
            context,
            state,
          ).animate().fadeIn(delay: 180.ms, duration: 450.ms),
        ],
      ],
    );
  }

  Widget _buildHeroPanel(BuildContext context, RecordingState state) {
    return ModernGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEyebrow(context, 'Real-time respiratory instrument'),
          const SizedBox(height: 12),
          Text(
            'Clinical Respiratory intake',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Capture a live breathing sample or upload a recording for automated risk scoring.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _buildSignalChip(
                context,
                icon: LucideIcons.activity,
                label: state.isRecording ? 'Capturing' : 'Standby',
                accent: state.isRecording
                    ? AppTheme.oxide
                    : AppTheme.respiratoryTeal,
              ),
              _buildSignalChip(
                context,
                icon: LucideIcons.shield,
                label: 'HIPAA Memory',
                accent: AppTheme.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapturePanel(
    BuildContext context,
    RecordingState state,
    bool useWideLayout,
  ) {
    final bool canAnalyzeUpload =
        state.recordedFilePath != null &&
        !state.isRecording &&
        !state.isAnalyzing;

    return ModernGlassCard(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = !useWideLayout || constraints.maxWidth < 720;
          final Widget halo = RepaintBoundary(
            child: BreathHaloButton(
              isRecording: state.isRecording,
              isAnalyzing: state.isAnalyzing,
              amplitude: state.amplitude,
              durationLabel: _formatDuration(state.recordingDuration),
              onPressed: _toggleRecording,
            ),
          );

          final Widget details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildEyebrow(context, 'Capture Engine'),
              const SizedBox(height: 12),
              Text(
                state.isRecording ? 'Streaming Signal...' : 'Prepare Patient',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.isRecording
                    ? 'Natural breathing pattern recommended.'
                    : 'Auscultation via mobile mic or WAV import.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isAnalyzing ? null : _toggleRecording,
                  icon: Icon(
                    state.isRecording ? LucideIcons.square : LucideIcons.mic,
                    size: 18,
                  ),
                  label: Text(
                    state.isRecording ? 'Stop Session' : 'Start Session',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: state.isAnalyzing ? null : _pickFile,
                      icon: const Icon(LucideIcons.upload, size: 16),
                      label: const Text(
                        'Import',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  if (state.recordedFilePath != null) ...<Widget>[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.respiratoryTeal,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: canAnalyzeUpload
                            ? () => _runAnalysis(state.recordedFilePath!)
                            : null,
                        icon: const Icon(LucideIcons.play, size: 16),
                        label: const Text(
                          'Analyze',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );

          if (stacked) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: halo),
                const SizedBox(height: 24),
                details,
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(flex: 6, child: details),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: halo),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusPanel(BuildContext context, RecordingState state) {
    final Color accent = state.isRecording
        ? AppTheme.oxide
        : state.isAnalyzing
        ? AppTheme.gold
        : AppTheme.respiratoryTeal;

    final String message =
        state.statusMessage ?? 'Ready for respiratory capture.';

    return ModernGlassCard(
      padding: const EdgeInsets.all(16),
      tint: accent.withValues(alpha: 0.06),
      borderColor: accent.withValues(alpha: 0.25),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (state.recordedFilePath != null)
            const Icon(
              LucideIcons.checkCircle,
              size: 14,
              color: AppTheme.success,
            ),
        ],
      ),
    );
  }

  Widget _buildSideRail(
    BuildContext context,
    RecordingState state,
    bool useWideLayout,
  ) {
    return Column(
      children: <Widget>[
        ModernGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildEyebrow(context, 'Triage Workflow'),
              const SizedBox(height: 16),
              _buildStep(
                context,
                index: '01',
                title: 'Acquire Signal',
                body: 'Live or imported audio.',
              ),
              const SizedBox(height: 12),
              _buildStep(
                context,
                index: '02',
                title: 'Run AI Review',
                body: 'Feature extraction.',
              ),
              const SizedBox(height: 12),
              _buildStep(
                context,
                index: '03',
                title: 'Review Risk',
                body: 'Confidence & patterns.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          flex: useWideLayout ? 1 : 0,
          child: ModernGlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildEyebrow(context, 'Instrument Telemetry'),
                const SizedBox(height: 16),
                _buildMiniMetric(
                  context,
                  label: 'Signal integrity',
                  value: 'Nominal',
                ),
                const SizedBox(height: 12),
                _buildMiniMetric(
                  context,
                  label: 'Analysis Latency',
                  value: '< 400ms',
                ),
                const SizedBox(height: 12),
                _buildMiniMetric(
                  context,
                  label: 'Mode',
                  value: state.isAnalyzing ? 'Inference' : 'Monitoring',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEyebrow(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppTheme.slateMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSignalChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.slate),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String index,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.goldSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            index,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.slate),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMetric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.slate),
        ),
      ],
    );
  }
}
