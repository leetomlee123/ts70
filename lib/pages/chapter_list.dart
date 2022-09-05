import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/Screen.dart';
import 'package:ts70/utils/database_provider.dart';

final v = StateProvider(((ref) => ""));
ScrollController _refreshController = ScrollController();
final chapterProvider = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final vs = ref.watch(v);
  final play = ref.read(playProvider);
  final result = await ListenApi().getChapters(vs, play.value!.id.toString());
  return result;
});
final option = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
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
  Search model;
  MyCustomClass(this.model, this.ref);

  Future<void> myAsyncMethod(
      BuildContext context, VoidCallback onSuccess) async {
    int result = await DataBaseProvider.dbProvider.addVoiceOrUpdate(model);
    if (kDebugMode) {
      print('dddd $result');
    }
    final state = ref.read(refreshProvider.state);
    state.state = state.state ? false : true;
    onSuccess.call();
  }
}

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final play = ref.read(playProvider).value;
    final f = ref.watch(chapterProvider);
    return f.when(
        data: (data) {
          return SingleChildScrollView(
            controller: _refreshController,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                final model = data[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.pop(context);
                    await audioPlayer.pause();
                    play.idx = index;
                    int result = await DataBaseProvider.dbProvider
                        .addVoiceOrUpdate(play);
                    if (kDebugMode) {
                      print('dddd $result');
                    }
                    await initResource(play, ref);
                    // print("ok");
                    // final state = ref.read(refreshProvider.state);
                    // state.state = state.state ? false : true;
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
                              color:
                                  index == play!.idx ? Colors.lightBlue : null,
                              fontSize: 22),
                        ),
                        const Spacer(),
                        Offstage(
                          offstage: index != play.idx,
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
        loading: () => const Center(
              child: Text('loading...'),
            ));
  }
}
