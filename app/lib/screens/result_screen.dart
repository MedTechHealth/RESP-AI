import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math' as math;
import '../models/analysis_result.dart';
import '../widgets/modern_glass_card.dart';
import '../widgets/mesh_background.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('DIAGNOSTIC ANALYSIS'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MeshBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _buildTopInfo(),
                    const SizedBox(height: 32),
                    _buildMainScoreCard(context),
                    const SizedBox(height: 32),
                    _buildBentoGrid(context),
                    const SizedBox(height: 48),
                    _buildDisclaimer(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIGNAL REFERENCE: ${math.Random().nextInt(99999).toString().padLeft(5, '0')}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Biometric Analysis Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentCyan.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.lock,
                size: 12,
                color: AppTheme.accentCyan,
              ),
              const SizedBox(width: 8),
              const Text(
                'SECURE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accentCyan,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildMainScoreCard(BuildContext context) {
    final color = _getRiskColor(result.riskScore);

    return ModernGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Text(
            'RESPIRATORY RISK LEVEL',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 2.0,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 140,
                    child: CustomPaint(
                      painter: PremiumGaugePainter(
                        score: result.riskScore,
                        color: color,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Column(
                      children: [
                        Text(
                          result.riskScore.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 64,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.classification.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: color,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 1000.ms)
              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
          const SizedBox(height: 48),
          _buildPriorityIndicator(color),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.activity, color: color, size: 18),
          const SizedBox(width: 14),
          Text(
            'Inference Confidence: ${(result.probability * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildBentoGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: _buildPatternCard()),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _buildMetricTile(
                'ALGORITHM',
                result.classification,
                LucideIcons.cpu,
                AppTheme.primaryIndigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                'CONFIDENCE',
                result.diseaseAssociation.confidence,
                LucideIcons.barChart,
                AppTheme.accentCyan,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMetricTile(
                'FILE CLASS',
                'PCM-16',
                LucideIcons.activity,
                AppTheme.accentEmerald,
              ),
            ),
          ],
        ),
        if ((result.details['detected_anomalies'] as List? ?? [])
            .isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildAnomaliesCard(),
        ],
      ],
    ).animate().fadeIn(delay: 600.ms).moveY(begin: 30, end: 0);
  }

  Widget _buildPatternCard() {
    final condition = result.diseaseAssociation.condition.toLowerCase();
    final isNormal =
        condition.contains('normal') || condition.contains('healthy');
    final color = isNormal ? AppTheme.accentEmerald : AppTheme.primaryIndigo;

    return ModernGlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fingerprint, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                'PATTERN MATCH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            result.diseaseAssociation.condition,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.diseaseAssociation.disclaimer,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppTheme.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliesCard() {
    final anomalies = result.details['detected_anomalies'] as List? ?? [];

    return ModernGlassCard(
      padding: const EdgeInsets.all(28),
      color: AppTheme.errorRose.withOpacity(0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                size: 16,
                color: AppTheme.errorRose,
              ),
              const SizedBox(width: 8),
              const Text(
                'ACOUSTIC ANOMALIES IDENTIFIED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.errorRose,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: anomalies
                .map(
                  (a) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.errorRose.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      a.toString().toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.errorRose,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Column(
      children: [
        const Icon(
          LucideIcons.shieldAlert,
          size: 28,
          color: AppTheme.textTertiary,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            result.details['medical_disclaimer'] ?? 'Research prototype only.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms);
  }

  Color _getRiskColor(double score) {
    if (score >= 7) return AppTheme.errorRose;
    if (score >= 4) return AppTheme.warningAmber;
    return AppTheme.accentEmerald;
  }
}

class PremiumGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  PremiumGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width / 2, size.height);
    final center = Offset(size.width / 2, size.height);

    final trackPaint = Paint()
      ..color = AppTheme.borderMedium.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final rect = Rect.fromCircle(center: center, radius: radius - 15);

    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);

    final tickPaint = Paint()
      ..color = AppTheme.textTertiary.withOpacity(0.3)
      ..strokeWidth = 2;
    for (int i = 0; i <= 10; i++) {
      double angle = math.pi + (i / 10) * math.pi;
      Offset p1 =
          center +
          Offset(
            math.cos(angle) * (radius - 30),
            math.sin(angle) * (radius - 30),
          );
      Offset p2 =
          center +
          Offset(
            math.cos(angle) * (radius - 40),
            math.sin(angle) * (radius - 40),
          );
      canvas.drawLine(p1, p2, tickPaint);
    }

    canvas.drawArc(
      rect,
      math.pi,
      math.pi * (math.min(score, 10.0) / 10),
      false,
      shadowPaint,
    );
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * (math.min(score, 10.0) / 10),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
