import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:ts70/global.dart';
import 'package:ts70/main.dart';
import 'package:ts70/model/HistoryNotifier.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/model/model.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/audio_source_stream.dart';
import 'package:ts70/utils/custom_cache_manager.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/event_bus.dart';

late AudioPlayer audioPlayer;
late LockCachingAudioSource audioSource;
// final refreshProvider =
//     StateProvider.autoDispose((ref) => DateUtil.getNowDateMs());
final playProvider = StateProvider.autoDispose<Search?>((ref) {
  var history = Global.history;
  if (history.isNotEmpty) {
    return history.first;
  }
  return Search();
});
final speedProvider = StateProvider.autoDispose<double>((ref) => 1.0);
final downFlagProvider = StateProvider.autoDispose<bool>((ref) => false);
final downPercetProvider = StateProvider.autoDispose<double>((ref) => 0.0);
final cronProvider = StateProvider<int>((ref) => 0);
final bgProvide = FutureProvider.autoDispose<PaletteGenerator>((ref) async {
  final cover = ref.watch(playProvider.select((value) => value!.cover));
  if (kDebugMode) {
    print("bgImage source url $cover");
  }
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
    CachedNetworkImageProvider(cover!),
    maximumColorCount: 20,
  );
  return paletteGenerator;
});
final statePlayProvider = StateProvider<bool>((ref) => false);
final stateEventProvider =
    StateProvider<ProcessingState>((ref) => ProcessingState.idle);
final todosProvider = ChangeNotifierProvider<HistoryNotifier>((ref) {
  return HistoryNotifier();
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
    if (kDebugMode) {
      print("Index init");
    }
    super.initState();
    audioPlayer = AudioPlayer();
    eventBus.on<TimerEvent>().listen((event) {
      ref.read(cronProvider.notifier).state = 0;
    });
    eventBus.on<PlayEvent>().listen((event) async {
      final play = ref.read(playProvider.notifier);
      final load = ref.read(loadProvider.notifier);
      load.state = true;
      String url = play.state!.url ?? "";
      try {
        FileInfo? fileInfo = await CustomCacheManager.instance
            .getFileFromCache(play.state!.getCacheKey());
        if (fileInfo == null) {
          if (url.isEmpty) {
            url = "";
            url = await ListenApi().chapterUrl(play.state);
            if (url.isEmpty) {
              load.state = false;
              return;
            }
          }
        }
        audioSource = LockCachingAudioSource(
          Uri.parse(url),
          cacheFile: fileInfo?.file,
          tag: MediaItem(
            id: '1',
            album: play.state!.title,
            title: "${play.state!.title}-第${(play.state!.idx ?? 0) + 1}回",
            artUri: Uri.parse(play.state!.cover ?? ""),
          ),
        );
        if (kDebugMode) {
          print("loading network resource");
        }

        await audioPlayer.setAudioSource(audioSource);
        final duration = await audioPlayer.load();
        play.state =
            play.state!.copyWith(url: url, duration: duration!.inSeconds);
        await audioPlayer
            .seek(Duration(seconds: play.state!.position!.toInt()));

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
        load.state = false;
      } finally {
        load.state = false;
      }
    });
    audioPlayer.playerStateStream.listen((event) async {
      ref.read(statePlayProvider.notifier).state = event.playing;
      ref.read(stateEventProvider.notifier).state = event.processingState;
      final item = ref.read(playProvider);
      DataBaseProvider.dbProvider.addVoiceOrUpdate(item!);
      if (event.processingState == ProcessingState.completed) {
        final search = ref.read(playProvider.notifier);
        await audioSource.clearCache();
        search.state = search.state!.copyWith(
            position: 0, duration: 1, url: "", idx: search.state!.idx! + 1);

        eventBus.fire(PlayEvent());
      }
    });
    audioPlayer.positionStream.listen((event) {
      if (ref.read(statePlayProvider) &&
          ref.read(stateEventProvider) != ProcessingState.completed) {
        final pp = ref.read(playProvider.notifier);
        pp.state = pp.state!.copyWith(position: event.inSeconds);
      }
    });

    audioPlayer.bufferedPositionStream.listen((event) {
      final pp = ref.read(playProvider.notifier);
      pp.state = pp.state!.copyWith(buffer: event.inSeconds);
    });

    audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace st) {
      if (e is PlayerException) {
        FirebaseAnalytics.instance.logEvent(
            name: "audio_player_error", parameters: {"sourceData": e.message});
      } else {}
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    eventBus.destroy();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        // statusBarColor: Color(0xFFF2F3F7),        //状态栏背景颜色
        statusBarIconBrightness: Brightness.dark // dark:一般显示黑色   light：一般显示白色
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const SafeArea(child: Home())
        //     Container(
        //   decoration: const BoxDecoration(
        //       image: DecorationImage(
        //           image: AssetImage("assets/background.png"), fit: BoxFit.cover)),
        //   child: const SafeArea(child: Home()),
        // )
        //     Stack(
        //   children: [
        //     Image.asset(
        //       "assets/background.png",
        //       fit: BoxFit.fitWidth,
        //     ),
        //     const SafeArea(child: Home())
        //   ],
        // )
        );
  }
}
