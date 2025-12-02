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

class MaterialMenuChip<T> extends StatefulWidget {
  final GlobalKey<PopupMenuButtonState>
  menuKey; // Place it as higher in your active widget tree as possible
  final List<MenuChipItem<T>> menuItemsList;
  final T? selectedValue;
  final ValueChanged<T?> onSelectionChanged;
  final Widget? chipAvatar;
  final Widget chipLabel;
  final bool isChipEnabled;
  final MaterialChipStyle? chipStyle;
  final MaterialPopupMenuStyle? menuStyle;

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
    _selectedMenuItem =
        _isSelected
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
        _TrailingStatus.expand =>
          widget.chipStyle?.expandIcon ??
              const Icon(key: ValueKey('expand'), Icons.arrow_drop_down),
        _TrailingStatus.collapse =>
          widget.chipStyle?.collapseIcon ??
              const Icon(key: ValueKey('collapse'), Icons.arrow_drop_up),
        _TrailingStatus.delete =>
          widget.chipStyle?.deleteIcon ??
              const Icon(key: ValueKey('remove'), Icons.close),
      };
    }

    String? trailingMessage() {
      return switch (_trailingStatus) {
        _TrailingStatus.expand =>
          widget.chipStyle?.expandTooltipMessage ??
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
            onSelected:
                widget.isChipEnabled
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

class MaterialChipStyle {
  // final Key? key;
  // final Widget? avatar;
  final Color? selectedAvatarColor; // NEW
  // final Widget label;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle; // NEW
  final EdgeInsetsGeometry? labelPadding;
  // final bool selected;
  // final void Function(bool)? onSelected;
  final bool showDeleteIcon; // NEW
  final Widget? deleteIcon;
  // final void Function()? onDeleted;
  final Color? deleteIconColor;
  final String? deleteButtonTooltipMessage;
  final Widget? expandIcon; // NEW
  final String? expandTooltipMessage; // NEW
  final Widget? collapseIcon; // NEW
  final Color? expandCollapseIconColor; // NEW
  final double? pressElevation;
  final Color? disabledColor;
  final Color? selectedColor;
  final String? tooltip;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final WidgetStateProperty<Color?>? color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final MaterialTapTargetSize? materialTapTargetSize;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  // final IconThemeData? iconTheme;
  final Color? selectedShadowColor;
  final bool showCheckmark;
  final Color? checkmarkColor;
  final ShapeBorder avatarBorder;
  final BoxConstraints? avatarBoxConstraints;
  final BoxConstraints? deleteIconBoxConstraints;
  final ChipAnimationStyle? chipAnimationStyle;
  final MouseCursor? mouseCursor;

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

class MaterialPopupMenuStyle {
  // final Key? key;
  // final List<PopupMenuEntry<T>> Function(BuildContext) itemBuilder;
  // final T? initialValue;
  // final void Function()? onOpened;
  // final void Function(T)? onSelected;
  // final void Function()? onCanceled;
  // final String tooltip;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  // final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? menuPadding;
  // final Widget? child;
  // final BorderRadius? borderRadius;
  // final double? splashRadius;
  // final Widget? icon;
  // final double? iconSize;
  final Offset offset;
  // final bool enabled;
  // final ShapeBorder? shape;
  final Color? color;
  // final Color? iconColor;
  final bool? enableFeedback;
  final BoxConstraints? constraints;
  final PopupMenuPosition position;
  final Clip clipBehavior;
  // final bool useRootNavigator;
  final AnimationStyle? popUpAnimationStyle;
  // final RouteSettings? routeSettings;
  // final ButtonStyle? style;
  final bool? requestFocus;

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
