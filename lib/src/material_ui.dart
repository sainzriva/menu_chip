import 'dart:ui' show BlendMode, Clip, Color, ColorFilter, Radius;
import 'package:flutter/foundation.dart' show Key, ValueChanged, ValueKey;
import 'package:flutter/painting.dart'
    show CircleBorder, Offset, OutlinedBorder;
import 'package:flutter/animation.dart' show AnimationStyle;
import 'package:flutter/rendering.dart'
    show
        BorderRadius,
        BorderSide,
        BoxConstraints,
        EdgeInsetsGeometry,
        MainAxisSize,
        MouseCursor,
        ShapeBorder,
        TextStyle;
import 'package:flutter/widgets.dart'
    show
        AnimatedSwitcher,
        BuildContext,
        ColorFiltered,
        FadeTransition,
        GlobalKey,
        Icon,
        KeyedSubtree,
        Row,
        ScaleTransition,
        State,
        StatefulWidget,
        Widget,
        WidgetStateProperty,
        FocusNode;
import 'package:flutter/material.dart'
    show
        Colors,
        Durations,
        FilterChip,
        Icons,
        ListTile,
        MaterialLocalizations,
        PopupMenuButton,
        PopupMenuButtonState,
        PopupMenuItem,
        PopupMenuPosition,
        VisualDensity,
        MaterialTapTargetSize,
        ChipAnimationStyle;
import '../src/model.dart' show MenuChipItem;

/// A lightweight and customizable Flutter package that combines a filter chip
/// with a dropdown menu.
///
/// Perfect for creating selection interfaces where users need to choose from
/// multiple options in a compact, intuitive UI component.
///
/// /// ### Example:
/// ```dart
/// import 'package:menu_chip/menu_chip.dart';
///
/// // Place it as higher in your active widget tree as possible
/// final _key = GlobalKey<PopupMenuButtonState>();
/// String? _chipValue;
///
/// MaterialMenuChip(
///   menuKey: _key,
///   menuItemsList: [
///     MenuChipItem(
///       value: 'option1',
///       label: Text('Option 1'),
///       avatar: Icon(Icons.star),
///     ),
///     MenuChipItem(
///       value: 'option2',
///       label: Text('Option 2'),
///       avatar: Icon(Icons.favorite),
///     ),
///   ],
///   selectedValue: _chipValue,
///   onSelectionChanged: (value) {
///     print('Selected: $value');
///   },
///   chipLabel: Text('Filter'),
/// );
/// ```
///
/// See also:
/// - [MenuChipItem], which defines individual menu items
/// - [MaterialChipStyle], for customizing the chip's appearance
/// - [MaterialPopupMenuStyle], for customizing the dropdown menu
class MaterialMenuChip<T> extends StatefulWidget {
  /// A [GlobalKey] for the underlying [PopupMenuButton].
  ///
  /// Place this key as high in your widget tree as possible to ensure
  /// proper menu positioning and state management.
  ///
  /// This key allows programmatic control of the menu (opening/closing)
  /// and is required for the widget to function correctly.
  final GlobalKey<PopupMenuButtonState> menuKey;

  /// The list of selectable items to display in the dropdown menu.
  ///
  /// Each item must be a [MenuChipItem] with a [MenuChipItem.value] and
  /// [MenuChipItem.label].
  /// The list must not be empty.
  ///
  /// Example:
  /// ```dart
  /// menuItemsList: [
  ///   MenuChipItem(value: 'home', label: Text('Home')),
  ///   MenuChipItem(value: 'work', label: Text('Work')),
  /// ]
  /// ```
  final List<MenuChipItem<T>> menuItemsList;

  /// The currently selected value, or `null` if no selection.
  ///
  /// When provided, the chip will display as "onSelected" and show
  /// the corresponding menu item as checked in the dropdown.
  final T? selectedValue;

  /// Called when a menu item is selected or the selection is cleared.
  ///
  /// The callback receives the selected [MenuChipItem.value], or `null`
  /// if the user clears the selection (via the delete icon when enabled).
  ///
  /// Example:
  /// ```dart
  /// onSelectionChanged: (value) {
  ///   setState(() => _selectedValue = value);
  /// }
  /// ```
  final ValueChanged<T?> onSelectionChanged;

  /// An optional widget displayed on the left side of the chip.
  ///
  /// Typically an [Icon] or [CircleAvatar], but can be any widget.
  /// If not provided, the chip will show only the [chipLabel].
  ///
  /// Example:
  /// ```dart
  /// chipAvatar: Icon(Icons.filter_list),
  /// ```
  final Widget? chipAvatar;

  /// The primary text/widget displayed on the chip.
  ///
  /// Usually a [Text] widget describing the chip's purpose.
  /// This widget is always visible on the chip.
  ///
  /// Required to provide context about what the chip controls.
  final Widget chipLabel;

