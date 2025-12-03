import 'package:flutter/material.dart';
import 'package:menu_chip/menu_chip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'menu_chip test', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _modeAvatar = Icon(Icons.directions);
  static const _modeLabel = Text('Mode');
  static const _modesList = [
    MenuChipItem(
      value: 'run',
      avatar: Icon(Icons.directions_run),
      label: Text('Running'),
    ),
    MenuChipItem(
      value: 'walk',
      avatar: Icon(Icons.directions_walk),
      label: Text('Walking'),
    ),
    MenuChipItem(
      value: 'hike',
      avatar: Icon(Icons.hiking),
      label: Text('Hiking'),
    ),
    MenuChipItem(
      value: 'cycle',
      avatar: Icon(Icons.directions_bike),
      label: Text('Cycling'),
    ),
  ];

  final _menuKey0 = GlobalKey<PopupMenuButtonState>(),
      _menuKey1 = GlobalKey<PopupMenuButtonState>(),
      _menuKey2 = GlobalKey<PopupMenuButtonState>();

  String? _chip0, _chip1 = _modesList.first.value, _chip2;

  @override
  Widget build(BuildContext context) {
    // Example of a default menu chip
    Widget defaultMenuChip() {
      return MaterialMenuChip(
        menuKey: _menuKey0,
        menuItemsList: _modesList,
        selectedValue: _chip0,
        onSelectionChanged: (newValue) {
          setState(() => _chip0 = newValue);
        },
        chipAvatar: _modeAvatar,
        chipLabel: _modeLabel,
      );
    }

    // Example of a menu chip with no checkmark and remove icon
    Widget noCheckmarkMenuChip() {
      return MaterialMenuChip(
        menuKey: _menuKey1,
        menuItemsList: _modesList,
        selectedValue: _chip1,
        onSelectionChanged: (newValue) {
          final String? update = newValue == _chip1 ? null : newValue;
          setState(() => _chip1 = update);
        },
        chipAvatar: _modeAvatar,
        chipLabel: _modeLabel,
        chipStyle: const MaterialChipStyle(
          showDeleteIcon: false,
          showCheckmark: false,
        ),
      );
    }

    // Example of a custom menu chip
    Widget customMenuChip() {
      return MaterialMenuChip(
        menuKey: _menuKey2,
        menuItemsList: _modesList,
        selectedValue: _chip2,
        onSelectionChanged: (newValue) {
          setState(() => _chip2 = newValue);
        },
        chipAvatar: _modeAvatar,
        chipLabel: _modeLabel,
        chipStyle: const MaterialChipStyle(
          labelStyle: TextStyle(fontStyle: FontStyle.italic),
          selectedLabelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          deleteIcon: Icon(Icons.delete),
          deleteIconColor: Colors.brown,
          selectedColor: Colors.blue,
          backgroundColor: Colors.lime,
          checkmarkColor: Colors.yellowAccent,
        ),
        menuStyle: const MaterialPopupMenuStyle(offset: Offset(-5, 15)),
      );
    }

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [defaultMenuChip(), noCheckmarkMenuChip(), customMenuChip()],
      ),
    );
  }
}
