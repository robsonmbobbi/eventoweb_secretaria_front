import 'package:flutter/material.dart';

class ThemeButtonMenu extends ThemeExtension<ThemeButtonMenu> {
  late final ButtonStyle theme;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  ThemeButtonMenu({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  }) {
    theme = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: EdgeInsets.all(13),
      side: BorderSide(color: borderColor),
      fixedSize: const Size(120, 118),
    );
  }

  @override
  ThemeExtension<ThemeButtonMenu> lerp(
    covariant ThemeExtension<ThemeButtonMenu>? other,
    double t,
  ) {
    if (other is! ThemeButtonMenu) {
      return this;
    }
    return ThemeButtonMenu(
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }

  @override
  ThemeExtension<ThemeButtonMenu> copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return ThemeButtonMenu(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}