  /// Whether the chip is interactive.
  ///
  /// When `false` (default is `true`), the chip appears disabled
  /// and does not respond to taps or hover interactions.
  final bool isChipEnabled;

  /// Customization options for the chip's visual appearance.
  ///
  /// Use [MaterialChipStyle] to customize colors, icons, borders,
  /// and other visual properties of the chip.
  ///
  /// If `null`, default Material Design 3 styles are used.
  final MaterialChipStyle? chipStyle;

  /// Customization options for the dropdown menu.
  ///
  /// Use [MaterialPopupMenuStyle] to customize the menu's appearance,
  /// including colors, elevation, padding, and item styling.
  ///
  /// If `null`, default Material Design styles 3 are used.
  final MaterialPopupMenuStyle? menuStyle;

  /// Creates a Material Design chip with dropdown menu.
  ///
  /// The [menuKey], [menuItemsList], [onSelectionChanged], and [chipLabel]
  /// parameters are required and must not be `null`.
  ///
  /// All other parameters are optional with sensible defaults.
  const MaterialMenuChip({
    super.key,
    required this.menuKey,
    required this.menuItemsList,
    this.selectedValue,
    required this.onSelectionChanged,
    this.chipAvatar,
    required this.chipLabel,
    this.isChipEnabled = true,
    this.chipStyle,
    this.menuStyle,
  });

  @override
  State<MaterialMenuChip<T>> createState() => _MaterialMenuChipState<T>();
}

class _MaterialMenuChipState<T> extends State<MaterialMenuChip<T>> {
  late bool _isSelected;
  late MenuChipItem<T>? _selectedMenuItem;
  late bool _showDeleteIcon;
  late bool _showCheckmark;
  late _TrailingStatus _trailingStatus;

  @override
  void initState() {
    super.initState();
    _getValues();
  }

  @override
  void didUpdateWidget(MaterialMenuChip<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getValues();
  }

  void _getValues() {
    _isSelected = widget.selectedValue != null;
    _selectedMenuItem = _isSelected
        ? widget.menuItemsList.firstWhere(
            (e) => e.value == widget.selectedValue,
            orElse: () => widget.menuItemsList.first,
          )
        : null;
    _showDeleteIcon = widget.chipStyle?.showDeleteIcon ?? true;
    _showCheckmark = widget.chipStyle?.showCheckmark ?? true;
    _trailingStatus = _showMenu(false);
  }

  void _updateMenu(_MenuAction status, {T? value}) {
    if (status == _MenuAction.onOpen) {
      setState(() => _trailingStatus = _showMenu(true));
    } else if (status == _MenuAction.onSelected) {
      setState(() {
        _trailingStatus = _showMenu(false);
        widget.onSelectionChanged.call(value);
      });
    } else {
      setState(() => _trailingStatus = _showMenu(false));
    }
  }

