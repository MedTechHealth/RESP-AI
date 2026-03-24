import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/theme/app_theme.dart';

void main() {
  test('AppTheme has correct color constants', () {
    expect(AppTheme.slate, const Color(0xFF0F172A));
    expect(AppTheme.frost, const Color(0xFFF5F7FA));
  });

  test('AppTheme has tabular figures font feature', () {
    expect(AppTheme.tabularFigures, contains(const FontFeature.tabularFigures()));
  });
}
