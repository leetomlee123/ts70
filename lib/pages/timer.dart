import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/main.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/utils/event_bus.dart';

class CountTimer extends ConsumerWidget {
  const CountTimer({super.key});

  timer(v) {
    if (timerInstance?.isActive ?? false) {
      timerInstance!.cancel();
    }
    timerInstance = Timer(Duration(minutes: v), () async {
      await audioPlayer.pause();
      eventBus.fire(TimerEvent());
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(cronProvider);
    return SingleChildScrollView(
      child: Container(
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
                    )),
                const Text(
                  '定时关闭',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                     ),
                ),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      timerInstance!.cancel();
                      ref.read(cronProvider.notifier).state = 0;
                    },
                    child: const Text('取消定时'))
              ],
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: 9,
                itemExtent: 40,
                itemBuilder: (ctx, i) {
                  int v = 5 * (i + 1);
                  return ListTile(
                    onTap: () async {
                      ref.read(cronProvider.notifier).state = v;
                      timer(v);
                    },
                    title: Text(
                      "$v分钟",
                    ),
                    trailing: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) {
                        return Colors.blue;
                      }),
                      value: p == v,
                      onChanged: (bool? value) async {
                        ref.read(cronProvider.notifier).state = v;
                        timer(v);
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
