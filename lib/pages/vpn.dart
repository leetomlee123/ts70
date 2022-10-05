import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/listen.dart';

class VpnView extends ConsumerWidget {
  const VpnView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: Vpn()
      ),
    );
  }
}

final vpns = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final result = await ListenApi().imageLink();
  return result;
});
final check = StateProvider.autoDispose<int>((ref) => -1);

class Vpn extends ConsumerWidget {
  const Vpn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(vpns);
    final cc = ref.watch(check.state);
    return f.when(
        data: (data) {
          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  title: Text(
                    item.name ?? "",
                    style: const TextStyle(
                         fontWeight: FontWeight.bold,fontSize: 18),
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        cc.state == index ? Icons.check : Icons.copy,
                      ),
                      onPressed: () {
                        cc.state = index;
                        Clipboard.setData(ClipboardData(text: item.index));
                      }),
                );
              },
              itemCount: data!.length,
              itemExtent: 45,
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
