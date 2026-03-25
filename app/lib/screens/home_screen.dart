import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
        double normalized = (amp.current + 160) / 160;
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
    final Size size = MediaQuery.sizeOf(context);
    final bool useWideLayout = size.width >= 1024;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80,
        title: _buildAppBarTitle(context),
        actions: _buildAppBarActions(context),
      ),
      body: MeshBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _clamp(20, 40, size.width),
              vertical: _clamp(12, 24, size.height),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: useWideLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Stage (60%)
                          Expanded(
                            flex: 6,
                            child: _buildStage(context, recordingState),
                          ),
                          SizedBox(width: _clamp(20, 40, size.width)),
                          // Bento Side-Rail (40%)
                          Expanded(
                            flex: 4,
                            child: _buildBentoRail(context, recordingState),
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: _buildStage(
                              context,
                              recordingState,
                              isMobile: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 5,
                            child: _buildBentoRail(
                              context,
                              recordingState,
                              isMobile: true,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _clamp(double min, double max, double screenDim) {
    return (screenDim / 100).clamp(min, max);
  }

  Widget _buildAppBarTitle(BuildContext context) {
    final bool useWideLayout = MediaQuery.sizeOf(context).width >= 1024;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.glass.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.glassBorder, width: 0.5),
          ),
          child: const Icon(
            LucideIcons.stethoscope,
            size: 20,
            color: AppTheme.slate,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'RESP-AI',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slate,
                  letterSpacing: -0.2,
                ),
              ),
              if (useWideLayout)
                Text(
                  'INSTRUMENT DASHBOARD',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: AppTheme.slateMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 24),
        child: TextButton.icon(
          onPressed: () => ref.read(recordingProvider.notifier).reset(),
          icon: const Icon(LucideIcons.refreshCw, size: 14),
          label: Text(
            'RESET SESSION',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.slate,
              fontSize: 11,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildStage(
    BuildContext context,
    RecordingState state, {
    bool isMobile = false,
  }) {
    return _buildStageCard(context, state);
  }

  Widget _buildStageCard(BuildContext context, RecordingState state) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(0),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: Center(
              child: BreathHaloButton(
                isRecording: state.isRecording,
                isAnalyzing: state.isAnalyzing,
                amplitude: state.amplitude,
                durationLabel: _formatDuration(state.recordingDuration),
                onPressed: _toggleRecording,
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildEyebrow(context, 'Primary Instrument'),
                const SizedBox(height: 8),
                Text(
                  'Respiratory Capture',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    color: AppTheme.slate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: _buildStatusPanel(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoRail(
    BuildContext context,
    RecordingState state, {
    bool isMobile = false,
  }) {
    return Column(
      children: <Widget>[
        Expanded(flex: 5, child: _buildClinicalProtocolCard(context, state)),
        const SizedBox(height: 16),
        Expanded(flex: 4, child: _buildTelemetryGrid(context, state)),
        const SizedBox(height: 16),
        Expanded(flex: 3, child: _buildSampleManagementCard(context, state)),
      ],
    );
  }

  Widget _buildClinicalProtocolCard(
    BuildContext context,
    RecordingState state,
  ) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEyebrow(context, 'Clinical Protocol'),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildStep(
                  context,
                  index: '01',
                  title: 'Auscultation',
                  body: 'Engage capture for 10-15s breath cycle.',
                  isActive:
                      !state.isRecording && state.recordedFilePath == null,
                  isComplete:
                      state.recordedFilePath != null || state.isRecording,
                ),
                _buildStep(
                  context,
                  index: '02',
                  title: 'AI Synthesis',
                  body: 'Neural feature extraction & review.',
                  isActive: state.isAnalyzing,
                  isComplete: false,
                ),
                _buildStep(
                  context,
                  index: '03',
                  title: 'Risk Scoring',
                  body: 'Clinical narrative generation.',
                  isActive: false,
                  isComplete: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(BuildContext context, RecordingState state) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: ModernGlassCard(
            padding: const EdgeInsets.all(20),
            child: _buildTelemetryTile(
              context,
              label: 'SIGNAL',
              value: state.isRecording ? 'STREAMING' : 'IDLE',
              icon: LucideIcons.activity,
              accent: state.isRecording ? AppTheme.oxide : AppTheme.mentholCyan,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ModernGlassCard(
            padding: const EdgeInsets.all(20),
            child: _buildTelemetryTile(
              context,
              label: 'LATENCY',
              value: '< 120ms',
              icon: LucideIcons.zap,
              accent: AppTheme.mentholCyan,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSampleManagementCard(
    BuildContext context,
    RecordingState state,
  ) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildEyebrow(context, 'Sample Management'),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: state.isAnalyzing ? null : _pickFile,
                  icon: const Icon(LucideIcons.upload, size: 18),
                  label: const Text('IMPORT'),
                ),
              ),
              if (state.recordedFilePath != null &&
                  !state.isRecording) ...<Widget>[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.respiratoryTeal,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: state.isAnalyzing
                        ? null
                        : () => _runAnalysis(state.recordedFilePath!),
                    icon: const Icon(LucideIcons.play, size: 18),
                    label: const Text('ANALYZE'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildEyebrow(context, label),
            Icon(icon, size: 14, color: accent),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.slate,
            fontFeatures: AppTheme.tabularFigures,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String index,
    required String title,
    required String body,
    bool isActive = false,
    bool isComplete = false,
  }) {
    final Color accent = isActive
        ? AppTheme.respiratoryTeal
        : (isComplete ? AppTheme.success : AppTheme.slateMuted);

    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.2), width: 1),
          ),
          child: isComplete
              ? const Icon(LucideIcons.check, size: 18, color: AppTheme.success)
              : Text(
                  index,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppTheme.slate : AppTheme.slateMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppTheme.slateMuted,
                ),
              ),
            ],
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

  Widget _buildStatusPanel(BuildContext context, RecordingState state) {
    final Color accent = state.isRecording
        ? AppTheme.oxide
        : state.isAnalyzing
        ? AppTheme.gold
        : AppTheme.respiratoryTeal;

    final String message =
        state.statusMessage ?? 'Ready for respiratory capture.';

    return ModernGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      tint: accent.withValues(alpha: 0.08),
      borderColor: accent.withValues(alpha: 0.2),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.8,
                color: AppTheme.slate,
              ),
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
}
