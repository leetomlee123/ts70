import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/services/services.dart';

final webStateProvider = StateProvider.autoDispose((ref) => 0);

class WebState extends ConsumerWidget {
  const WebState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(webStateProvider);
    streamController.stream.listen((event) {
      if (event is int) {
        ref.read(webStateProvider.notifier).state = event;
        streamController.close();
      }
    });
    return CircleAvatar(
      backgroundColor:
          f == 200 ? const Color.fromARGB(255, 66, 196, 70) : Colors.red,
      radius: 3,
    );
  }
}