  _TrailingStatus _showMenu(bool value) {
    if (value) {
      return _TrailingStatus.collapse;
    } else if (_isSelected && _showDeleteIcon) {
      return _TrailingStatus.delete;
    } else {
      return _TrailingStatus.expand;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? chipAvatar() {
      if (_isSelected && _showCheckmark) {
        return null;
      } else if (_isSelected && !_showCheckmark) {
        final Widget? avatar = (_selectedMenuItem?.avatar);
        final Color? color = widget.chipStyle?.selectedAvatarColor;

        if (avatar == null) return null;

        final Key key = Key(_selectedMenuItem?.value.toString() ?? '');

        return color == null
            ? KeyedSubtree(key: key, child: avatar)
            : ColorFiltered(
                key: avatar.key,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                child: avatar,
              );
      } else {
        return widget.chipAvatar;
      }
    }

    Widget chipLabel() {
      return _selectedMenuItem?.label ?? widget.chipLabel;
    }

    TextStyle? labelStyle() {
      return switch (_isSelected) {
        true => widget.chipStyle?.selectedLabelStyle,
        false => widget.chipStyle?.labelStyle,
      };
    }

    Widget trailingIcon() {
      return switch (_trailingStatus) {
        _TrailingStatus.expand => widget.chipStyle?.expandIcon ??
            const Icon(key: ValueKey('expand'), Icons.arrow_drop_down),
        _TrailingStatus.collapse => widget.chipStyle?.collapseIcon ??
            const Icon(key: ValueKey('collapse'), Icons.arrow_drop_up),
        _TrailingStatus.delete => widget.chipStyle?.deleteIcon ??
            const Icon(key: ValueKey('remove'), Icons.close),
      };
    }

    String? trailingMessage() {
      return switch (_trailingStatus) {
        _TrailingStatus.expand => widget.chipStyle?.expandTooltipMessage ??
            MaterialLocalizations.of(context).collapsedIconTapHint,
        _TrailingStatus.collapse => null,
        _TrailingStatus.delete => widget.chipStyle?.deleteButtonTooltipMessage,
      };
    }

    Color? trailingIconColor() {
      return switch ((_trailingStatus, _isSelected)) {
        (_TrailingStatus.delete, _) => widget.chipStyle?.deleteIconColor,
        (_TrailingStatus.collapse, true) => widget.chipStyle?.deleteIconColor,
        _ => widget.chipStyle?.expandCollapseIconColor,
      };
    }

    Widget? iconAnimation(Widget? widget) {
      return widget == null
          ? null
          : AnimatedSwitcher(
              duration: Durations.short4,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: widget,
            );
    }

    List<PopupMenuItem<T>> itemBuilder() {
      return List<PopupMenuItem<T>>.generate(widget.menuItemsList.length, (i) {
        final item = widget.menuItemsList[i];
        return PopupMenuItem<T>(
          value: item.value,
          child: ListTile(leading: item.avatar, title: item.label),
        );
      });
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <PopupMenuButton<T>>[
        PopupMenuButton<T>(
          key: widget.menuKey,
          itemBuilder: (_) => itemBuilder(),
          initialValue: widget.selectedValue,
          onOpened: () => _updateMenu(_MenuAction.onOpen),
          onSelected: (T newValue) {
            _updateMenu(_MenuAction.onSelected, value: newValue);
          },
          onCanceled: () => _updateMenu(_MenuAction.onCanceled),
          tooltip: '',
          elevation: widget.menuStyle?.elevation,
          shadowColor: widget.menuStyle?.shadowColor,
          surfaceTintColor: widget.menuStyle?.surfaceTintColor,
          menuPadding: widget.menuStyle?.menuPadding,
          borderRadius: const BorderRadius.all(Radius.circular(1000)),
          offset: widget.menuStyle?.offset ?? Offset.zero,
          color: widget.menuStyle?.color,
          enableFeedback: widget.menuStyle?.enableFeedback,
          constraints: widget.menuStyle?.constraints,
          position: widget.menuStyle?.position ?? PopupMenuPosition.under,
          clipBehavior: widget.menuStyle?.clipBehavior ?? Clip.none,
          popUpAnimationStyle: widget.menuStyle?.popUpAnimationStyle,
          requestFocus: widget.menuStyle?.requestFocus,
          child: FilterChip(
            avatar: iconAnimation(chipAvatar()),
            label: chipLabel(),
            selected: _isSelected,
            onSelected: widget.isChipEnabled
                ? (_) {
                    widget.menuKey.currentState?.showButtonMenu();
                  }
                : null,
            deleteIcon: iconAnimation(trailingIcon()),
            onDeleted: () {
              _isSelected && _showDeleteIcon
                  ? widget.onSelectionChanged.call(null)
                  : widget.menuKey.currentState?.showButtonMenu();
            },
            labelStyle: labelStyle(),
            deleteButtonTooltipMessage: trailingMessage(),
            deleteIconColor: trailingIconColor(),
            labelPadding: widget.chipStyle?.labelPadding,
            pressElevation: widget.chipStyle?.pressElevation,
            disabledColor: widget.chipStyle?.disabledColor,
            selectedColor: widget.chipStyle?.selectedColor,
            tooltip: widget.chipStyle?.tooltip ?? '',
            side: widget.chipStyle?.side,
            shape: widget.chipStyle?.shape,
            clipBehavior: widget.chipStyle?.clipBehavior ?? Clip.none,
            focusNode: widget.chipStyle?.focusNode,
            autofocus: widget.chipStyle?.autofocus ?? false,
            color: widget.chipStyle?.color,
            backgroundColor: widget.chipStyle?.backgroundColor,
            padding: widget.chipStyle?.padding,
            visualDensity: widget.chipStyle?.visualDensity,
            materialTapTargetSize: widget.chipStyle?.materialTapTargetSize,
            elevation: widget.chipStyle?.elevation,
            shadowColor: widget.chipStyle?.shadowColor,
            surfaceTintColor: widget.chipStyle?.surfaceTintColor,
            selectedShadowColor: widget.chipStyle?.selectedShadowColor,
            showCheckmark: widget.chipStyle?.showCheckmark,
            checkmarkColor: widget.chipStyle?.checkmarkColor,
            avatarBorder:
                widget.chipStyle?.avatarBorder ?? const CircleBorder(),
            avatarBoxConstraints: widget.chipStyle?.avatarBoxConstraints,
            deleteIconBoxConstraints:
                widget.chipStyle?.deleteIconBoxConstraints,
            chipAnimationStyle: widget.chipStyle?.chipAnimationStyle,
            mouseCursor: widget.chipStyle?.mouseCursor,
          ),
        ),
      ],
    );
  }
}

/// Style configuration for customizing [MaterialMenuChip] appearance.
///
/// All properties are optional with sensible Material Design defaults.
///
/// ### Example:
/// ```dart
/// MaterialChipStyle(
///   labelStyle: TextStyle(fontStyle: FontStyle.italic),
///   selectedLabelStyle: TextStyle(
///     color: Colors.white,
///     fontWeight: FontWeight.bold,
///   ),
///   deleteIcon: Icon(Icons.delete),
///   deleteIconColor: Colors.brown,
///   selectedColor: Colors.blue,
///   backgroundColor: Colors.lime,
///   checkmarkColor: Colors.yellowAccent,
/// ),
/// ```
class MaterialChipStyle {
  // final Key? key;
  // final Widget? avatar;

