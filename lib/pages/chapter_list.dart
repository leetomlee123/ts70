import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ts70/main.dart';
import 'package:ts70/model/model.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/custom_cache_manager.dart';
import 'package:ts70/utils/event_bus.dart';
import 'package:ts70/utils/screen.dart';

const itemHeight = 45.0;

final v = StateProvider.autoDispose(((ref) => ""));
final index = StateProvider(((ref) => 0));
final chapterProvider = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final vs = ref.watch(v);
  final play = ref.read(playProvider);
  final result = await ListenApi().getChapters70ts(vs, play!.id.toString());
  return result;
});
final option = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final play = ref.read(playProvider);
  final result = await ListenApi().getOptions(play);
  final s = result![play!.idx! ~/ 30].index!;
  ref.read(v.notifier).state = s;
  return result;
});
final chapterTsbProvider = FutureProvider.autoDispose<int?>((ref) async {
  final play = ref.read(playProvider);
  final result = await ListenApi().getChaptersTsb(play!.id ?? "");
  return result;
});

class Chapters extends ConsumerWidget {
  const Chapters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var read = ref.read(playProvider);
    return Visibility(
      replacement: const ChapterList(),
      visible: read!.cover!.contains("tingshubao"),
      child: const Cps70(),
    );
  }
}

final controller = ItemScrollController();

class Cps70 extends ConsumerStatefulWidget{
  const Cps70({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
   return Cps70State();
  }
  
}
class Cps70State extends ConsumerState{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final f = ref.watch(chapterTsbProvider);
    final ff = ref.read(playProvider);
    return f.when(
        data: (data) {
          // controller.scrollTo(index: ff?.idx ?? 0 ,
          //     duration: Duration(seconds: 2),
          //     curve: Curves.easeInOutCubic);
          return ScrollablePositionedList.builder(
            itemScrollController: controller,
            itemCount: data!,
            itemBuilder: ((context, index) {
              final b = ff!.idx == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.pop(context);
                  await audioPlayer.stop();
                  final play = ref.read(playProvider.notifier);
                  play.state = play.state!.copyWith(
                      idx: index, position: 0, url: "", duration: 1);
                  eventBus.fire(PlayEvent());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: Screen.width * .7,
                        child: Text(
                          "第${index + 1}回",
                          style: TextStyle(
                              color: b ? Colors.lightBlue : Colors.black,
                              fontSize: 15),
                          maxLines: 2,
                        ),
                      ),
                      const Spacer(),
                      Offstage(
                        offstage: !b,
                        child: const Icon(
                          Icons.check,
                          color: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
        error: (error, stackTrace) => const Center(
          child: Text(
            'oops...',
          ),
        ),
        loading: () => const Center(
          child: Text(
            'loading...',
          ),
        ));
  }
  
}


class ChapterList70Ts extends ConsumerWidget {
  const ChapterList70Ts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(chapterTsbProvider);
    final ff = ref.read(playProvider);
    return f.when(
        data: (data) {
          // controller.scrollTo(index: ff?.idx ?? 0 ,
          //     duration: Duration(seconds: 2),
          //     curve: Curves.easeInOutCubic);
          return ScrollablePositionedList.builder(
            itemScrollController: controller,
            itemCount: data!,
            itemBuilder: ((context, index) {
              final b = ff!.idx == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.pop(context);
                  await audioPlayer.stop();
                  final play = ref.read(playProvider.notifier);
                  play.state = play.state!.copyWith(
                      idx: index, position: 0, url: "", duration: 1);
                  eventBus.fire(PlayEvent());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: Screen.width * .7,
                        child: Text(
                          "第${index + 1}回",
                          style: TextStyle(
                              color: b ? Colors.lightBlue : Colors.black,
                              fontSize: 15),
                          maxLines: 2,
                        ),
                      ),
                      const Spacer(),
                      Offstage(
                        offstage: !b,
                        child: const Icon(
                          Icons.check,
                          color: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
        error: (error, stackTrace) => const Center(
          child: Text(
            'oops...',
          ),
        ),
        loading: () => const Center(
          child: Text(
            'loading...',
          ),
        ));
  }
}

class ChapterList extends ConsumerWidget {
  const ChapterList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(option);
    final vp = ref.watch(v.notifier);
    return f.when(
        data: (data) {
          return Column(
            children: [
              DropdownButton(
                  iconSize: 40,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                  value: vp.state,
                  items: data!
                      .map((e) => DropdownMenuItem(
                    value: e.index,
                    child: Text(e.name ?? ""),
                  ))
                      .toList(),
                  onChanged: ((value) {
                    ref.read(v.notifier).state = value!;
                  })),
              const Expanded(child: ListPage())
            ],
          );
        },
        error: (error, stackTrace) => const Center(
          child: Text(
            'oops...',
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

final scroll = StateProvider(((ref) => ""));

// ignore: must_be_immutable
class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(chapterProvider);
    final play = ref.read(playProvider);
    return f.when(
        data: (data) {
          final vp = ref.read(v.notifier).state;
          int i = play!.idx! % 30;
          int j = play.idx! ~/ 30 + 1;
          bool currentPage = int.parse(vp) == (j);
          int idx = currentPage ? i - 5 : -3;

          int len = data?.length ?? 0;
          controller.jumpTo(index: idx);
          return
            ScrollablePositionedList.builder(
              itemScrollController: controller,
              itemCount: data?.length ?? 0,
              itemBuilder: ((context, index) {
                final model = data![index];
                final b = index == i && currentPage;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.pop(context);
                    await audioPlayer.stop();
                    final play = ref.read(playProvider.notifier);
                    final vs = ref.read(v.notifier).state;
                    play.state = play.state!.copyWith(
                        idx: index + (int.parse(vs) - 1) * 30,
                        position: 0,
                        url: "",
                        duration: 1);
                    eventBus.fire(PlayEvent());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: Screen.width * .7,
                          child: Text(
                            "${model.name}",
                            style: TextStyle(
                                color: b ? Colors.lightBlue : null,
                                fontSize: 15),
                            maxLines: 2,
                          ),
                        ),
                        const Spacer(),
                        // DownLoadItem(
                        //   index: index,
                        // ),
                        Offstage(
                          offstage: !b,
                          child: const Icon(
                            Icons.check,
                            color: Colors.lightBlue,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
        },
        error: (error, stackTrace) => const Center(
          child: Text('oops...'),
        ),
        loading: () => const Center(
          child: Text('loading...'),
        ));
  }
}

class DownLoadItem extends ConsumerWidget {
  final int? index;
  DownLoadItem({super.key, this.index});
  late var cache = StateProvider.autoDispose<bool>(((ref) {
    final play = ref.read(playProvider.notifier).state;
    return CustomCacheManager.instance
        .getFileFromCache(play!.getCacheKeyByIndex(index.toString())) ==
        null;
  }));
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheProvider = ref.watch(cache);

    return IconButton(
        onPressed: () async {
          final p = ref.read(playProvider.notifier).state;
          final url = await ListenApi().chapterUrl(p);
          await CustomCacheManager.instance.downloadFile(url);
        },
        icon: Icon(
            cacheProvider ? Icons.download_done_outlined : Icons.download));
  }
}
