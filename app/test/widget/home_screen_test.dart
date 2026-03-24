import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'home screen uses the new Instrument Dashboard layout on desktop',
    (tester) async {
      // Desktop size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const ProviderScope(child: RespAIApp()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('RESP-AI'), findsOneWidget);
      expect(find.text('INSTRUMENT DASHBOARD'), findsOneWidget);
      expect(find.text('Respiratory Capture'), findsOneWidget);
      expect(find.text('CLINICAL PROTOCOL'), findsOneWidget);
      expect(find.text('SAMPLE MANAGEMENT'), findsOneWidget);

      // Check that we have a Row for desktop
      expect(find.byType(Row), findsWidgets);
    },
  );

  testWidgets('home screen uses the single column layout on mobile', (
    tester,
  ) async {
    // Mobile size
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const ProviderScope(child: RespAIApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('RESP-AI'), findsOneWidget);
    // INSTRUMENT DASHBOARD is hidden on mobile in my implementation
    expect(find.text('INSTRUMENT DASHBOARD'), findsNothing);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