  /// Used to define the avatar widget's color with an [ColorFilter] that
  /// contains the color with [BlendMode.srcIn].
  final Color? selectedAvatarColor; // NEW

  // final Widget label;

  /// The style to be applied to the chip's label.
  ///
  /// If this is null and [ThemeData.useMaterial3] is true, then
  /// [TextTheme.labelLarge] is used. Otherwise, [TextTheme.bodyLarge] is used.
  /// This only has an effect on widgets that respect the [DefaultTextStyle],
  /// such as [Text].
  ///
  /// If [TextStyle.color] is a [WidgetStateProperty],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  /// [WidgetState.disabled].
  /// [WidgetState.selected].
  /// [WidgetState.hovered].
  /// [WidgetState.focused].
  /// [WidgetState.pressed].
  final TextStyle? labelStyle;

  /// The style to be applied to the chip's label when the [WidgetState] is
  /// [WidgetState.selected].
  final TextStyle? selectedLabelStyle; // NEW

  /// The padding around the [MenuChipItem.label] widget.
  ///
  /// By default, this is 4 logical pixels at the beginning and the end of the
  /// label, and zero on top and bottom.
  final EdgeInsetsGeometry? labelPadding;

  // final bool selected;

  // final void Function(bool)? onSelected;

  /// Whether or not to show a delete icon when "onDeleted" is set.
  ///
  /// Defaults to true.
  final bool showDeleteIcon; // NEW

  /// The icon displayed when "onDeleted" is set.
  ///
  /// If [deleteIconColor] is provided, it will be used as the color of the
  /// delete icon. If [deleteIconColor] is null, then the icon will use the
  /// color specified in the chip [IconTheme]. If the [IconTheme] is null, then
  /// the icon will use the color specified in the [ThemeData.iconTheme].
  ///
  /// If a size is specified in the chip [IconTheme], then the delete icon will
  /// use that size. Otherwise, defaults to 18 pixels.
  ///
  /// Defaults to an [Icon] widget set to use [Icons.clear]. If
  /// [ThemeData.useMaterial3] is false, then defaults to an [Icon] widget set
  /// to use [Icons.cancel].
  final Widget? deleteIcon;

  // final void Function()? onDeleted;

  /// Used to define the delete icon's color with an [IconTheme] that contains
  /// the icon.
  ///
  /// The default is Color(0xde000000) (slightly transparent black) for light
  /// themes, and Color(0xdeffffff) (slightly transparent white) for dark themes.
  ///
  /// The delete icon appears if [DeletableChipAttributes.onDeleted] is non-null.
  final Color? deleteIconColor;

  /// The message to be used for the chip's delete button tooltip.
  ///
  /// If provided with an empty string, the tooltip of the delete button will
  /// be disabled.
  ///
  /// If null, the default [MaterialLocalizations.deleteButtonTooltip] will be
  /// used.
  ///
  /// If the chip is disabled, the delete button tooltip will not be shown.
  final String? deleteButtonTooltipMessage;

  /// The icon displayed when "onExpand" is set.
  ///
  /// If [expandCollapseIconColor] is provided, it will be used as the color of
  /// the expand icon. If [expandCollapseIconColor] is null, then the icon will
  /// use the color specified in the chip [IconTheme]. If the [IconTheme] is
  /// null, then the icon will use the color specified in the
  /// [ThemeData.iconTheme].
  ///
  /// If a size is specified in the chip [IconTheme], then the expand icon will
  /// use that size. Otherwise, defaults to 18 pixels.
  ///
  /// Defaults to an [Icon] widget set to use [Icons.arrow_drop_down].
  final Widget? expandIcon; // NEW

  /// The message to be used for the chip's expand button tooltip.
  ///
  /// If provided with an empty string, the tooltip of the expand button will
  /// be disabled.
  ///
  /// If null, the default [MaterialLocalizations.collapsedIconTapHint] will be
  /// used.
  ///
  /// If the chip is disabled, the expand button tooltip will not be shown.
  final String? expandTooltipMessage; // NEW

