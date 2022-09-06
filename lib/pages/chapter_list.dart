import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/loading.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/Screen.dart';
import 'package:ts70/utils/database_provider.dart';

final v = StateProvider(((ref) => ""));
ScrollController scrollController = ScrollController();
final chapterProvider = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final vs = ref.watch(v);
  final play = ref.read(playProvider);
  final result = await ListenApi().getChapters(vs, play.value!.id.toString());
  return result;
});
final option = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  print("load options");
  final play = ref.watch(playProvider);
  final result = await ListenApi().getOptions(play.value);
  final s = result![play.value!.idx! ~/ 30].index!;
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
          return SizedBox(
            height: Screen.height * .8,
            child: SingleChildScrollView(
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
            ),
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

class MyCustomClass {
  WidgetRef ref;
  int index;
  MyCustomClass(this.ref, this.index);
  Future<void> myAsyncMethod(
      BuildContext context, VoidCallback onSuccess) async {
    final play = ref.read(playProvider).value;
    if (index == play!.idx) return;
    play.position = Duration.zero;
    play.duration = Duration.zero;
    final vs = ref.read(v.state).state;
    play.idx = index + (int.parse(vs) - 1) * 30;
    int result = await DataBaseProvider.dbProvider.addVoiceOrUpdate(play);
    final state = ref.read(refreshProvider.state);
    if (kDebugMode) {
      print('dddd $result');
    }
    state.state = state.state ? false : true;
    //资源释放
    await audioPlayer.stop();

    onSuccess.call();
  }
}

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(chapterProvider);
    final play = ref.read(playProvider).value;

    return f.when(
        data: (data) {
          // scrollController=ScrollController(initialScrollOffset:(play!.idx! % 30)*40 );
          return SingleChildScrollView(
            controller: scrollController,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                final model = data[index];
                final b = index == (play!.idx! % 30);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => MyCustomClass(ref, index).myAsyncMethod(context,
                      () async {
                    Navigator.pop(context);
                    await initResource(play, ref);
                  }),
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
