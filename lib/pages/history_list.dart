import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/utils/database_provider.dart';

class HistoryList extends ConsumerWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(historyProvider);
    return f.when(
        data: (data) {
          return ListView.builder(
            itemExtent: 100,
            itemBuilder: (ctx, i) {
              final item = data[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  await audioPlayer.pause();

                  int result =
                      await DataBaseProvider.dbProvider.addVoiceOrUpdate(item);
                  if (kDebugMode) {
                    print('dddd $result');
                  }
                  final state = ref.read(refreshProvider.state);
                  state.state = state.state ? false : true;
                  await initResource(item, ref);
                },
                onLongPress: () {
                  BotToast.showWidget(
                      toastBuilder: (void Function() cancelFunc) {
                    return AlertDialog(
                      title: const Text('确定删除此项?',
                          style: TextStyle(fontSize: 17.0)),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            // Get.back();
                            cancelFunc();
                          },
                        ),
                        TextButton(
                          child: const Text('确定'),
                          onPressed: () async {
                            int result = await DataBaseProvider.dbProvider
                                .delById(item.id);
                            if (kDebugMode) {
                              print('dddd $result');
                            }
                            final state = ref.read(refreshProvider.state);
                            state.state = state.state ? false : true;
                            cancelFunc();
                          },
                          // onPressed: () => controller.delete(i),
                        )
                      ],
                    );
                  });
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.deepPurpleAccent,
                      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
                    ),
                    height: 100,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(item.cover ?? ""),
                          radius: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              child: Text(
                                item.title ?? "",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "第${item.idx! + 1}回",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  if (i == 0) return;
                                  // controller.toTop(i);
                                  //
                                  // await controller.audioPlayer.stop();
                                  // await controller.saveState();
                                  // controller.model.value = item;
                                  // controller.idx.value =
                                  //     controller.model.value.idx ?? 0;
                                  // controller.playerState.value =
                                  //     ProcessingState.idle;
                                  //
                                  // await controller.getUrl(controller.idx.value);
                                  //
                                  // await controller.audioPlayer.play();
                                  // controller.detail(item.id.toString());
                                },
                                icon: const Icon(
                                  // controller.history[i].id ==
                                  //         controller.model.value.id
                                  //     ? Icons.music_note_outlined
                                  //     :
                                  Icons.play_arrow_rounded,
                                  size: 35,
                                  color: Colors.white,
                                )),
                            RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                  text: '已听',
                                  style: TextStyle(fontSize: 11),
                                ),
                                TextSpan(
                                  text:
                                      '${((item.idx! + 1) / ((item.count ?? 1) == 0 ? 100 : (item.count ?? 1)) * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: data!.length,
          );
        },
        error: (error, stackTrace) => const Center(
              child: Text('Ops...'),
            ),
        loading: () => const Center(
              child: Text('loading...'),
            ));
  }
}
