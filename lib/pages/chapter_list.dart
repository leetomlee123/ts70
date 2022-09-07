import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/loading.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';

final v = StateProvider(((ref) => ""));
ScrollController scrollController = ScrollController();
final chapterProvider = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final vs = ref.watch(v);
  final play = ref.read(playProvider);
  final result = await ListenApi().getChapters(vs, play!.id.toString());
  return result;
});
final option = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final play = ref.watch(playProvider);
  final result = await ListenApi().getOptions(play);
  final s = result![play!.idx! ~/ 30].index!;
  ref.read(v.state).state = s;
  return result;
});

class ChapterList extends ConsumerWidget {
  const ChapterList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(option);
    final vp = ref.watch(v.state);
    return f.when(
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              children: [
                DropdownButton(
                    // isExpanded: true,
                    // 图标大小
                    iconSize: 40,
                    // 下拉文本样式
                    style: const TextStyle(color: Colors.blue),
                    value: vp.state,
                    items: data!
                        .map((e) => DropdownMenuItem(
                              value: e.index,
                              child: Text(e.name ?? ""),
                            ))
                        .toList(),
                    onChanged: ((value) {
                      vp.state = value!;
                    })),
                const ListPage()
              ],
            ),
          );
        },
        error: (error, stackTrace) => const Center(
              child: Text('Ops...'),
            ),
        loading: () => const Loading());
  }
}

class MyCustomClass {
  WidgetRef ref;
  int index;

  MyCustomClass(this.ref, this.index);

  Future<void> myAsyncMethod(
      BuildContext context, VoidCallback onSuccess) async {
    final play = ref.read(playProvider);
    if (index == play!.idx) return;
    play.position = Duration.zero;
    play.duration = Duration.zero;
    final vs = ref.read(v.state).state;
    play.idx = index + (int.parse(vs) - 1) * 30;
    int result = await DataBaseProvider.dbProvider.addVoiceOrUpdate(play);
    ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
    if (kDebugMode) {
      print('dddd $result');
    }
    //资源释放
    await audioPlayer.pause();
    onSuccess.call();
  }
}

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(chapterProvider);
    final play = ref.read(playProvider);

    return f.when(
        data: (data) {
          return SingleChildScrollView(
            // controller: ScrollController(initialScrollOffset: max(0,play!.idx! % 30+1)*40 ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                final model = data[index];
                final vp = ref.read(v.state).state;
                final b = (index == (play!.idx! % 30) &&
                    int.parse(vp) == (play.idx! ~/ 30 + 1));
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.pop(context);
                    final play = ref.read(playProvider);
                    int result = await DataBaseProvider.dbProvider
                        .addVoiceOrUpdate(play!);
                    play.position = Duration.zero;
                    final vs = ref.read(v.state).state;
                    play.idx = index + (int.parse(vs) - 1) * 30;
                    // ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
                    if (kDebugMode) {
                      print('dddd $result');
                    }
                    //资源释放
                    await audioPlayer.stop();
                    await initResource(play, ref);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${model.name}",
                          style: TextStyle(
                              color: b ? Colors.lightBlue : null, fontSize: 22),
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
              itemCount: data!.length,
              itemExtent: 40,
            ),
          );
        },
        error: (error, stackTrace) => const Center(
              child: Text('Ops...'),
            ),
        loading: () => const Loading());
  }
}
