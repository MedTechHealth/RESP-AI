import 'package:app/main.dart';
import 'package:app/models/analysis_result.dart';
import 'package:app/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home screen exposes the new respiratory intake UI', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const ProviderScope(child: RespAIApp()));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Respiratory Capture'), findsOneWidget);
    expect(find.text('START CAPTURE'), findsOneWidget);
    expect(find.text('IMPORT'), findsOneWidget);
  });

  testWidgets('result screen exposes the new risk overview narrative', (
    tester,
  ) async {
    final result = AnalysisResult(
      filename: 'sample.wav',
      riskScore: 6.8,
      probability: 0.87,
      classification: 'Elevated risk',
      diseaseAssociation: DiseaseAssociation(
        condition: 'Asthma pattern',
        confidence: 'High',
        disclaimer: 'Prototype support only.',
      ),
      details: <String, dynamic>{
        'detected_anomalies': <String>['wheeze', 'coarse crackle'],
        'medical_disclaimer': 'Not a medical diagnosis.',
      },
    );

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(MaterialApp(home: ResultScreen(result: result)));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Clinical Risk Narrative'), findsOneWidget);
    expect(find.text('CLASSIFICATION CONFIDENCE'), findsOneWidget);
    expect(find.text('Prototype support only.'), findsOneWidget);
  });
}
