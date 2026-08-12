import 'package:flutter_test/flutter_test.dart';

import 'package:gymlife_v2/main.dart';

void main() {
  testWidgets('App boots to the auth slider screen', (tester) async {
    await tester.pumpWidget(const GymLifeApp());

    expect(find.text('GymLife'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