  /// The icon displayed when "onCollapse" is set.
  ///
  /// If [expandCollapseIconColor] is provided, it will be used as the color of
  /// the collapse icon. If [expandCollapseIconColor] is null, then the icon
  /// will use the color specified in the chip [IconTheme]. If the [IconTheme]
  /// is null, then the icon will use the color specified in the
  /// [ThemeData.iconTheme].
  ///
  /// If a size is specified in the chip [IconTheme], then the collapse icon
  /// will use that size. Otherwise, defaults to 18 pixels.
  ///
  /// Defaults to an [Icon] widget set to use [Icons.arrow_drop_up].
  final Widget? collapseIcon; // NEW

  /// Used to define the expand or collapse icon's color with an [IconTheme]
  /// that contains the icon.
  ///
  /// The default is Color(0xde000000) (slightly transparent black) for light
  /// themes, and Color(0xdeffffff) (slightly transparent white) for dark themes.
  ///
  /// The delete icon appears if [DeletableChipAttributes.onDeleted] is non-null.
  final Color? expandCollapseIconColor; // NEW

  /// Elevation to be applied on the chip relative to its parent during the
  /// press motion.
  ///
  /// This controls the size of the shadow below the chip.
  ///
  /// Defaults to 8. The value is always non-negative.
  final double? pressElevation;

  /// The color used for the chip's background to indicate that it is not
  /// enabled.
  ///
  /// The chip is disabled when [MaterialMenuChip.isChipEnabled] is false, or
  /// all three of [SelectableChipAttributes.onSelected],
  /// [TappableChipAttributes.onPressed], and
  /// [DeletableChipAttributes.onDeleted] are null.
  ///
  /// It defaults to [Colors.black38].
  final Color? disabledColor;

  /// Color to be used for the chip's background, indicating that it is selected.
  ///
  /// The chip is selected when [MaterialMenuChip.selectedValue] is not null.
  final Color? selectedColor;

  /// Tooltip string to be used for the body area (where the label and avatar
  /// are) of the chip.
  ///
  /// Defaults is not be shown.
  final String? tooltip;

  /// The color and weight of the chip's outline.
  ///
  /// Defaults to the border side in the ambient [ChipThemeData]. If the theme
  /// border side resolves to null and [ThemeData.useMaterial3] is true, then
  /// [BorderSide] with a [ColorScheme.outline] color is used when the chip is
  /// enabled, and [BorderSide] with a [ColorScheme.onSurface] color with an
  /// opacity of 0.12 is used when the chip is disabled. Otherwise, it defaults
  /// to null.
  ///
  /// This value is combined with [shape] to create a shape decorated with an
  /// outline. To omit the outline entirely, pass [BorderSide.none] to [side].
  ///
  /// If it is a [WidgetStateBorderSide], [WidgetStateProperty.resolve] is used
  /// for the following [WidgetState]s:
  ///
  /// [WidgetState.disabled].
  /// [WidgetState.selected].
  /// [WidgetState.hovered].
  /// [WidgetState.focused].
  /// [WidgetState.pressed].
  final BorderSide? side;

  /// The [OutlinedBorder] to draw around the chip.
  ///
  /// Defaults to the shape in the ambient [ChipThemeData]. If the theme shape
  /// resolves to null and [ThemeData.useMaterial3] is true, then
  /// [RoundedRectangleBorder] with a circular border radius of 8.0 is used.
  /// Otherwise, [StadiumBorder] is used.
  ///
  /// This shape is combined with [side] to create a shape decorated with an
  /// outline. If [side] is not null or side of [shape] is [BorderSide.none],
  /// side of [shape] is ignored. To omit the outline entirely, pass
  /// [BorderSide.none] to [side].
  ///
  /// If it is a [WidgetStateOutlinedBorder], [WidgetStateProperty.resolve] is
  /// used for the following [WidgetState]s:
  ///
  /// [WidgetState.disabled].
  /// [WidgetState.selected].
  /// [WidgetState.hovered].
  /// [WidgetState.focused].
  /// [WidgetState.pressed].
  final OutlinedBorder? shape;

  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// An optional focus node to use as the focus node for this widget.
  ///
  /// If one is not supplied, then one will be automatically allocated, owned,
  /// and managed by this widget. The widget will be focusable even if a
  /// [focusNode] is not supplied. If supplied, the given [focusNode] will be
  /// hosted by this widget, but not owned. See [FocusNode] for more information
  /// on what being hosted and/or owned implies.
  ///
  /// Supplying a focus node is sometimes useful if an ancestor to this widget
  /// wants to control when this widget has the focus. The owner will be
  /// responsible for calling [FocusNode.dispose] on the focus node when it is
  /// done with it, but this widget will attach/detach and reparent the node
  /// when needed.
  final FocusNode? focusNode;

  /// True if this widget will be selected as the initial focus when no other
  /// node in its scope is currently focused.
  ///
  /// Ideally, there is only one widget with autofocus set in each [FocusScope].
  /// If there is more than one widget with autofocus set, then the first one
  /// added to the tree will get focus.
  ///
  /// Defaults to false.
  final bool autofocus;

