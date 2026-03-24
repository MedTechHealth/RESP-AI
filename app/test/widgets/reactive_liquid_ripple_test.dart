import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/reactive_liquid_ripple.dart';

void main() {
  testWidgets('ReactiveLiquidRipple renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ReactiveLiquidRipple(
              size: 260,
              color: Colors.blue,
              amplitude: 1.0,
              isAnimating: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ReactiveLiquidRipple), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ReactiveLiquidRipple),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });
}
