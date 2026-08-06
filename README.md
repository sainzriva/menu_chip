A Flutter filter chip with a built-in dropdown menu for single-value selection.

`MaterialMenuChip` opens a Material 3 menu from a chip, shows the current selection, and lets users clear it—ideal for compact filters in toolbars, search bars, and list headers.

[![Pub Version](https://img.shields.io/pub/v/menu_chip.svg)](https://pub.dev/packages/menu_chip)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://pub.dev/packages/menu_chip/license)
![GitHub open issues](https://img.shields.io/github/issues-raw/sainzriva/menu_chip)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)](https://flutter.dev)

## Features

- Filter chip that anchors a Material 3 dropdown menu
- Typed single selection with optional clear
- Customizable chip and menu styles (`MaterialChipStyle`, `MaterialPopupMenuStyle`)
- Leading avatars on the chip and menu items
- Zero dependencies beyond the Flutter SDK
- RTL support out of the box

<img src="https://raw.githubusercontent.com/sainzriva/menu_chip/main/assets/demo.gif" width="200" alt="Menu Chip Demo">

Based on [Material Design 3](https://m3.material.io/components/chips/guidelines)

## Getting started

To add the menu_chip to your Flutter application follow the [installation instructions](https://pub.dev/packages/menu_chip/install) on pub.dev

## Usage

```dart
String? selection;

MaterialMenuChip(
  chipLabel: Text('Sort by'),
  selectedValue: selection,
  onSelectionChanged: (newValue) {
    setState(() => selection = newValue);
  },
  menuItemsList: const [
    MenuChipItem(
      value: 'name',
      label: Text('Name'),
      avatar: Icon(Icons.sort_by_alpha),
    ),
    MenuChipItem(
      value: 'date',
      label: Text('Date'),
      avatar: Icon(Icons.calendar_today),
    ),
    MenuChipItem(
      value: 'size',
      label: Text('Size'),
      avatar: Icon(Icons.straighten),
    ),
  ],
);
```