  /// The color that fills the chip, in all [WidgetState]s.
  ///
  /// Defaults to null.
  ///
  /// Resolves in the following states:
  ///
  /// [WidgetState.selected].
  /// [WidgetState.disabled].
  final WidgetStateProperty<Color?>? color;

  /// Color to be used for the unselected, enabled chip's background.
  ///
  /// The default is light grey.
  final Color? backgroundColor;

  /// The padding between the contents of the chip and the outside [shape].
  ///
  /// If this is null and [ThemeData.useMaterial3] is true, then a padding of
  /// 8.0 logical pixels on all sides is used. Otherwise, it defaults to a
  /// padding of 4.0 logical pixels on all sides.
  final EdgeInsetsGeometry? padding;

  /// Defines how compact the chip's layout will be.
  ///
  /// Chips are unaffected by horizontal density changes.
  ///
  /// Density, in the context of a UI, is the vertical and horizontal
  /// "compactness" of the elements in the UI. It is unitless, since it means
  /// different things to different UI elements. For buttons, it affects the
  /// spacing around the centered label of the button. For lists, it affects
  /// the distance between baselines of entries in the list.
  ///
  /// Typically, density values are integral, but any value in range may be
  /// used. The range includes values from [VisualDensity.minimumDensity]
  /// (which is -4), to [VisualDensity.maximumDensity] (which is 4), inclusive,
  /// where negative values indicate a denser, more compact, UI, and positive
  /// values indicate a less dense, more expanded, UI. If a component doesn't
  /// support the value given, it will clamp to the nearest supported value.
  ///
  /// The default for visual densities is zero for both vertical and horizontal
  /// densities, which corresponds to the default visual density of components
  /// in the Material Design specification.
  ///
  /// As a rule of thumb, a change of 1 or -1 in density corresponds to 4
  /// logical pixels. However, this is not a strict relationship since
  /// components interpret the density values appropriately for their needs.
  ///
  /// A larger value translates to a spacing increase (less dense), and a
  /// smaller value translates to a spacing decrease (more dense).
  ///
  /// In Material Design 3, the [visualDensity] does not override the default
  /// visual for the following components which are set to
  /// [VisualDensity.standard] for all platforms:
  ///
  /// [IconButton] - To override the default value of
  /// [IconButton.visualDensity], use [ThemeData.iconButtonTheme] instead.
  /// [Checkbox] - To override the default value of [Checkbox.visualDensity],
  /// use [ThemeData.checkboxTheme] instead.
  /// See also:
  ///
  /// [ThemeData.visualDensity], which specifies the [visualDensity] for all widgets within a [Theme].
  final VisualDensity? visualDensity;

  /// Configures the minimum size of the tap target.
  ///
  /// Defaults to [ThemeData.materialTapTargetSize].
  ///
  /// See also:
  ///
  /// [MaterialTapTargetSize], for a description of how this affects tap
  /// targets.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Elevation to be applied on the chip relative to its parent.
  ///
  /// This controls the size of the shadow below the chip.
  ///
  /// Defaults to 0. The value is always non-negative.
  final double? elevation;

  /// Color of the chip's shadow when the elevation is greater than 0.
  ///
  /// If this is null and [ThemeData.useMaterial3] is true, then
  /// [Colors.transparent] color is used. Otherwise, it defaults to null.
  final Color? shadowColor;

  /// Color of the chip's surface tint overlay when its elevation is greater
  /// than 0.
  ///
  /// This is not recommended for use. Material 3 spec introduced a set of
  /// tone-based surfaces and surface containers in its [ColorScheme], which
  /// provide more flexibility. The intention is to eventually remove surface
  /// tint color from the framework.
  ///
  /// If this is null, defaults to [Colors.transparent].
  final Color? surfaceTintColor;

  // final IconThemeData? iconTheme;

  /// Color of the chip's shadow when the elevation is greater than 0 and the
  /// chip is selected.
  ///
  /// The default is [Colors.black].
  final Color? selectedShadowColor;

  /// Whether or not to show a check mark when
  /// [SelectableChipAttributes.selected] is true.
  ///
  /// Defaults to true.
  final bool showCheckmark;

  /// [Color] of the chip's check mark when a check mark is visible.
  ///
  /// This will override the color set by the platform's brightness setting.
  ///
  /// If null, it will defer to a color selected by the platform's brightness
  /// setting.
  final Color? checkmarkColor;

  /// The shape of the translucent highlight painted over the avatar when the
  /// [MaterialMenuChip.selectedValue] property is not null.
  ///
  /// Only the outer path of the shape is used.
  ///
  /// Defaults to [CircleBorder].
  final ShapeBorder avatarBorder;

