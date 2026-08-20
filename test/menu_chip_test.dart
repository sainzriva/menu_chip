import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_chip/menu_chip.dart';

void main() {
  testWidgets('The chip has a menu', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialMenuChip(
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

    // Tap the chip to open the menu
    await tester.tap(find.byType(FilterChip));
    await tester.pumpAndSettle();

    // Look for menu items
    expect(find.text('ABC'), findsOneWidget);
    expect(find.text('DEF'), findsOneWidget);
  });

  testWidgets('Collapse icon closes menu without clearing selection', (
    WidgetTester tester,
  ) async {
    String? selected = 'abc';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return MaterialMenuChip(
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
                selectedValue: selected,
                onSelectionChanged: (newValue) {
                  setState(() => selected = newValue);
                },
                chipLabel: const Text('test'),
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Selected chip shows the delete icon when the menu is closed
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Open the menu via the chip body
    await tester.tap(find.byType(FilterChip));
    await tester.pumpAndSettle();

    expect(find.text('DEF'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);

    // Pressing the collapse icon should only close the menu
    await tester.tap(find.byIcon(Icons.arrow_drop_up));
    await tester.pumpAndSettle();

    expect(find.text('DEF'), findsNothing);
    expect(selected, 'abc');
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
