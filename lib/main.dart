import 'package:bot_toast/bot_toast.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/global.dart';
import 'package:ts70/pages/index.dart';

EventBus eventBus = EventBus();

// Future<void> main() async {
//   runZonedGuarded(() async {
//     await SentryFlutter.init(
//       (options) {
//         options.dsn =
//             'https://041c11e61b9b4dba8b653a646523753b@o924080.ingest.sentry.io/6738525';
//         options.tracesSampleRate = 1.0;
//       },
//     );
//     await Global.init();
//     runApp(const ProviderScope(child: MyApp()));
//   }, (exception, stackTrace) async {
//     await Sentry.captureException(exception, stackTrace: stackTrace);
//   });
// }
void main() =>
    Global.init().then((value) => runApp(const ProviderScope(child: MyApp())));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("app root ");
    }
    return MaterialApp(
      title: '听风',
      builder: BotToastInit(),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        textTheme: const TextTheme(
          headline1: TextStyle(
              fontSize: 36.0, fontWeight: FontWeight.bold),
          headline2: TextStyle(
              fontSize: 32.0, fontWeight: FontWeight.w400),
          headline3: TextStyle(
              fontSize: 28.0, fontWeight: FontWeight.w400),
          headline4: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.w400),
          headline6: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.w200),
          bodyText1: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w200),
        ),
        fontFamily: 'Georgia',
      ),
      navigatorObservers: [
        BotToastNavigatorObserver(),
        FirebaseAnalyticsObserver(analytics: Global.analytics),
      ],
      home: const Index(),
    );
  }
}
