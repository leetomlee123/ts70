import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';

class Speed extends ConsumerWidget {
  const Speed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(speedProvider.state);
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
                const SizedBox(
                  width: 20,
                ),
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
                      p.state = v;
                      await audioPlayer.setSpeed(p.state);
                    },
                    title: Text(
                      "${v}x",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) {
                        const Set<MaterialState> interactiveStates =
                            <MaterialState>{
                          MaterialState.pressed,
                          MaterialState.hovered,
                          MaterialState.focused,
                        };
                        return Colors.blue;
                      }),
                      value: p.state == v,
                      onChanged: (bool? value) async {
                        p.state = v;
                        await audioPlayer.setSpeed(p.state);
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
