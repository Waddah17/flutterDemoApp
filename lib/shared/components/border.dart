import 'package:flutter/material.dart';
import '../../utils/color_helpers.dart';

Border border([MaterialColor? color]) {
  return Border.all(color: color ?? HexColor.cardBorderPrimaryColor, width: 0.5);
}

Border get borderBottom => Border(bottom: BorderSide(color: HexColor.cardBorderPrimaryColor, width: 0.5));

List<BoxShadow> get borderShadow =>
    <BoxShadow>[BoxShadow(color: HexColor.cardBorderPrimaryColor, blurRadius: 1.0, offset: const Offset(0, 2))];

List<BoxShadow> get borderBottomShadow =>
    <BoxShadow>[BoxShadow(color: HexColor.cardBorderPrimaryColor, blurRadius: 1.0, offset: const Offset(0, 2))];