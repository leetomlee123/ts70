import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/listen.dart';

final vpns = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final result = await ListenApi().imageLink();
  return result;
});

class Vpn extends ConsumerWidget {
  const Vpn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(vpns);
    return f.when(
        data: (data) {
          return Container(
            color: Colors.black,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return ListTile(
                    title: Text(
                      item.name ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.index));
                          BotToast.showText(text: 'paste success');
                        }),
                  );
                },
                itemCount: data!.length,
                itemExtent: 45,
              ),
            ),
          );
        },
        error: (error, stackTrace) => const Center(
              child: Text(
                'Ops...',
                style: TextStyle(color: Colors.white),
              ),
            ),
        loading: () => const Center(
              child: Text(
                'loading...',
                style: TextStyle(color: Colors.white),
              ),
            ));
  }
}
