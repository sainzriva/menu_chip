import 'package:material_ui/material_ui.dart';
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

  String? _defaultChip;
  String? _cupertinoChip;
  String? _noCheckmarkChip = _modesList.first.value;
  String? _customChip;

  @override
  Widget build(BuildContext context) {
    // Example of a default Material menu chip
    Widget defaultMaterialMenuChip() {
      return MaterialMenuChip(
        menuItemsList: _modesList,
        selectedValue: _defaultChip,
        onSelectionChanged: (newValue) {
          setState(() => _defaultChip = newValue);
        },
        chipAvatar: _modeAvatar,
        chipLabel: _modeLabel,
      );
    }

    // Example of a default Cupertino menu chip
    Widget defaultCupertinoMenuChip() {
      return CupertinoMenuChip(
        menuItemsList: _modesList,
        selectedValue: _cupertinoChip,
        onSelectionChanged: (newValue) {
          setState(() => _cupertinoChip = newValue);
        },
        chipAvatar: _modeAvatar,
        chipLabel: _modeLabel,
      );
    }

    // Example of a menu chip with no checkmark and remove icon
    Widget noCheckmarkMenuChip() {
      return MaterialMenuChip(
        menuItemsList: _modesList,
        selectedValue: _noCheckmarkChip,
        onSelectionChanged: (newValue) {
          setState(() => _noCheckmarkChip = newValue);
        },
        enableUnselect: true,
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
        menuItemsList: _modesList,
        selectedValue: _customChip,
        onSelectionChanged: (newValue) {
          setState(() => _customChip = newValue);
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
        children: [
          defaultMaterialMenuChip(),
          defaultCupertinoMenuChip(),
          noCheckmarkMenuChip(),
          customMenuChip(),
        ],
      ),
    );
  }
}
