import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
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
    final f = ref.read(historyProvider);
    final view = f.when(
        data: (data) {
          return ListView.builder(
            itemExtent: 90,
            itemBuilder: (ctx, i) {
              final item = data[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.pop(context);
                  await audioPlayer.stop();
                  int result =
                      await DataBaseProvider.dbProvider.addVoiceOrUpdate(item);
                  if (kDebugMode) {
                    print('dddd $result');
                  }
                  ref.read(refreshProvider.state).state =
                      DateUtil.getNowDateMs();
                  ref.read(playProvider.state).state = item;
                  await initResource(context);
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
                            ref.read(refreshProvider.state).state =
                                DateUtil.getNowDateMs();
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
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.black,
                      // boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
                    ),
                    height: 90,
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
                              width: 200,
                              child: Text(
                                item.title ?? "",
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              item.bookMeta ?? "",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '第${item.idx! + 1}回',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(
                          width: 20,
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
              child: Text(''),
            ),
        loading: () => const Center(
              child: Text(
                'loading...',
                style: TextStyle(color: Colors.white),
              ),
            ));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("历史记录"),
      ),
      body: Container(
        color: Colors.black87,
        child: view,
      ),
    );
  }
}
