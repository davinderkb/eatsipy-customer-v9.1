import 'package:eatsipy_customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'faded item description uses ShaderMask and clips instead of ellipsis',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FadedItemDescription(
            text:
                'A long dish description that should fade at the end instead of using dots.',
            isDark: false,
          ),
        ),
      ),
    );

    expect(find.byType(ShaderMask), findsOneWidget);
    final text =
        tester.widget<Text>(find.textContaining('long dish description'));
    expect(text.maxLines, 2);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
  });
}
