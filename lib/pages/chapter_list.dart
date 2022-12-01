import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/main.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/event_bus.dart';
import 'package:ts70/utils/screen.dart';

const itemHeight = 45.0;

final v = StateProvider(((ref) => ""));
final index = StateProvider(((ref) => 0));
final chapterProvider = FutureProvider.autoDispose<List<Chapter>?>((ref) async {
  final vs = ref.watch(v);
  final play = ref.read(playProvider);
  final result = await ListenApi().getChapters(vs, play!.id.toString());
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
var controller = ScrollController();

class Chapters extends ConsumerWidget {
  const Chapters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var read = ref.read(playProvider);
    return Visibility(
      replacement: const ChapterList(),
      visible: read!.cover!.contains("tingshubao"),
      child: SingleChildScrollView(controller: controller,child:  const ChapterList70Ts(),),
    );
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
          controller.animateTo(max(0, ff!.idx! - 3) * itemHeight,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
          return ListView.builder(
            shrinkWrap: true,
            controller: controller,
            itemBuilder: ((context, index) {
              final b = ff.idx == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.pop(context);
                  await audioPlayer.stop();
                  final play = ref.read(playProvider.notifier);
                  play.state = play.state!
                      .copyWith(idx: index, position: 0, url: "", duration: 1);
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
                          "第${index+1}回",
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
            itemCount: data,
            itemExtent: itemHeight,
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
          return SingleChildScrollView(
            controller: controller,
            child: Container(
              color: Colors.black,
              child: Column(
                children: [
                  DropdownButton(
                      dropdownColor: Colors.black87,
                      iconSize: 40,
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
          var i = play!.idx! % 30;
          var j = play.idx! ~/ 30 + 1;
          var bool = int.parse(vp) == (j);
          if (bool) {
            controller.animateTo(max(0, i - 3) * itemHeight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear);
          }
          return ListView.builder(
            shrinkWrap: true,
            controller: controller,
            itemBuilder: ((context, index) {
              final model = data![index];
              final b = index == i && bool;
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
                              color: b ? Colors.lightBlue : Colors.white,
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
            itemCount: data?.length??0,
            itemExtent: itemHeight,
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
