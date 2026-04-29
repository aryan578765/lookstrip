import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookstrip/main.dart';

void main() {
  testWidgets('LooksTrip shows configuration gate before splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LooksTripApp()));

    expect(find.text('Configuration needs attention'), findsOneWidget);
    expect(find.text('Continue in offline mode'), findsOneWidget);

    await tester.tap(find.text('Continue in offline mode'));
    await tester.pump();

    expect(find.text('LooksTrip'), findsOneWidget);
    expect(find.text('AI-Powered Travel'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
