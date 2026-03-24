import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/modern_glass_card.dart';

void main() {
  testWidgets('ModernGlassCard has BackdropFilter and 0.5px border', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModernGlassCard(
            child: const Text('Glass Card'),
          ),
        ),
      ),
    );

    // Verify BackdropFilter exists
    expect(find.byType(BackdropFilter), findsOneWidget);

    // Verify border width 0.5px
    final Container container = tester.widget(find.descendant(
      of: find.byType(ModernGlassCard),
      matching: find.byType(Container),
    ));
    final BoxDecoration decoration = container.decoration as BoxDecoration;
    final Border border = decoration.border as Border;
    expect(border.top.width, 0.5);
  });
}
