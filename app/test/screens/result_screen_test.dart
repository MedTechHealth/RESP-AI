import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/analysis_result.dart';
import 'package:app/screens/result_screen.dart';

void main() {
  testWidgets('ResultScreen renders correctly', (WidgetTester tester) async {
    final result = AnalysisResult(
      filename: 'test_audio.wav',
      riskScore: 6.5,
      probability: 0.82,
      classification: 'Moderate Variance',
      diseaseAssociation: DiseaseAssociation(
        condition: 'COPD Pattern',
        confidence: 'High',
        disclaimer: 'For educational use only.',
      ),
      details: {
        'detected_anomalies': ['Wheeze', 'Crackles'],
        'medical_disclaimer': 'Clinical prototype only.',
      },
    );

    await tester.pumpWidget(MaterialApp(home: ResultScreen(result: result)));
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // Give animations some time

    expect(find.text('Clinical Review'), findsOneWidget);
    expect(find.text('Clinical Risk Narrative'), findsOneWidget);
    expect(find.text('6.5'), findsOneWidget);
    expect(find.text('MODERATE VARIANCE'), findsOneWidget);
    expect(find.text('COPD Pattern'), findsOneWidget);
  });
}
