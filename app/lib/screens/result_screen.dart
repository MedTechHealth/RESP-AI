import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
// import 'package:responsive_framework/responsive_framework.dart'; // Removed: not used directly after changes

import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
// import '../widgets/holographic_lung.dart'; // Removed HolographicLung
import '../widgets/mesh_background.dart';
import '../widgets/modern_glass_card.dart'; // Will be replaced by GlassmorphicContainer later

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final bool useWideLayout = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: _buildAppBarTitle(context),
        actions: _buildAppBarActions(context),
      ),
      body: MeshBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _clamp(20, 40, MediaQuery.sizeOf(context).width),
              vertical: _clamp(12, 24, MediaQuery.sizeOf(context).height),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1800),
                child: useWideLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Left Rail: Assessment stats
                          Expanded(
                            flex: 3,
                            child: _buildAssessmentRail(context),
                          ),
                          const SizedBox(width: 20),
                          // Center Stage: Diagnostic Lung & Massive Result
                          Expanded(flex: 6, child: _buildResultStage(context)),
                          const SizedBox(width: 20),
                          // Right Rail: Protocols & Context
                          Expanded(flex: 3, child: _buildContextRail(context)),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Expanded(flex: 7, child: _buildResultStage(context)),
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 5,
                            child: _buildAssessmentRail(context),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'CLINICAL REVIEW',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            letterSpacing: 1.5,
            color: AppTheme.vaprupBlue.withAlpha((0.6 * 255).round()),
          ),
        ),
        Text(
          'ID: ${result.filename.split('/').last}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 12,
            color: AppTheme.vaprupBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.vaprupBlue.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withAlpha((0.5 * 255).round()),
            width: 0.5,
          ),
        ),
        child: Text(
          'SECURE SESSION',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 9,
            letterSpacing: 1.2,
            color: AppTheme.vaprupBlue.withAlpha((0.5 * 255).round()),
          ),
        ),
      ),
    ];
  }

  Widget _buildResultStage(BuildContext context) {
    final String condition = result.diseaseAssociation.condition.toUpperCase();
    final double confidence = result.probability * 100;

    return ModernGlassCard(
      // Will be GlassmorphicContainer in Task 4
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background Center Viz
          Center(
            child: Opacity(
              opacity: 0.8,
              // HolographicLung will be replaced by DynamicLungModel later (Task 5)
              child: Container(
                width: 500,
                height: 500,
                color: AppTheme.vaprupBlue.withAlpha(
                  (0.05 * 255).round(),
                ), // Placeholder color
                child: const Center(
                  child: Text('Dynamic Lung Model Placeholder'),
                ),
              ),
            ),
          ),
          // Massive Top Result
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildEyebrow(context, 'Primary Finding'),
                const SizedBox(height: 12),
                Text(
                  'CONDITION: $condition',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    color: AppTheme.vaprupBlue,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'CONFIDENCE: ${confidence.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                    color: AppTheme.vaprupTeal,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Bottom Narrative
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ModernGlassCard(
                // Will be GlassmorphicContainer in Task 4
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildEyebrow(context, 'Clinical Narrative'),
                    const SizedBox(height: 12),
                    Text(
                      _summarySentence(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        color: AppTheme.vaprupBlue.withAlpha(
                          (0.8 * 255).round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentRail(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(flex: 4, child: _buildConfidencePanel(context)),
        const SizedBox(height: 16),
        Expanded(flex: 6, child: _buildScorePanel(context)),
      ],
    );
  }

  Widget _buildContextRail(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(flex: 5, child: _buildRecommendationPanel(context)),
        const SizedBox(height: 16),
        Expanded(flex: 5, child: _buildEvidenceGrid(context)),
      ],
    );
  }

  Widget _buildConfidencePanel(BuildContext context) {
    final double confidencePercent = result.probability * 100;
    final Color accent = confidencePercent >= 75
        ? Theme.of(context).colorScheme.tertiaryContainer
        : confidencePercent >= 45
        ? AppTheme.warningAmber
        : AppTheme.alertCoral;

    return ModernGlassCard(
      // Will be GlassmorphicContainer in Task 4
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildEyebrow(context, 'Classification Confidence'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                confidencePercent.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.vaprupBlue,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.vaprupBlue.withAlpha((0.5 * 255).round()),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Association Confidence: ${result.diseaseAssociation.confidence}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.vaprupBlue.withAlpha((0.6 * 255).round()),
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: result.probability.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppTheme.vaprupMint.withAlpha(
              (0.5 * 255).round(),
            ), // AppTheme.frostDeep
            color: accent,
          ),
        ],
      ),
    );
  }

  Widget _buildScorePanel(BuildContext context) {
    final Color riskColor = _riskColor(context, result.riskScore);

    return ModernGlassCard(
      // Will be GlassmorphicContainer in Task 4
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEyebrow(context, 'Instrument Signal'),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: CustomPaint(
                    painter: _RiskDialPainter(
                      score: result.riskScore,
                      color: riskColor,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              result.riskScore.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.vaprupBlue,
                                    height: 1.0,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              result.classification.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: riskColor,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _riskHeadline(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.vaprupBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceGrid(BuildContext context) {
    final List<dynamic> anomalies =
        (result.details['detected_anomalies'] as List<dynamic>?) ?? <dynamic>[];
    return ModernGlassCard(
      // Will be GlassmorphicContainer in Task 4
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEyebrow(context, 'Telemetry Markers'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                _evidenceRow(
                  context,
                  title: 'Pattern',
                  value: result.diseaseAssociation.condition,
                  icon: LucideIcons.fingerprint,
                  accent: AppTheme.vaprupTeal, // AppTheme.mentholCyan
                ),
                const Divider(height: 24),
                _evidenceRow(
                  context,
                  title: 'Model',
                  value: result.classification,
                  icon: LucideIcons.cpu,
                  accent: AppTheme.warningAmber, // AppTheme.clinicalAmber
                ),
                const Divider(height: 24),
                _evidenceRow(
                  context,
                  title: 'Markers',
                  value: anomalies.isEmpty ? 'None' : anomalies.join(', '),
                  icon: LucideIcons.alertTriangle,
                  accent: AppTheme.alertCoral, // AppTheme.oxide
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _evidenceRow(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Row(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: AppTheme.vaprupBlue.withAlpha((0.5 * 255).round()),
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  color: AppTheme.vaprupBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationPanel(BuildContext context) {
    return ModernGlassCard(
      // Will be GlassmorphicContainer in Task 4
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEyebrow(context, 'Clinical Context'),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _noteRow(
                  context,
                  icon: LucideIcons.stethoscope,
                  text: 'Decision support tool only. Not a clinical diagnosis.',
                ),
                _noteRow(
                  context,
                  icon: LucideIcons.shieldAlert,
                  text:
                      (result.details['medical_disclaimer'] as String?) ??
                      'Professional consultation required.',
                ),
                _noteRow(
                  context,
                  icon: LucideIcons.rotateCcw,
                  text: 'Repeat analysis if ambient noise was present.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(
            icon,
            size: 14,
            color: AppTheme.vaprupBlue.withAlpha((0.4 * 255).round()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppTheme.vaprupBlue.withAlpha((0.7 * 255).round()),
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
        color: AppTheme.vaprupBlue.withAlpha((0.5 * 255).round()),
        letterSpacing: 1.1,
      ),
    );
  }

  String _summarySentence() {
    final String condition = result.diseaseAssociation.condition;
    final String band = _riskBand().toLowerCase();
    return 'Mapped to $band risk (${result.riskScore.toStringAsFixed(1)}/10). Pattern associated with $condition.';
  }

  String _riskHeadline() {
    if (result.riskScore >= 7) {
      return 'Elevated Attention Required';
    }
    if (result.riskScore >= 4) {
      return 'Moderate Pattern Variance';
    }
    return 'Low Risk Signal Trend';
  }

  String _riskBand() {
    if (result.riskScore >= 7) {
      return 'Elevated';
    }
    if (result.riskScore >= 4) {
      return 'Moderate';
    }
    return 'Low';
  }

  Color _riskColor(BuildContext context, double score) {
    if (score >= 7) {
      return AppTheme.alertCoral; // AppTheme.oxide
    }
    if (score >= 4) {
      return AppTheme.warningAmber; // AppTheme.clinicalAmber
    }
    return Theme.of(context).colorScheme.tertiaryContainer; // AppTheme.success
  }
}

class _RiskDialPainter extends CustomPainter {
  const _RiskDialPainter({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.9);
    final double radius = math.min(size.width * 0.4, size.height * 0.78);

    // Main Track
    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.vaprupMint; // AppTheme.frostDeep

    final Paint trackInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.vaprupMint.withAlpha(
        (0.3 * 255).round(),
      ); // AppTheme.frostDeep

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Rect rectInner = Rect.fromCircle(center: center, radius: radius - 20);

    canvas.drawArc(rect, math.pi, math.pi, false, track);
    canvas.drawArc(rectInner, math.pi, math.pi, false, trackInner);

    // Progress
    final double sweep = math.pi * (score.clamp(0, 10) / 10);

    final Paint progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = color;

    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..color = color.withAlpha((0.15 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(rectInner, math.pi, sweep, false, glow);
    canvas.drawArc(rectInner, math.pi, sweep, false, progress);

    // Precision Ticks
    final Paint majorTick = Paint()
      ..color = AppTheme.vaprupBlue.withAlpha((0.4 * 255).round())
      ..strokeWidth = 1.2;
    final Paint minorTick = Paint()
      ..color = AppTheme.vaprupBlue.withAlpha((0.15 * 255).round())
      ..strokeWidth = 0.8;

    for (int index = 0; index <= 40; index++) {
      final double angle = math.pi + (math.pi / 40) * index;
      final bool isMajor = index % 4 == 0;
      final double length = isMajor ? 12.0 : 6.0;

      final Offset outer =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 2);
      final Offset inner =
          center +
          Offset(math.cos(angle), math.sin(angle)) * (radius + 2 + length);

      canvas.drawLine(outer, inner, isMajor ? majorTick : minorTick);
    }

    // Needle
    final Paint needlePaint = Paint()
      ..color = AppTheme.vaprupBlue
      ..style = PaintingStyle.fill;

    final double needleAngle = math.pi + sweep;
    final Path needlePath = Path();

    final Offset needleBase1 =
        center +
        Offset(math.cos(needleAngle + 0.1), math.sin(needleAngle + 0.1)) * 12;
    final Offset needleBase2 =
        center +
        Offset(math.cos(needleAngle - 0.1), math.sin(needleAngle - 0.1)) * 12;
    final Offset needleTip =
        center +
        Offset(math.cos(needleAngle), math.sin(needleAngle)) * (radius - 36);

    needlePath.moveTo(needleBase1.dx, needleBase1.dy);
    needlePath.lineTo(needleBase2.dx, needleBase2.dy);
    needlePath.lineTo(needleTip.dx, needleTip.dy);
    needlePath.close();

    canvas.drawPath(needlePath, needlePaint);
    canvas.drawCircle(center, 5, needlePaint);
    canvas.drawCircle(center, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RiskDialPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