  /// Optional size constraints for the avatar.
  ///
  /// When unspecified, defaults to a minimum size of chip height or label
  /// height (whichever is greater) and a padding of 8.0 pixels on all sides.
  ///
  /// The default constraints ensure that the avatar is accessible. Specifying
  /// this parameter enables creation of avatar smaller than the minimum size,
  /// but it is not recommended.
  ///
  /// This sample shows how to use [avatarBoxConstraints] to adjust avatar
  /// size constraints
  ///
  /// ** See code in examples/api/lib/material/chip/chip_attributes.avatar_box_constraints.0.dart **
  final BoxConstraints? avatarBoxConstraints;

  /// Optional size constraints for the delete icon.
  ///
  /// When unspecified, defaults to a minimum size of chip height or label
  /// height (whichever is greater) and a padding of 8.0 pixels on all sides.
  ///
  /// The default constraints ensure that the delete icon is accessible.
  /// Specifying this parameter enables creation of delete icon smaller than
  /// the minimum size, but it is not recommended.
  ///
  /// This sample shows how to use [deleteIconBoxConstraints] to adjust delete
  /// icon size constraints.
  ///
  /// ** See code in examples/api/lib/material/chip/deletable_chip_attributes.delete_icon_box_constraints.0.dart **
  final BoxConstraints? deleteIconBoxConstraints;

  /// Used to override the default chip animations durations.
  ///
  /// If [ChipAnimationStyle.enableAnimation] with duration or reverse duration
  /// is provided, it will be used to override the chip enable and disable
  /// animation durations. If it is null, then default duration will be 75ms.
  ///
  /// If [ChipAnimationStyle.selectAnimation] with duration or reverse duration
  /// is provided, it will be used to override the chip select and unselect
  /// animation durations. If it is null, then default duration will be 195ms.
  ///
  /// If [ChipAnimationStyle.avatarDrawerAnimation] with duration or reverse
  /// duration is provided, it will be used to override the chip checkmark
  /// animation duration. If it is null, then default duration will be 150ms.
  ///
  /// If [ChipAnimationStyle.deleteDrawerAnimation] with duration or reverse
  /// duration is provided, it will be used to override the chip delete icon
  /// animation duration. If it is null, then default duration will be 150ms.
  ///
  /// This sample showcases how to override the chip animations durations using
  /// [ChipAnimationStyle].
  ///
  /// ** See code in examples/api/lib/material/chip/chip_attributes.chip_animation_style.0.dart **
  final ChipAnimationStyle? chipAnimationStyle;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  /// [WidgetState.hovered]
  /// [WidgetState.focused]
  /// [WidgetState.disabled]
  /// If this property is null, [WidgetStateMouseCursor.clickable] will be used.
  final MouseCursor? mouseCursor;

  /// Creates a style configuration for [MaterialMenuChip].
  ///
  /// All parameters are optional. Omitted parameters use Material Design 3
  /// defaults.
  const MaterialChipStyle({
    // this.key,
    // this.avatar,
    this.selectedAvatarColor,
    // required this.label,
    this.labelStyle,
    this.selectedLabelStyle,
    this.labelPadding,
    this.showDeleteIcon = true,
    // this.selected = false,
    // required this.onSelected,
    this.deleteIcon,
    // this.onDeleted,
    this.deleteIconColor,
    this.deleteButtonTooltipMessage,
    this.expandIcon,
    this.expandTooltipMessage,
    this.collapseIcon,
    this.expandCollapseIconColor,
    this.pressElevation,
    this.disabledColor,
    this.selectedColor,
    this.tooltip = '',
    this.side,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.color,
    this.backgroundColor,
    this.padding,
    this.visualDensity,
    this.materialTapTargetSize,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    // this.iconTheme,
    this.selectedShadowColor,
    this.showCheckmark = true,
    this.checkmarkColor,
    this.avatarBorder = const CircleBorder(),
    this.avatarBoxConstraints,
    this.deleteIconBoxConstraints,
    this.chipAnimationStyle,
    this.mouseCursor,
  });
}

/// Style configuration for customizing [MaterialMenuChip] popup menu appearance.
///
/// All properties are optional with sensible Material Design defaults.
///
/// ### Example:
/// ```dart
/// MaterialPopupMenuStyle(offset: Offset(-5, 15)),
/// `
class MaterialPopupMenuStyle {
  // final Key? key;

  // final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;

  // final T? initialValue;

  // final void Function()? onOpened;

  // final void Function(T)? onSelected;

  // final void Function()? onCanceled;

  // final String tooltip;

  /// The z-coordinate at which to place the menu when open. This controls the
  /// size of the shadow below the menu.
  ///
  /// Defaults to 8, the appropriate elevation for popup menus.
  final double? elevation;

  /// The color used to paint the shadow below the menu.
  ///
  /// If null then the ambient [PopupMenuThemeData.shadowColor] is used. If
  /// that is null too, then the overall theme's [ThemeData.shadowColor]
  /// (default black) is used.
  final Color? shadowColor;

