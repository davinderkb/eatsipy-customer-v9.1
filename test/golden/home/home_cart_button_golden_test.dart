import 'package:eatsipy_customer/app/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home cart badge golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: RepaintBoundary(
              child: HomeCartButton(isDark: false, count: 7, onTap: () {}),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeCartButton),
      matchesGoldenFile('goldens/home_cart_button.png'),
    );
  });
}
