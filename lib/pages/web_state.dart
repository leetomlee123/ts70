import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/services/services.dart';

final  webStateProvider = FutureProvider.autoDispose((ref) async {
  return await ListenApi().checkSite("sk");
});

class WebState extends ConsumerWidget {
  const WebState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(webStateProvider);
    final errorWidget = Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
    return f.when(
      data: (data) {
        return Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 66, 196, 70),
              borderRadius: BorderRadius.all(Radius.circular(5))),
        );
      },
      loading: () => errorWidget,
      error: (error, stackTrace) => errorWidget,
    );
  }
}
