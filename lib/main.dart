import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ts70/global.dart';
import 'package:ts70/pages/index.dart';

EventBus eventBus = EventBus();

Future<void> main() async {
  runZonedGuarded(() async {
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://041c11e61b9b4dba8b653a646523753b@o924080.ingest.sentry.io/6738525';
        options.tracesSampleRate = 1.0;
      },
    );
    Global.init().then((value) => runApp(const ProviderScope(child: MyApp())));
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
// void main() =>
//     Global.init().then((value) => runApp(const ProviderScope(child: MyApp())));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("app root ");
    }
    return MaterialApp(
      title: '听风',
      theme: ThemeData(
        primaryColor: Colors.blue,
        textTheme: const TextTheme(
          headline1: TextStyle(
              fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.white),
          headline2: TextStyle(
              fontSize: 32.0, fontWeight: FontWeight.w400, color: Colors.white),
          headline3: TextStyle(
              fontSize: 28.0, fontWeight: FontWeight.w400, color: Colors.white),
          headline4: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.w400, color: Colors.white),
          headline6: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.w200, color: Colors.white),
          bodyText1: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w200, color: Colors.white),
          subtitle1: TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.w200, color: Colors.white),
          subtitle2: TextStyle(
              fontSize: 13.0, fontWeight: FontWeight.w200, color: Colors.white),
        ),
        fontFamily: 'Georgia',
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.blue[600]),
      ),
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver(),
        FirebaseAnalyticsObserver(analytics: Global.analytics),
      ],
      home: const Index(),
    );
  }
}
