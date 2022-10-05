import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ts70/global.dart';
import 'package:ts70/pages/home.dart';

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
    return MaterialApp(
      title: '听风',
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver(),
        FirebaseAnalyticsObserver(analytics: Global.analytics),
      ],
      home: const Index(),
    );
  }
}
