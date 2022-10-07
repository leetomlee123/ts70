import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/event_bus.dart';

EventBus eventBus = EventBus();
AudioPlayer audioPlayer = AudioPlayer();
late LockCachingAudioSource audioSource;
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

final stateProvider = StateProvider.autoDispose<PlayerState>(
    (ref) => PlayerState(false, ProcessingState.idle));

final save = Provider.autoDispose((ref) {
  ref.watch(stateProvider.select((value) => value.playing));
  final play = ref.read(playProvider);
  DataBaseProvider.dbProvider.addVoiceOrUpdate(play!);
});
final loadProvider = StateProvider.autoDispose((ref) => false);
int completed = 0;
Timer? timerInstance;

class Index extends ConsumerWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    eventBus.on<PlayEvent>().listen((event) async {
      final play = ref.read(playProvider);
      final load = ref.read(loadProvider.state);
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
        audioSource = LockCachingAudioSource(
          Uri.parse(url),
          tag: MediaItem(
            id: '1',
            album: play.title,
            title: "${play.title}-第${(play.idx ?? 0) + 1}回",
            artUri: Uri.parse(play.cover ?? ""),
          ),
        );
        if (kDebugMode) {
          print("loading network resource");
        }
        FirebaseAnalytics.instance.logEvent(
            name: "fetch_source_link",
            parameters: {"sourceData": play.toMap()});

        await audioPlayer.setAudioSource(audioSource);
        final duration = await audioPlayer.load();
        play.duration = duration;
        await audioPlayer.seek(play.position);
        await DataBaseProvider.dbProvider.addVoiceOrUpdate(play);
        ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
        if (kDebugMode) {
          print("play ${audioPlayer.processingState}");
        }
        load.state = false;

        if (event.play) {
          await audioPlayer.play();
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });

    audioPlayer.playerStateStream.listen((event) async {
      final s = ref.read(stateProvider.state);
      final search = ref.read(playProvider.state);
      if (s.state.playing && !event.playing) {
        DataBaseProvider.dbProvider.addVoiceOrUpdate(search.state!);
      }
      if (kDebugMode) {
        print(event.processingState);
      }
      s.state = event;

      switch (event.processingState) {
        case ProcessingState.completed:
          completed += 1;
          break;
        default:
          completed = 0;
      }
      if (completed == 1) {
        await audioSource.clearCache();
        search.state = search.state!.copyWith(
            position: Duration.zero,
            duration: const Duration(seconds: 1),
            url: "",
            idx: search.state!.idx! + 1);
        await DataBaseProvider.dbProvider.addVoiceOrUpdate(search.state!);
        ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
        eventBus.fire(PlayEvent());
      }
    });

    audioPlayer.positionStream.listen((event) {
      final kk = ref.read(stateProvider.state).state;
      if (kk.playing && kk.processingState != ProcessingState.completed) {
        final f = ref.read(playProvider.state);
        f.state = f.state!.copyWith(position: event);
        if (kDebugMode) {
          // print(f.state);
        }
      }
    });

    return const Home();
  }
}
