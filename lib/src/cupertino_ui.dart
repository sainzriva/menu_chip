import 'dart:ui' show Color, Size, VoidCallback;

import 'package:flutter/foundation.dart' show ValueChanged;
import 'package:flutter/painting.dart'
    show
        Alignment,
        AlignmentGeometry,
        BorderRadius,
        BoxDecoration,
        EdgeInsets,
        EdgeInsetsGeometry;
import 'package:flutter/rendering.dart'
    show BoxConstraints, HitTestBehavior, MouseCursor;
import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Flexible,
        FocusNode,
        Icon,
        MainAxisSize,
        MenuController,
        Row,
        SizedBox,
        StatelessWidget,
        Widget,
        WidgetStateProperty;
import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoButton,
        CupertinoButtonSize,
        CupertinoColors,
        CupertinoIcons,
        CupertinoMenuAnchor,
        CupertinoMenuAnimationStatusChangedCallback,
        CupertinoMenuItem;

import '../src/model.dart' show CupertinoMenuChipItem, MenuChipItem;

/// Which [CupertinoButton] constructor [CupertinoMenuChip] should use.
enum CupertinoMenuChipButtonVariant {
  /// [CupertinoButton] with no filled background.
  plain,

  /// [CupertinoButton.tinted].
  tinted,

  /// [CupertinoButton.filled].
  filled,
}

/// A Cupertino-style selection button with a pull-down menu.
///
/// Follows the Apple HIG pop-up button pattern: the button shows the current
/// selection (or [chipLabel] as a placeholder) with a chevron. Tapping it
/// opens a menu of mutually exclusive options; choosing one closes the menu
/// and reports the value via [onSelectionChanged]. The selected menu row
/// shows a leading checkmark. Tapping that row again does not clear the
/// selection unless [enableUnselect] is true.
///
/// Appearance is customized with [chipStyle] and [menuStyle].
///
/// ### Example:
/// ```dart
/// import 'package:menu_chip/menu_chip.dart';
///
/// String? _value;
///
/// CupertinoMenuChip<String>(
///   menuItemsList: [
///     MenuChipItem(value: 'run', label: Text('Running')),
///     MenuChipItem(value: 'walk', label: Text('Walking')),
///   ],
///   selectedValue: _value,
///   onSelectionChanged: (value) => setState(() => _value = value),
///   chipLabel: Text('Mode'),
/// );
/// ```
///
/// See also:
/// - [MenuChipItem], which defines individual menu items.
/// - [CupertinoMenuChipItem], for subtitle, trailing, and destructive rows.
/// - [CupertinoChipStyle], for customizing the button.
/// - [CupertinoPopupMenuStyle], for customizing the menu.
class CupertinoMenuChip<T> extends StatelessWidget {
  /// The list of selectable items to display in the menu.
  ///
  /// The list must not be empty.
  final List<MenuChipItem<T>> menuItemsList;

  /// The currently selected value, or `null` if no selection.
  ///
  /// When set, the button shows the matching item's label and that menu row
  /// shows a checkmark. Otherwise the button shows [chipLabel].
  final T? selectedValue;

  /// Called with the selected [MenuChipItem.value] when the user picks a row.
  ///
  /// Called with `null` when [enableUnselect] is true and the user taps the
  /// currently selected row.
  final ValueChanged<T?> onSelectionChanged;

  /// An optional widget displayed on the left side of the button when nothing
  /// is selected, or when the selected item has no [MenuChipItem.avatar].
  final Widget? chipAvatar;

  /// Placeholder shown on the button when [selectedValue] is `null`.
  final Widget chipLabel;

  /// Whether the button is interactive. Defaults to true.
  final bool isChipEnabled;

  /// Whether tapping the currently selected menu item clears the selection.
  ///
  /// Defaults to false, matching the HIG pop-up button pattern. When true,
  /// choosing the checked row calls [onSelectionChanged] with `null`.
  final bool enableUnselect;

  /// Customization options for the button's appearance.
  ///
  /// If `null`, default Cupertino button styles are used.
  final CupertinoChipStyle? chipStyle;

  /// Customization options for the dropdown menu.
  ///
  /// If `null`, default Cupertino menu styles are used.
  final CupertinoPopupMenuStyle? menuStyle;

  /// Creates a Cupertino selection button with a pull-down menu.
  const CupertinoMenuChip({
    super.key,
    required this.menuItemsList,
    this.selectedValue,
    required this.onSelectionChanged,
    this.chipAvatar,
    required this.chipLabel,
    this.isChipEnabled = true,
    this.enableUnselect = false,
    this.chipStyle,
    this.menuStyle,
  });

