import 'package:assistant_me/common/app_theme.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText._(this.label, this.fontSize, this.isBold, {this.color, this.isUnderLine = false, this.overflow});

  factory AppText.small(String label, {bool isBold = false, Color? textColor}) {
    return AppText._(label, 12, isBold, color: textColor);
  }

  factory AppText.normal(String label, {bool isBold = false, Color? textColor, TextOverflow? overflow}) {
    return AppText._(label, AppTheme.defaultTextSize, isBold, color: textColor, overflow: overflow);
  }

  factory AppText.large(String label, {bool isBold = false, Color? textColor}) {
    return AppText._(label, 16, isBold, color: textColor);
  }

  factory AppText.error(String label) {
    return AppText._(label, AppTheme.defaultTextSize, false, color: Colors.red);
  }

  factory AppText.pageTitle(String label) {
    return AppText._(label, 18, true);
  }

  factory AppText.weblink(String label) {
    return AppText._(label, AppTheme.defaultTextSize, false, color: Colors.blueAccent, isUnderLine: true);
  }

  final String label;
  final double fontSize;
  final Color? color;
  final bool isBold;
  final bool isUnderLine;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : null,
        decoration: isUnderLine ? TextDecoration.underline : null,
        overflow: overflow,
        color: color,
      ),
    );
  }
}
