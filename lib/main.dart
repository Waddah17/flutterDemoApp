import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'features/Home/presentation/home_page.dart';
import 'exceptions/my_erros_handler.dart';
import 'constants/keys.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  MyErrorsHandler.initialize();
  FlutterError.onError = (details) async {
    FlutterError.presentError(details);
    MyErrorsHandler.onErrorDetails(details);
  };

  PlatformDispatcher.instance.onError = (error, stack){
    MyErrorsHandler.onError(error, stack);
    return true;
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      scaffoldMessengerKey: snackbarKey ,
      title: 'TheVendor',
      // used by the OS task switcher
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizations.delegate
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale("ar", "AE"),
      theme: theme(),
      home: const HomePage(title: "البائع"),
      builder: (context, widget) {
        Widget error = const Text('');

        if (widget is Scaffold || widget is Navigator) {
          error = Scaffold(body: Center(child: error));
        }

        ErrorWidget.builder = (errorDetails) => error;
        if (widget != null) {
          return widget;
        }
        throw ('widget is null');
      },
    );
  }
}
