import 'package:flutter/material.dart';
import 'package:thevendor/constants/colors.dart';

extension HexColor on MaterialColor {

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static MaterialColor fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    final color = Color(int.parse(buffer.toString(), radix: 16));
    return MaterialColor(color.value, getSwatch(color));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  static MaterialColor get primaryColor =>  fromHex(kPrimaryColor);
  static MaterialColor get primaryLightColor =>  fromHex(kPrimaryLightColor);
  static MaterialColor get bodyBackgroundPrimaryColor =>  fromHex(kBodyBackgroundPrimaryColor);
  static MaterialColor get textPrimaryColor =>  fromHex(kTextPrimaryColor);
  static MaterialColor get borderPrimaryColor =>  fromHex(kBorderPrimaryColor);
  static MaterialColor get headerPrimaryColor =>  fromHex(kHeaderPrimaryColor);
  static MaterialColor get cardBorderPrimaryColor =>  fromHex(kCardBorderPrimaryColor);
  static MaterialColor get cardTextPrimaryColor =>  fromHex(kCardTextPrimaryColor);
  static MaterialColor get pricePrimaryColor =>  fromHex(kPricePrimaryColor);
  static MaterialColor get buttonSecondaryColor =>  fromHex(kButtonSecondaryColor);
  static MaterialColor get textSuccessColor =>  fromHex(kTextSuccessColor);
  static MaterialColor get dangerAlertTextColor =>  fromHex(kDangerAlertTextColor);
  static MaterialColor get dangerAlertBackgroundColor =>  fromHex(kDangerAlertBackgroundColor);
  static MaterialColor get dangerAlertBorderColor =>  fromHex(kDangerAlertBorderColor);
  static MaterialColor get successAlertTextColor =>  fromHex(kSuccessAlertTextColor);
  static MaterialColor get successAlertBackgroundColor =>  fromHex(kSuccessAlertBackgroundColor);
  static MaterialColor get successAlertBorderColor =>  fromHex(kSuccessAlertBorderColor);
  static MaterialColor get infoAlertTextColor =>  fromHex(kInfoAlertTextColor);
  static MaterialColor get infoAlertBackgroundColor =>  fromHex(kInfoAlertBackgroundColor);
  static MaterialColor get infoAlertBorderColor =>  fromHex(kInfoAlertBorderColor);
  static MaterialColor get yellowColor =>  fromHex(kYellowColor);

}

Map<int, Color> getSwatch(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final lightness = hslColor.lightness;

  /// if [500] is the default color, there are at LEAST five
  /// steps below [500]. (i.e. 400, 300, 200, 100, 50.) A
  /// divisor of 5 would mean [50] is a lightness of 1.0 or
  /// a color of #ffffff. A value of six would be near white
  /// but not quite.
  final lowDivisor = 6;

  /// if [500] is the default color, there are at LEAST four
  /// steps above [500]. A divisor of 4 would mean [900] is
  /// a lightness of 0.0 or color of #000000
  final highDivisor = 5;

  final lowStep = (1.0 - lightness) / lowDivisor;
  final highStep = lightness / highDivisor;

  return {
    50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
    100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
    200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
    300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
    400: (hslColor.withLightness(lightness + lowStep)).toColor(),
    500: (hslColor.withLightness(lightness)).toColor(),
    600: (hslColor.withLightness(lightness - highStep)).toColor(),
    700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
    800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
    900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
  };
}

int toIntegerColor(MaterialColor color){
  return int.parse("0x${color.toHex().substring(1)}");
}