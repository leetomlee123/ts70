import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/global.dart';
import 'package:ts70/pages/home.dart';


void main() =>
    Global.init().then((value) => runApp(const ProviderScope(child: MyApp())));


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '听风',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver(),observer],
      home: const Home(),
    );
  }
}
