import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/features/marketplace/screens/marketplace_screen.dart';

void main() {
  testWidgets('Renders MarketplaceScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MarketplaceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}
