import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/services/services.dart';

final webStateProvider = StateProvider.autoDispose((ref) => 0);

class WebState extends ConsumerWidget {
  const WebState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(webStateProvider.state);
    streamController.stream.listen((event) {
      if (event is int) {
        f.state = event;
        streamController.close();
      }
    });
    final errorWidget = Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
    final okWidget = Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 66, 196, 70),
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
    return f.state == 200 ? okWidget : errorWidget;
  }
}
