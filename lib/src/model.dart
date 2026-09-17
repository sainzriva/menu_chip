import 'package:flutter/widgets.dart' show Widget;

/// A selectable item for use in [MaterialMenuChip] and [CupertinoMenuChip]
/// dropdown menus.
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
/// - [CupertinoMenuChip], which uses this class or [CupertinoMenuChipItem].
/// - [CupertinoMenuChipItem], for Cupertino-only row fields.
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

  /// Creates a menu item for [MaterialMenuChip] and [CupertinoMenuChip].
  ///
  /// The [value] and [label] must not be null.
  const MenuChipItem({required this.value, this.avatar, required this.label});
}

/// A [MenuChipItem] with Cupertino-only row fields.
///
/// [CupertinoMenuChip] reads [subtitle], [trailing], and
/// [isDestructiveAction]. [MaterialMenuChip] treats this as a normal
/// [MenuChipItem] and ignores those fields.
class CupertinoMenuChipItem<T> extends MenuChipItem<T> {
  /// An optional widget displayed underneath the [label].
  ///
  /// Mapped to [CupertinoMenuItem.subtitle].
  final Widget? subtitle;

  /// An optional widget displayed after the [label].
  ///
  /// Mapped to [CupertinoMenuItem.trailing]. If null,
  /// [CupertinoPopupMenuStyle.itemTrailing] is used when set.
  final Widget? trailing;

  /// Whether selecting this item performs a destructive action.
  ///
  /// Mapped to [CupertinoMenuItem.isDestructiveAction].
  final bool isDestructiveAction;

  /// Creates a Cupertino menu item.
  // Super parameters hide the generic `T` as InvalidType in constructor hover.
  // ignore: use_super_parameters
  const CupertinoMenuChipItem({
    required T value,
    Widget? avatar,
    required Widget label,
    this.subtitle,
    this.trailing,
    this.isDestructiveAction = false,
  }) : super(value: value, avatar: avatar, label: label);
}
