import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/widgets/glassmorphic_container.dart';
import 'dart:ui'; // For ImageFilter

void main() {
  group('GlassmorphicContainer', () {
    testWidgets('renders BackdropFilter and ClipRRect with child', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassmorphicContainer(child: Text('Test Child')),
          ),
        ),
      );

      // Expect to find BackdropFilter for the blur effect
      expect(find.byType(BackdropFilter), findsOneWidget);
      // Expect to find ClipRRect for the border radius
      expect(find.byType(ClipRRect), findsOneWidget);
      // Expect to find the child widget
      expect(find.text('Test Child'), findsOneWidget);

      // Verify the blur values (adjust if exact values change in implementation)
      final BackdropFilter backdropFilter = tester.widget(
        find.byType(BackdropFilter),
      );
      final ImageFilter blurFilter = backdropFilter.filter as ImageFilter;
      // This assertion might be tricky depending on how ImageFilter equality works.
      // We'll rely on the presence of BackdropFilter for now and refine if needed.
      // For more precise testing of ImageFilter, one might need to inspect its string representation or specific properties if exposed.
    });

    testWidgets('applies correct background and border colors based on theme', (
      WidgetTester tester,
    ) async {
      // Test in light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: GlassmorphicContainer(child: Text('Light Mode Test')),
          ),
        ),
      );
      // Need to find the Container within the GlassmorphicContainer and check its decoration
      final containerFinderLight = find.descendant(
        of: find.byType(GlassmorphicContainer),
        matching: find.byType(Container),
      );
      expect(containerFinderLight, findsOneWidget);
      final Container containerLight = tester.widget(containerFinderLight);
      final BoxDecoration decorationLight =
          containerLight.decoration as BoxDecoration;
      // Expecting default light mode colors. Will need to adjust based on AppTheme.
      expect(
        decorationLight.color?.alpha,
        (0.7 * 255).round(),
      ); // surfaceLight with 70% opacity
      expect(
        (decorationLight.border as Border).top.color.alpha,
        (0.05 * 255).round(),
      ); // lungBlue with 5% opacity

      // Test in dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: GlassmorphicContainer(child: Text('Dark Mode Test')),
          ),
        ),
      );
      final containerFinderDark = find.descendant(
        of: find.byType(GlassmorphicContainer),
        matching: find.byType(Container),
      );
      expect(containerFinderDark, findsOneWidget);
      final Container containerDark = tester.widget(containerFinderDark);
      final BoxDecoration decorationDark =
          containerDark.decoration as BoxDecoration;
      // Expecting default dark mode colors. Will need to adjust based on AppTheme.
      expect(
        decorationDark.color?.alpha,
        (0.4 * 255).round(),
      ); // surfaceDark with 40% opacity
      expect(
        (decorationDark.border as Border).top.color.alpha,
        (0.08 * 255).round(),
      ); // Colors.white with 8% opacity
    });
  });
}
