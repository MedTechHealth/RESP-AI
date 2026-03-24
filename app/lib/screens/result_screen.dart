import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/mesh_background.dart';
import '../widgets/modern_glass_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final bool useWideLayout = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Text(
          'Clinical Review',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 14, letterSpacing: 0.4),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 18),
          tooltip: 'Back to Dashboard',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MeshBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: useWideLayout
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildNarrativeHeader(context)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .moveY(begin: 12, end: 0),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 7,
                                  child: _buildMainColumn(context, true),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 4,
                                  child: _buildSideColumn(context, true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            _buildNarrativeHeader(context),
                            const SizedBox(height: 20),
                            _buildMainColumn(context, false),
                            const SizedBox(height: 20),
                            _buildSideColumn(context, false),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrativeHeader(BuildContext context) {
    return ModernGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildEyebrow(
                context,
                'Respiratory Profile · ID: ${result.filename.split('/').last}',
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.slate.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CONFIDENTIAL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 2.0,
                    color: AppTheme.slate.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Clinical Risk Narrative',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              _summarySentence(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: AppTheme.slateSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainColumn(BuildContext context, bool useWideLayout) {
    return Column(
      children: <Widget>[
        _buildScorePanel(context)
            .animate()
            .fadeIn(delay: 80.ms, duration: 420.ms)
            .moveY(begin: 12, end: 0),
        const SizedBox(height: 20),
        if (useWideLayout)
          Expanded(
            child: SingleChildScrollView(
              child: _buildEvidenceGrid(
                context,
              ).animate().fadeIn(delay: 140.ms, duration: 420.ms),
            ),
          )
        else
          _buildEvidenceGrid(context),
      ],
    );
  }

  Widget _buildSideColumn(BuildContext context, bool useWideLayout) {
    return Column(
      children: <Widget>[
        _buildConfidencePanel(
          context,
        ).animate().fadeIn(delay: 200.ms, duration: 420.ms),
        const SizedBox(height: 20),
        if (useWideLayout)
          Expanded(
            child: SingleChildScrollView(
              child: _buildRecommendationPanel(
                context,
              ).animate().fadeIn(delay: 260.ms, duration: 420.ms),
            ),
          )
        else
          _buildRecommendationPanel(context),
      ],
    );
  }

  Widget _buildScorePanel(BuildContext context) {
    final Color riskColor = _riskColor(result.riskScore);

    return ModernGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 720;
          final Widget dial = RepaintBoundary(
            child: SizedBox(
              width: 280,
              height: 220,
              child: CustomPaint(
                painter: _RiskDialPainter(
                  score: result.riskScore,
                  color: riskColor,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          result.riskScore.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 68,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                                fontFeatures: AppTheme.tabularFigures,
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
          );

          final Widget narrative = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildEyebrow(context, 'Instrument Signal'),
              const SizedBox(height: 16),
              Text(
                _riskHeadline(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 22,
                  letterSpacing: -0.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pattern matching score derived from spectral analysis of audio telemetry.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppTheme.slateSoft,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _metricChip(
                    context,
                    icon: LucideIcons.activity,
                    label: 'Clinical Band',
                    value: _riskBand(),
                    accent: riskColor,
                  ),
                  _metricChip(
                    context,
                    icon: LucideIcons.target,
                    label: 'Precision',
                    value: '${(result.probability * 100).toStringAsFixed(1)}%',
                    accent: AppTheme.slateSoft,
                  ),
                ],
              ),
            ],
          );

          if (stacked) {
            return Column(
              children: <Widget>[dial, const SizedBox(height: 16), narrative],
            );
          }

          return Row(
            children: <Widget>[
              dial,
              const SizedBox(width: 32),
              Expanded(child: narrative),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEvidenceGrid(BuildContext context) {
    final List<dynamic> anomalies =
        (result.details['detected_anomalies'] as List<dynamic>?) ?? <dynamic>[];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        _evidenceCard(
          context,
          title: 'Pattern Match',
          value: result.diseaseAssociation.condition,
          body: result.diseaseAssociation.disclaimer,
          icon: LucideIcons.fingerprint,
          accent: AppTheme.respiratoryTeal,
        ),
        _evidenceCard(
          context,
          title: 'Classification',
          value: result.classification,
          body: 'Model output label.',
          icon: LucideIcons.cpu,
          accent: AppTheme.gold,
        ),
        _evidenceCard(
          context,
          title: 'Reference',
          value: result.filename.split('/').last,
          body: 'Analyzed recording.',
          icon: LucideIcons.fileAudio,
          accent: AppTheme.success,
        ),
        _evidenceCard(
          context,
          title: 'Anomalies',
          value: anomalies.isEmpty ? 'None' : anomalies.join(', '),
          body: anomalies.isEmpty
              ? 'No explicit anomalies.'
              : 'Reported markers.',
          icon: LucideIcons.alertTriangle,
          accent: AppTheme.oxide,
        ),
      ],
    );
  }

  Widget _buildConfidencePanel(BuildContext context) {
    final double confidencePercent = result.probability * 100;
    final Color accent = confidencePercent >= 75
        ? AppTheme.success
        : confidencePercent >= 45
        ? AppTheme.gold
        : AppTheme.oxide;

    return ModernGlassCard(
      padding: const EdgeInsets.all(24),
      tint: accent.withValues(alpha: 0.05),
      borderColor: accent.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: AppTheme.slate,
                  fontFeatures: AppTheme.tabularFigures,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.slateMuted,
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
              color: AppTheme.slateSoft,
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: result.probability.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppTheme.frostDeep.withValues(alpha: 0.5),
            color: accent,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPanel(BuildContext context) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildEyebrow(context, 'Clinical Context'),
          const SizedBox(height: 16),
          _noteRow(
            context,
            icon: LucideIcons.stethoscope,
            text: 'Decision support tool only. Not a clinical diagnosis.',
          ),
          const SizedBox(height: 12),
          _noteRow(
            context,
            icon: LucideIcons.shieldAlert,
            text:
                (result.details['medical_disclaimer'] as String?) ??
                'Research prototype. Professional consultation required.',
          ),
          const SizedBox(height: 12),
          _noteRow(
            context,
            icon: LucideIcons.rotateCcw,
            text: 'Repeat analysis if significant ambient noise was present.',
          ),
        ],
      ),
    );
  }

  Widget _metricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppTheme.slate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _evidenceCard(
    BuildContext context, {
    required String title,
    required String value,
    required String body,
    required IconData icon,
    required Color accent,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
      child: ModernGlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 12, color: accent),
                ),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontFeatures: AppTheme.tabularFigures,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppTheme.slateMuted,
              ),
            ),
          ],
        ),
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
          child: Icon(icon, size: 14, color: AppTheme.slateMuted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  Widget _buildEyebrow(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppTheme.slateMuted,
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

  Color _riskColor(double score) {
    if (score >= 7) {
      return AppTheme.oxide;
    }
    if (score >= 4) {
      return AppTheme.gold;
    }
    return AppTheme.success;
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
      ..color = AppTheme.frostDeep;

    final Paint trackInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.frostDeep.withValues(alpha: 0.3);

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
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(rectInner, math.pi, sweep, false, glow);
    canvas.drawArc(rectInner, math.pi, sweep, false, progress);

    // Precision Ticks
    final Paint majorTick = Paint()
      ..color = AppTheme.slate.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    final Paint minorTick = Paint()
      ..color = AppTheme.slate.withValues(alpha: 0.15)
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
      ..color = AppTheme.slate
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
