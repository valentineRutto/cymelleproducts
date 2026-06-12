import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cymelleproducts/main.dart';

void main() {
  testWidgets('Bottom navigation switches between products and ride tracking', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Products'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);

    await tester.tap(find.text('Ride Tracking'));
    await tester.pump();

    expect(find.text('John Kamau'), findsOneWidget);
    expect(find.text('Toyota Prius'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(find.text('Products'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });
}
