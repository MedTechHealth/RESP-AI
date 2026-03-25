import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/analysis_result.dart';
import 'package:app/screens/result_screen.dart';

void main() {
  testWidgets('ResultScreen renders correctly', (WidgetTester tester) async {
    // Set a larger viewport to avoid overflows in tests
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

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

    expect(find.text('CLINICAL REVIEW'), findsOneWidget);
    expect(find.text('CLINICAL NARRATIVE'), findsOneWidget);
    expect(find.text('6.5'), findsWidgets);
    expect(find.text('CONDITION: COPD PATTERN'), findsOneWidget);
    expect(find.text('COPD Pattern'), findsOneWidget);
  });
}
