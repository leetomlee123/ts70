import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';

class CountTimer extends ConsumerWidget {
  const CountTimer({super.key});

  timer(v) {
    if (timerInstance?.isActive ?? false) {
      timerInstance!.cancel();
    }
    timerInstance = Timer(Duration(minutes: v), () async {
      await audioPlayer.pause();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(cronProvider.state);
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
                  '定时关闭',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                const Spacer(),
                TextButton(onPressed: (){
                   timerInstance!.cancel();
                   p.state = 0;
                }, child: const Text('取消定时'))
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
                      p.state = v;
                      timer(v);
                    },
                    title: Text(
                      "$v分钟",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) {
                        return Colors.blue;
                      }),
                      value: p.state == v,
                      onChanged: (bool? value) async {
                        p.state = v;
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