  @override
  Widget build(BuildContext context) {
    MenuChipItem<T>? selectedItem;
    if (selectedValue != null) {
      for (final item in menuItemsList) {
        if (item.value == selectedValue) {
          selectedItem = item;
          break;
        }
      }
      selectedItem ??= menuItemsList.first;
    }

    final CupertinoPopupMenuStyle? style = menuStyle;
    final CupertinoChipStyle? buttonStyle = chipStyle;

    return CupertinoMenuAnchor(
      onOpen: style?.onOpen,
      onClose: style?.onClose,
      onAnimationStatusChanged: style?.onAnimationStatusChanged,
      constraints: style?.constraints,
      constrainCrossAxis: style?.constrainCrossAxis ?? false,
      consumeOutsideTaps: style?.consumeOutsideTaps ?? false,
      enableSwipe: style?.enableSwipe ?? true,
      enableLongPressToOpen: style?.enableLongPressToOpen ?? false,
      useRootOverlay: style?.useRootOverlay ?? false,
      overlayPadding: style?.overlayPadding ?? const EdgeInsets.all(8),
      childFocusNode: style?.childFocusNode,
      menuChildren: [
        for (final item in menuItemsList)
          CupertinoMenuItem(
            leading: item.value == selectedValue
                ? const Icon(CupertinoIcons.checkmark)
                : item.avatar,
            subtitle: item is CupertinoMenuChipItem<T> ? item.subtitle : null,
            trailing: item is CupertinoMenuChipItem<T>
                ? item.trailing ?? style?.itemTrailing
                : style?.itemTrailing,
            leadingWidth: style?.leadingWidth,
            leadingMidpointAlignment: style?.leadingMidpointAlignment,
            trailingWidth: style?.trailingWidth,
            trailingMidpointAlignment: style?.trailingMidpointAlignment,
            padding: style?.itemPadding,
            constraints: style?.itemConstraints,
            autofocus: style?.itemAutofocus ?? false,
            onFocusChange: style?.itemOnFocusChange,
            onHover: style?.itemOnHover,
            decoration: style?.itemDecoration,
            mouseCursor: style?.itemMouseCursor,
            behavior: style?.itemBehavior ?? HitTestBehavior.opaque,
            requestCloseOnActivate: style?.requestCloseOnActivate ?? true,
            requestFocusOnHover: style?.requestFocusOnHover ?? true,
            isDestructiveAction: item is CupertinoMenuChipItem<T>
                ? item.isDestructiveAction
                : false,
            onPressed: () {
              if (enableUnselect && item.value == selectedValue) {
                onSelectionChanged(null);
              } else {
                onSelectionChanged(item.value);
              }
            },
            child: item.label,
          ),
      ],
      builder: (_, MenuController controller, _) {
        final Widget? leadingAvatar = selectedItem?.avatar ?? chipAvatar;
        final Widget child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingAvatar != null) ...[
              leadingAvatar,
              const SizedBox(width: 4),
            ],
            Flexible(child: selectedItem?.label ?? chipLabel),
            const SizedBox(width: 4),
            buttonStyle?.expandIcon ??
                const Icon(CupertinoIcons.chevron_up_chevron_down, size: 14),
          ],
        );

        final VoidCallback? onPressed = isChipEnabled
            ? () => controller.isOpen ? controller.close() : controller.open()
            : null;

