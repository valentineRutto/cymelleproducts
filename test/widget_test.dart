import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cymelleproducts/main.dart';

void main() {
  testWidgets('Product app renders shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Shop'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });
}
