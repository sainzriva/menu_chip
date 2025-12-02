import 'package:flutter/widgets.dart' show Widget;

class MenuChipItem<T> {
  final T value;
  final Widget? avatar;
  final Widget label;

  const MenuChipItem({required this.value, this.avatar, required this.label});
}