        return switch (buttonStyle?.variant ??
            CupertinoMenuChipButtonVariant.plain) {
          CupertinoMenuChipButtonVariant.tinted => CupertinoButton.tinted(
            sizeStyle: buttonStyle?.sizeStyle ?? CupertinoButtonSize.large,
            padding: buttonStyle?.padding,
            color: buttonStyle?.color,
            foregroundColor: buttonStyle?.foregroundColor,
            disabledColor:
                buttonStyle?.disabledColor ??
                CupertinoColors.tertiarySystemFill,
            minimumSize: buttonStyle?.minimumSize,
            pressedOpacity: buttonStyle?.pressedOpacity ?? 0.4,
            borderRadius: buttonStyle?.borderRadius,
            alignment: buttonStyle?.alignment ?? Alignment.center,
            focusColor: buttonStyle?.focusColor,
            focusNode: buttonStyle?.focusNode,
            onFocusChange: buttonStyle?.onFocusChange,
            autofocus: buttonStyle?.autofocus ?? false,
            mouseCursor: buttonStyle?.mouseCursor,
            onLongPress: buttonStyle?.onLongPress,
            onPressed: onPressed,
            child: child,
          ),
          CupertinoMenuChipButtonVariant.filled => CupertinoButton.filled(
            sizeStyle: buttonStyle?.sizeStyle ?? CupertinoButtonSize.large,
            padding: buttonStyle?.padding,
            color: buttonStyle?.color,
            foregroundColor: buttonStyle?.foregroundColor,
            disabledColor:
                buttonStyle?.disabledColor ??
                CupertinoColors.tertiarySystemFill,
            minimumSize: buttonStyle?.minimumSize,
            pressedOpacity: buttonStyle?.pressedOpacity ?? 0.4,
            borderRadius: buttonStyle?.borderRadius,
            alignment: buttonStyle?.alignment ?? Alignment.center,
            focusColor: buttonStyle?.focusColor,
            focusNode: buttonStyle?.focusNode,
            onFocusChange: buttonStyle?.onFocusChange,
            autofocus: buttonStyle?.autofocus ?? false,
            mouseCursor: buttonStyle?.mouseCursor,
            onLongPress: buttonStyle?.onLongPress,
            onPressed: onPressed,
            child: child,
          ),
          CupertinoMenuChipButtonVariant.plain => CupertinoButton(
            sizeStyle: buttonStyle?.sizeStyle ?? CupertinoButtonSize.large,
            padding: buttonStyle?.padding,
            color: buttonStyle?.color,
            foregroundColor: buttonStyle?.foregroundColor,
            disabledColor:
                buttonStyle?.disabledColor ??
                CupertinoColors.quaternarySystemFill,
            minimumSize: buttonStyle?.minimumSize,
            pressedOpacity: buttonStyle?.pressedOpacity ?? 0.4,
            borderRadius: buttonStyle?.borderRadius,
            alignment: buttonStyle?.alignment ?? Alignment.center,
            focusColor: buttonStyle?.focusColor,
            focusNode: buttonStyle?.focusNode,
            onFocusChange: buttonStyle?.onFocusChange,
            autofocus: buttonStyle?.autofocus ?? false,
            mouseCursor: buttonStyle?.mouseCursor,
            onLongPress: buttonStyle?.onLongPress,
            onPressed: onPressed,
            child: child,
          ),
        };
      },
    );
  }
}

/// Style configuration for customizing [CupertinoMenuChip] button appearance.
///
/// All properties are optional with Cupertino defaults.
class CupertinoChipStyle {
  // final Widget? child;
  // final VoidCallback? onPressed;

  /// Which [CupertinoButton] constructor to use.
  ///
  /// Defaults to [CupertinoMenuChipButtonVariant.plain].
  final CupertinoMenuChipButtonVariant variant;

  /// The size of the button.
  ///
  /// Defaults to [CupertinoButtonSize.large].
  final CupertinoButtonSize? sizeStyle;

  /// The amount of space to surround the child inside the bounds of the button.
  final EdgeInsetsGeometry? padding;

  /// The color of the button's background.
  final Color? color;

  /// The color of the button's text and icons.
  final Color? foregroundColor;

  /// The color of the button's background when the button is disabled.
  final Color? disabledColor;

  /// The minimum size of the button.
  final Size? minimumSize;

  /// The opacity that the button will fade to when it is pressed.
  ///
  /// Defaults to 0.4.
  final double? pressedOpacity;

  /// The radius of the button's corners when it has a background color.
  final BorderRadius? borderRadius;

  /// The alignment of the button's child.
  ///
  /// Defaults to [Alignment.center].
  final AlignmentGeometry? alignment;

  /// The color to use for the focus highlight for keyboard interactions.
  final Color? focusColor;

  /// An optional focus node for the button.
  final FocusNode? focusNode;

  /// Called when the button's focus changes.
  final ValueChanged<bool>? onFocusChange;

  /// Whether this widget should be the initial focus.
  ///
  /// Defaults to false.
  final bool autofocus;

  /// The cursor for a mouse pointer when it hovers over the button.
  final MouseCursor? mouseCursor;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// The trailing chevron on the button.
  ///
  /// Defaults to [CupertinoIcons.chevron_up_chevron_down].
  final Widget? expandIcon;

  /// Creates a style configuration for [CupertinoMenuChip]'s button.
  const CupertinoChipStyle({
    this.variant = CupertinoMenuChipButtonVariant.plain,
    this.sizeStyle,
    this.padding,
    this.color,
    this.foregroundColor,
    this.disabledColor,
    this.minimumSize,
    this.pressedOpacity,
    this.borderRadius,
    this.alignment,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.mouseCursor,
    this.onLongPress,
    this.expandIcon,
  });
}

