import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/holographic_lung.dart';

void main() {
  testWidgets('HolographicLung can be rendered', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HolographicLung(size: 300, isRecording: true, confidence: 0.9),
        ),
      ),
    );

    expect(find.byType(HolographicLung), findsOneWidget);
  });

  testWidgets('HolographicLung renders with disease overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HolographicLung(size: 300, disease: 'Pneumonia')),
      ),
    );

    expect(find.byType(HolographicLung), findsOneWidget);
  });
}
