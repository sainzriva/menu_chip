A Flutter filter chip with a built-in dropdown menu for single-value selection.

`MaterialMenuChip` opens a Material 3 menu from a chip, shows the current selection, and lets users clear it—ideal for compact filters in toolbars, search bars, and list headers.

`CupertinoMenuChip` follows Apple's Human Interface Guidelines as a pop-up button: the control shows the current selection (or a placeholder) and opens a mutually exclusive pull-down menu.

Requires Flutter ≥3.44. Material widgets use the standalone [`material_ui`](https://pub.dev/packages/material_ui) package (pulled in transitively); host apps should use `material_ui`'s `MaterialApp` / theme, or wrap legacy Material subtrees with `MaterialUiCompatibilityBridge`. Cupertino widgets use [`cupertino_ui`](https://pub.dev/packages/cupertino_ui).

[![Pub Version](https://img.shields.io/pub/v/menu_chip.svg)](https://pub.dev/packages/menu_chip)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://pub.dev/packages/menu_chip/license)
![GitHub open issues](https://img.shields.io/github/issues-raw/sainzriva/menu_chip)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)](https://flutter.dev)

## Features

- Filter chip that anchors a Material 3 dropdown menu (`MaterialMenuChip`)
- Cupertino pop-up button that follows Apple HIG (`CupertinoMenuChip`)
- Typed single selection with optional clear
- Customizable chip and menu styles (`MaterialChipStyle`, `MaterialPopupMenuStyle`, `CupertinoChipStyle`, `CupertinoPopupMenuStyle`)
- Leading avatars on the chip and menu items; Cupertino items can also use `CupertinoMenuChipItem` for subtitle, trailing, and destructive rows
- Built on [`material_ui`](https://pub.dev/packages/material_ui) and [`cupertino_ui`](https://pub.dev/packages/cupertino_ui)
- RTL support out of the box

<table>
  <tr>
    <td align="center" valign="top">
      <strong>Material menu chip</strong><br>
      <img src="https://raw.githubusercontent.com/sainzriva/menu_chip/main/assets/demo_material.gif" height="320" alt="Material menu chip">
    </td>
    <td align="center" valign="top">
      <strong>Cupertino menu chip</strong><br>
      <img src="https://raw.githubusercontent.com/sainzriva/menu_chip/main/assets/demo_cupertino.gif" height="320" alt="Cupertino menu chip">
    </td>
  </tr>
</table>

Based on [Material Design 3](https://m3.material.io/components/chips/guidelines) and [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/pop-up-buttons)

## Getting started

To add the menu_chip to your Flutter application follow the [installation instructions](https://pub.dev/packages/menu_chip/install) on pub.dev

## Usage

Material menu chip:
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

Cupertino menu chip:
```dart
String? selection;

CupertinoMenuChip(
  chipLabel: Text('Sort by'),
  selectedValue: selection,
  onSelectionChanged: (newValue) {
    setState(() => selection = newValue);
  },
  menuItemsList: const [
    CupertinoMenuChipItem(
      value: 'name',
      label: Text('Name'),
    ),
    CupertinoMenuChipItem(
      value: 'date',
      label: Text('Date'),
    ),
    CupertinoMenuChipItem(
      value: 'size',
      label: Text('Size'),
    ),
  ],
);
```