  /// The color used as an overlay on [color] to indicate elevation.
  ///
  /// This is not recommended for use. Material 3 spec introduced a set of
  /// tone-based surfaces and surface containers in its [ColorScheme], which
  /// provide more flexibility. The intention is to eventually remove surface
  /// tint color from the framework.
  ///
  /// If null, [PopupMenuThemeData.surfaceTintColor] is used. If that is also
  /// null, the default value is [Colors.transparent].
  ///
  /// See [Material.surfaceTintColor] for more details on how this overlay is
  /// applied.
  final Color? surfaceTintColor;

  // final EdgeInsetsGeometry padding;

  /// If provided, menu padding is used for empty space around the outside of
  /// the popup menu.
  ///
  /// If this property is null, then [PopupMenuThemeData.menuPadding] is used.
  /// If [PopupMenuThemeData.menuPadding] is also null, then vertical padding
  /// of 8 pixels is used.
  final EdgeInsetsGeometry? menuPadding;

  // final Widget? child;

  // final BorderRadius? borderRadius;

  // final double? splashRadius;

  // final Widget? icon;

  // final double? iconSize;

  /// The offset is applied relative to the initial position set by the
  /// [position].
  ///
  /// When not set, the offset defaults to [Offset.zero].
  final Offset offset;

  // final bool enabled;

  // final ShapeBorder? shape;

  /// If provided, the background color used for the menu.
  ///
  /// If this property is null, then [PopupMenuThemeData.color] is used. If
  /// [PopupMenuThemeData.color] is also null, then defaults to
  /// [ColorScheme.surfaceContainer].
  final Color? color;

  // final Color? iconColor;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  /// [Feedback] for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  /// Optional size constraints for the menu.
  ///
  /// When unspecified, defaults to:
  ///
  /// const BoxConstraints(
  ///   minWidth: 2.0 * 56.0,
  ///   maxWidth: 5.0 * 56.0,
  /// )
  /// The default constraints ensure that the menu width matches maximum width
  /// recommended by the Material Design guidelines. Specifying this parameter
  /// enables creation of menu wider than the default maximum width.
  final BoxConstraints? constraints;

  /// Whether the popup menu is positioned over or under the popup menu button.
  ///
  /// [offset] is used to change the position of the popup menu relative to the
  /// position set by this parameter.
  ///
  /// If this property is null, then [PopupMenuThemeData.position] is used. If
  /// [PopupMenuThemeData.position] is also null, then the position defaults to
  /// [PopupMenuPosition.over] which makes the popup menu appear directly over
  /// the button that was used to create it.
  final PopupMenuPosition position;

  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  ///
  /// The [clipBehavior] argument is used the clip shape of the menu.
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  // final bool useRootNavigator;

  /// Used to override the default animation curves and durations of the popup
  /// menu's open and close transitions.
  ///
  /// If [AnimationStyle.curve] is provided, it will be used to override the
  /// default popup animation curve. Otherwise, defaults to [Curves.linear].
  ///
  /// If [AnimationStyle.reverseCurve] is provided, it will be used to override
  /// the default popup animation reverse curve. Otherwise, defaults to
  /// Interval(0.0, 2.0 / 3.0).
  ///
  /// If [AnimationStyle.duration] is provided, it will be used to override the
  /// default popup animation duration. Otherwise, defaults to 300ms.
  ///
  /// To disable the theme animation, use [AnimationStyle.noAnimation].
  ///
  /// If this is null, then the default animation will be used.
  final AnimationStyle? popUpAnimationStyle;

  // final RouteSettings? routeSettings;

  // final ButtonStyle? style;

  /// Whether to request focus when the menu appears.
  ///
  /// If null, [Navigator.requestFocus] will be used instead.
  final bool? requestFocus;

  /// Creates a style configuration for [MaterialMenuChip] popup menu.
  ///
  /// All parameters are optional. Omitted parameters use Material Design 3
  /// defaults.
  const MaterialPopupMenuStyle({
    // this.key,
    // required this.itemBuilder,
    // this.initialValue,
    // this.onOpened,
    // this.onSelected,
    // this.onCanceled,
    // this.tooltip = '',
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    // this.padding = const EdgeInsets.all(8.0),
    this.menuPadding,
    // this.child,
    // this.borderRadius,
    // this.splashRadius,
    // this.icon,
    // this.iconSize,
    this.offset = Offset.zero,
    // this.enabled = true,
    // this.shape,
    this.color,
    // this.iconColor,
    this.enableFeedback,
    this.constraints,
    this.position = PopupMenuPosition.under,
    this.clipBehavior = Clip.none,
    // this.useRootNavigator = false,
    this.popUpAnimationStyle,
    // this.routeSettings,
    // this.style,
    this.requestFocus,
  });
}

enum _MenuAction { onOpen, onSelected, onCanceled }

enum _TrailingStatus { expand, collapse, delete }
