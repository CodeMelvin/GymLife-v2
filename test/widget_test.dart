import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymlife_v2/main.dart';

void main() {
  testWidgets('App boots to the auth slider screen', (tester) async {
    await tester.pumpWidget(const GymLifeApp());

    expect(find.byType(CircleAvatar), findsWidgets);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text("Don't have an account? Register here"), findsOneWidget);
  });
}
