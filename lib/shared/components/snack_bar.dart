import 'package:flutter/material.dart';
import 'package:thevendor/utils/color_helpers.dart';
import '../../constants/keys.dart';

class CustomSnackBar{

  static void infoAlert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: HexColor.infoAlertBackgroundColor,
      shape: Border.all(color: HexColor.infoAlertBorderColor),
      content: Text(message, style: TextStyle(color: HexColor.infoAlertTextColor),),
    ));
  }

  static void successAlert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: HexColor.successAlertBackgroundColor,
      shape: Border.all(color: HexColor.successAlertBorderColor),
      content: Text(message, style: TextStyle(color: HexColor.successAlertTextColor),),
    ));
  }

  static void dangerAlert(BuildContext context, String message) {

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: HexColor.dangerAlertBackgroundColor,
      shape: Border.all(color: HexColor.dangerAlertBorderColor),
      content: Text(message, style: TextStyle(color: HexColor.dangerAlertTextColor),),
    ));
  }

  static void dangerAlertUsingKey(String message) {
    snackbarKey.currentState?.showSnackBar(SnackBar(
      backgroundColor: HexColor.dangerAlertBackgroundColor,
      shape: Border.all(color: HexColor.dangerAlertBorderColor),
      content: Text(message, style: TextStyle(color: HexColor.dangerAlertTextColor),),
    ));
  }


}