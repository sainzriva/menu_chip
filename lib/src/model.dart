import 'package:flutter/widgets.dart' show Widget;

/// A selectable item for use in [MaterialMenuChip] dropdown menus.
///
/// Each [MenuChipItem] represents one option in the chip's dropdown menu.
/// The [value] is returned when the item is selected, [label] is displayed
/// in the menu, and [avatar] provides an optional leading icon or image.
///
/// ### Example:
/// ```dart
/// MenuChipItem(
///   value: 'home',
///   label: Text('Home'),
///   avatar: Icon(Icons.home),
/// )
/// ```
///
/// See also:
/// - [MaterialMenuChip], which uses this class for menu items.
class MenuChipItem<T> {
  /// The value returned when this item is selected.
  ///
  /// This value is passed to [MaterialMenuChip.onSelectionChanged]
  /// when the user selects this item from the dropdown.
  final T value;

  /// An optional widget displayed before the [label] in the dropdown.
  ///
  /// Typically an [Icon] or [CircleAvatar], but can be any widget.
  /// If not provided, no avatar is shown.
  final Widget? avatar;

  /// The primary widget displayed in the dropdown menu for this item.
  ///
  /// Usually a [Text] widget, but can be any widget tree.
  /// This is the main content users see and interact with.
  final Widget label;

  /// Creates a menu item for [MaterialMenuChip].
  ///
  /// The [value] and [label] must not be null.
  const MenuChipItem({required this.value, this.avatar, required this.label});
}
