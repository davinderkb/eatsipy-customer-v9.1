import 'package:eatsipy_customer/app/home_screen/home_screen.dart';
import 'package:eatsipy_customer/themes/app_them_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  testWidgets('home cart badge is hidden at zero', (tester) async {
    await tester.pumpWidget(
        wrap(HomeCartButton(isDark: false, count: 0, onTap: () {})));

    expect(find.byKey(const ValueKey('home-cart-badge')), findsNothing);
  });

  testWidgets(
      'home cart badge shows count and uses cartBadge color without overlapping button bounds',
      (tester) async {
    await tester.pumpWidget(
        wrap(HomeCartButton(isDark: false, count: 3, onTap: () {})));

    final badgeFinder = find.byKey(const ValueKey('home-cart-badge'));
    expect(badgeFinder, findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    final badge = tester.widget<Container>(badgeFinder);
    final decoration = badge.decoration! as BoxDecoration;
    expect(decoration.color, AppThemeData.cartBadge);

    final buttonRect = tester.getRect(find.byType(HomeCartButton));
    final badgeRect = tester.getRect(badgeFinder);
    expect(badgeRect.left, greaterThanOrEqualTo(buttonRect.left));
    expect(badgeRect.top, lessThan(buttonRect.top + 4));
    expect(badgeRect.right, greaterThan(buttonRect.right - 4));
  });
}
