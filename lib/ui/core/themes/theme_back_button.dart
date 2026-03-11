import 'package:flutter/material.dart';

class ThemeBackButton extends ThemeExtension<ThemeBackButton> {
  late final ButtonStyle theme;
  final Color foregroundColor;
  final Color backgroundColor;

  ThemeBackButton({
    required this.foregroundColor,
    required this.backgroundColor,
  }) {
    theme = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: EdgeInsets.all(13),
    );
  }

  @override
  ThemeExtension<ThemeBackButton> lerp(
    covariant ThemeExtension<ThemeBackButton>? other,
    double t,
  ) {
    if (other is! ThemeBackButton) {
      return this;
    }
    return ThemeBackButton(
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
    );
  }

  @override
  ThemeExtension<ThemeBackButton> copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return ThemeBackButton(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
