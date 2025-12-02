import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_chip/menu_chip.dart';

void main() {
  testWidgets('The chip has a menu', (WidgetTester tester) async {
    final key = GlobalKey<PopupMenuButtonState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialMenuChip(
            menuKey: key,
            menuItemsList: const [
              MenuChipItem(
                value: 'abc',
                avatar: Icon(Icons.abc),
                label: Text('ABC'),
              ),
              MenuChipItem(
                value: 'def',
                avatar: Icon(Icons.abc),
                label: Text('DEF'),
              ),
            ],
            selectedValue: null,
            onSelectionChanged: (newValue) {},
            chipLabel: const Text('test'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify chip is visible
    expect(find.text('test'), findsOneWidget);

    // Find and tap the PopupMenuButton
    final popupButtonFinder = find.byKey(key);
    expect(popupButtonFinder, findsOneWidget);

    // Open the menu
    await tester.tap(popupButtonFinder);

    // Wait for menu animation to complete
    await tester.pumpAndSettle();

    // Look for menu items
    expect(find.text('ABC'), findsOneWidget);
    expect(find.text('DEF'), findsOneWidget);
  });
}
