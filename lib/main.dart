import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/global.dart';
import 'package:ts70/pages/home.dart';

void main() =>
    Global.init().then((e) => runApp(const ProviderScope(child: MyApp())));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '听风',
      darkTheme: ThemeData.dark(useMaterial3: true),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: const Home(),
    );
  }
}
