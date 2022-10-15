import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/main.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/event_bus.dart';

late AudioPlayer audioPlayer;
final refreshProvider =
    StateProvider.autoDispose((ref) => DateUtil.getNowDateMs());
final playProvider = StateProvider.autoDispose<Search?>((ref) => Search());
final speedProvider = StateProvider.autoDispose<double>((ref) => 1.0);
final cronProvider = StateProvider<int>((ref) => 0);
final historyProvider = FutureProvider.autoDispose<List<Search>?>((ref) async {
  ref.watch(refreshProvider);
  List<Search> history = await DataBaseProvider.dbProvider.voices();
  if (history.isNotEmpty) {
    ref.read(playProvider.state).state = history.first;
  }
  return history;
});

final stateProvider =
    StateProvider.autoDispose<PlayerState>((ref) => PlayerState.stopped);

final save = Provider.autoDispose((ref) {
  ref.watch(stateProvider);
  final play = ref.read(playProvider);
  DataBaseProvider.dbProvider.addVoiceOrUpdate(play!);
});
final loadProvider = StateProvider.autoDispose((ref) => false);
Timer? timerInstance;

class Index extends ConsumerStatefulWidget {
  const Index({super.key});

  @override
  IndexState createState() => IndexState();
}

class IndexState extends ConsumerState {
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    eventBus.on<PlayEvent>().listen((event) async {
      final play = ref.read(playProvider);
      final load = ref.read(loadProvider.state);
      if (load.state) return;
      load.state = true;
      String url = play!.url ?? "";
      try {
        if (url.isEmpty) {
          url = "";
          url = await compute(ListenApi().chapterUrl, play);
          if (url.isEmpty) {
            load.state = false;
            return;
          }
          play.url = url;
        }
        // await audioPlayer.play(UrlSource(url));
        await audioPlayer.setSourceUrl(url);
        final duration = await audioPlayer.getDuration();
        play.duration = duration;
        await audioPlayer.seek(play.position ?? const Duration(seconds: 0));
        await DataBaseProvider.dbProvider.addVoiceOrUpdate(play);
        ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
        if (kDebugMode) {
          print("play ${audioPlayer.state}");
        }
        if (event.play) {
          await audioPlayer.play(UrlSource(url));
        }
        load.state = false;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });

    audioPlayer.onPlayerStateChanged.listen(
      (event) async {
        final s = ref.read(stateProvider.state);
        final search = ref.read(playProvider.state);
        // if (s.state.playing && !event.playing) {
        //   DataBaseProvider.dbProvider.addVoiceOrUpdate(search.state!);
        // }
        if (s.state == PlayerState.playing && !(event != PlayerState.playing)) {
          DataBaseProvider.dbProvider.addVoiceOrUpdate(search.state!);
        }
        if (kDebugMode) {
          print(event.name);
        }
        s.state = event;
        if (event == PlayerState.completed) {
          await audioPlayer.audioCache
              .clear(Uri.parse(search.state!.url ?? ""));
          search.state = search.state!.copyWith(
              position: Duration.zero,
              duration: const Duration(seconds: 1),
              url: "",
              idx: search.state!.idx! + 1);
          await DataBaseProvider.dbProvider.addVoiceOrUpdate(search.state!);
          ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
          eventBus.fire(PlayEvent());
        }
      },
      onDone: () {},
    );
    audioPlayer.onPositionChanged.listen((event) {
      final kk = ref.read(stateProvider.state).state;
      if (kk == PlayerState.playing) {
        final f = ref.read(playProvider.state);
        f.state = f.state!.copyWith(position: event);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    eventBus.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return const Home();
  }
}
