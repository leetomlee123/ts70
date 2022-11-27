import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/index.dart';

class Speed extends ConsumerWidget {
  const Speed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(speedProvider);
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_outlined,
                      color: Colors.white,
                    )),
                const Text(
                  '播放速度调节',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ],
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: 9,
                itemExtent: 40,
                itemBuilder: (ctx, i) {
                  var v = (.5 + (.25 * i));
                  return ListTile(
                    onTap: () async {
                      // controller.fast.value = v;
                      // Get.back();
                      ref.read(speedProvider.notifier).state = v;
                      await audioPlayer.setSpeed(p);
                    },
                    title: Text(
                      "${v}x",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) {
                        return Colors.blue;
                      }),
                      value: p == v,
                      onChanged: (bool? value) async {
                          ref.read(speedProvider.notifier).state = v;
                        await audioPlayer.setSpeed(p);
                      },
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
