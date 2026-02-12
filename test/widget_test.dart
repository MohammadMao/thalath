// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thalath/app.dart';

void main() {
  testWidgets('Home page displays Thalath title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ThalathApp());

    // Verify that the home page displays the title and button.
    expect(find.text('ثلاث'), findsWidgets);
    expect(find.text('Thalath'), findsOneWidget);
    expect(find.text('Start Playing'), findsOneWidget);
  });
}