/// Style configuration for customizing [CupertinoMenuChip] popup menu.
///
/// All properties are optional with Cupertino defaults.
class CupertinoPopupMenuStyle {
  // final MenuController? controller;
  // final List<Widget> menuChildren;
  // final RawMenuAnchorChildBuilder? builder;
  // final Widget? child;

  /// Called when the menu begins opening.
  final VoidCallback? onOpen;

  /// Called when the menu finishes closing.
  final VoidCallback? onClose;

  /// Called when the menu animation status changes.
  final CupertinoMenuAnimationStatusChangedCallback? onAnimationStatusChanged;

  /// Constraints applied to the menu scrollable.
  final BoxConstraints? constraints;

  /// Whether the menu's cross axis should be constrained by the overlay.
  ///
  /// Defaults to false.
  final bool constrainCrossAxis;

  /// Whether a tap that closes the menu is consumed instead of reaching
  /// widgets underneath.
  ///
  /// Defaults to false, matching [CupertinoMenuAnchor].
  final bool consumeOutsideTaps;

  /// Whether swiping is enabled on the menu.
  ///
  /// Defaults to true.
  final bool enableSwipe;

  /// Whether the menu should open in response to a long-press on the anchor.
  ///
  /// Defaults to false. Requires [enableSwipe] to be true.
  final bool enableLongPressToOpen;

  /// Whether to use the root overlay.
  ///
  /// Defaults to false.
  final bool useRootOverlay;

  /// Padding inside the overlay between its boundary and the menu content.
  ///
  /// Defaults to `EdgeInsets.all(8)`.
  final EdgeInsetsGeometry overlayPadding;

  /// Focus node associated with the child that opens the menu.
  final FocusNode? childFocusNode;

  /// Padding applied to every [CupertinoMenuItem].
  final EdgeInsetsGeometry? itemPadding;

  /// Constraints applied to every [CupertinoMenuItem].
  final BoxConstraints? itemConstraints;

  /// Horizontal space for each item's leading widget.
  final double? leadingWidth;

  /// Alignment of the leading widget within [leadingWidth].
  final AlignmentGeometry? leadingMidpointAlignment;

  /// Trailing widget used when [CupertinoMenuChipItem.trailing] is null.
  final Widget? itemTrailing;

  /// Horizontal space for each item's trailing widget.
  final double? trailingWidth;

  /// Alignment of the trailing widget within [trailingWidth].
  final AlignmentGeometry? trailingMidpointAlignment;

  /// Decoration painted behind every menu item.
  final WidgetStateProperty<BoxDecoration>? itemDecoration;

  /// Mouse cursor for every menu item.
  final WidgetStateProperty<MouseCursor>? itemMouseCursor;

  /// Hit-test behavior for every menu item.
  ///
  /// Defaults to [HitTestBehavior.opaque].
  final HitTestBehavior itemBehavior;

  /// Whether activating an item closes the menu.
  ///
  /// Defaults to true.
  final bool requestCloseOnActivate;

  /// Whether hovering a menu item requests focus.
  ///
  /// Defaults to true.
  final bool requestFocusOnHover;

  /// Whether every menu item requests autofocus.
  ///
  /// Defaults to false.
  final bool itemAutofocus;

  /// Called when a menu item's focus changes.
  final ValueChanged<bool>? itemOnFocusChange;

  /// Called when a pointer hovers a menu item.
  final ValueChanged<bool>? itemOnHover;

  /// Creates a style configuration for [CupertinoMenuChip] popup menu.
  const CupertinoPopupMenuStyle({
    this.onOpen,
    this.onClose,
    this.onAnimationStatusChanged,
    this.constraints,
    this.constrainCrossAxis = false,
    this.consumeOutsideTaps = false,
    this.enableSwipe = true,
    this.enableLongPressToOpen = false,
    this.useRootOverlay = false,
    this.overlayPadding = const EdgeInsets.all(8),
    this.childFocusNode,
    this.itemPadding,
    this.itemConstraints,
    this.leadingWidth,
    this.leadingMidpointAlignment,
    this.itemTrailing,
    this.trailingWidth,
    this.trailingMidpointAlignment,
    this.itemDecoration,
    this.itemMouseCursor,
    this.itemBehavior = HitTestBehavior.opaque,
    this.requestCloseOnActivate = true,
    this.requestFocusOnHover = true,
    this.itemAutofocus = false,
    this.itemOnFocusChange,
    this.itemOnHover,
  });
}
