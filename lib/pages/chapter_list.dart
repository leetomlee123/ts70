import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';

final v = StateProvider(((ref) => ""));
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
          return Container(
            color: Colors.black,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButton(
                      dropdownColor: Colors.black87,
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
              child: Text('Ops...' ,style: TextStyle(color: Colors.white),),
            ),
        loading: () => const Center(
              child: Text(
                'loading...',
                style: TextStyle(color: Colors.white),
              ),
            ));
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

final scroll = StateProvider(((ref) => ""));

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(chapterProvider);
    final play = ref.read(playProvider);
    // ScrollController(initialScrollOffset: max(0,play!.idx! % 30+1)*40 )
    return f.when(
        data: (data) {
          final vp = ref.read(v.state).state;
          var i = play!.idx! % 30;
          var j = play.idx! ~/ 30 + 1;
          var bool = int.parse(vp) == (j);
          // final controller = ScrollController(initialScrollOffset: i*40);
          // print("init scroller");
          return ListView.builder(
            shrinkWrap: true,
            // controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              final model = data[index];
              final b = index == i && bool;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.pop(context);
                  await audioPlayer.stop();
                  final play = ref.read(playProvider);
                  final vs = ref.read(v.state).state;
                  play!.idx = index + (int.parse(vs) - 1) * 30;
                  play.position = Duration.zero;
                  play.duration = const Duration(seconds: 1);
                  int result =
                      await DataBaseProvider.dbProvider.addVoiceOrUpdate(play);
                  ref.read(refreshProvider.state).state =
                      DateUtil.getNowDateMs();
                  if (kDebugMode) {
                    print('dddd $result');
                  }
                  //资源释放
                  await initResource(ref);
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
                            color: b ? Colors.lightBlue : Colors.white,
                            fontSize: 22),
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
