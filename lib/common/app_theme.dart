import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Colors.green;
  static const Color primaryLightColor = Color.fromARGB(255, 141, 251, 165);
  static const Color selectedCardColor = Color.fromARGB(255, 117, 116, 116);

  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Note Sans JP',
    primaryColor: primaryColor,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(
      color: primaryLightColor,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      selectedIconTheme: IconThemeData(color: primaryLightColor),
      selectedLabelTextStyle: TextStyle(color: primaryLightColor),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLightColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.black,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),
  );
}
