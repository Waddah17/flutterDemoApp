import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thevendor/shared/components/snack_bar.dart';
import '../constants/configurations.dart';

class MyErrorsHandler {
  static int lastLogTime = DateTime.now().millisecondsSinceEpoch;

  static void initialize() async {}

  static void onErrorDetails(FlutterErrorDetails errorDetails) async {
    if (DateTime.now().millisecondsSinceEpoch - lastLogTime > 2000) {
      await LogApi.logAsync(errorDetails.exceptionAsString(), errorDetails.stack.toString());
      lastLogTime = DateTime.now().millisecondsSinceEpoch;
    }
    // ErrorWidget(errorDetails.exception);
  }

  static void onError(Object error, StackTrace stackTrace) async {
    if (error.toString() == "Exception") {
      return;
    }
    if (DateTime.now().millisecondsSinceEpoch - lastLogTime > 2000) {
      await LogApi.logAsync(error.toString(), stackTrace.toString());
      lastLogTime = DateTime.now().millisecondsSinceEpoch;
    }
    // ErrorWidget(error);
  }

  static void display400ErrorMessage(Map<String, dynamic> json) {
    var message = json['modelState'].entries.map((entry) => entry.value[0]).toList()[0];
    CustomSnackBar.dangerAlertUsingKey(message);
  }

  static void displayExceptionMessage(String message) {
    CustomSnackBar.dangerAlertUsingKey(message);
  }

  static void handleException(Exception ex) {
    //TODO store exceptions in nosql database
    if (ex is TimeoutException) {
      MyErrorsHandler.displayExceptionMessage("حصل خطأ. يرجى المحاولة مجددا");
    }
    else if (ex is SocketException) {
      MyErrorsHandler.displayExceptionMessage("جهازك غير متصل بالانترنت");
    }
    else{
      MyErrorsHandler.displayExceptionMessage("حصل خطأ. يرجى المحاولة مجددا");
    }
  }
}

class LogApi {
  static Future logAsync(String message, String stackTrace) async {
    final url = Uri.parse('${ApiConfigurations.BaseUrl}/Logs/mobile');

    final response = await http.post(
      url,
      headers: ApiConfigurations.JsonContentType,
      body: jsonEncode(<String, String>{'message': message, 'stackTrace': stackTrace}),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      throw Exception();
    }
  }
}
