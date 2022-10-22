import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/color_helpers.dart';

ThemeData theme() {
  return ThemeData(
    primarySwatch: HexColor.primaryColor,
    appBarTheme: appBarTheme(),
    scaffoldBackgroundColor: HexColor.bodyBackgroundPrimaryColor,
    primaryTextTheme: TextTheme(headline6: TextStyle(color: HexColor.headerPrimaryColor, fontSize: 16)),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    foregroundColor: HexColor.primaryColor,
    titleTextStyle: TextStyle(color: HexColor.textPrimaryColor),
    systemOverlayStyle: SystemUiOverlayStyle(
      // Status bar color
      statusBarColor: HexColor.primaryColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ),
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
