// ignore_for_file: unnecessary_new

import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/search.dart';
import 'package:ts70/pages/web_state.dart';
import 'package:ts70/utils/database_provider.dart';

AudioPlayer audioPlayer = AudioPlayer();
late AudioSource audioSource;
final refreshProvider =
    StateProvider.autoDispose((ref) => DateUtil.getNowDateMs());
final playProvider = StateProvider.autoDispose<Search?>((ref) => Search());
final historyProvider = FutureProvider.autoDispose<List<Search>?>((ref) async {
  final refresh = ref.watch(refreshProvider);
  if (kDebugMode) {
    print('refresh');
  }
  ref.onDispose(() {
    // DataBaseProvider.dbProvider.addVoiceOrUpdate(value!);
    audioPlayer.dispose();
  });
  List<Search> voices = await DataBaseProvider.dbProvider.voices();
  ref.read(playProvider.state).state = voices.first;
  return voices;
});

// final processProvider = StateProvider.autoDispose((ref) {
//   final keyword = ref.watch(playProvider);
//   return keyword.whenOrNull(data:(data){
//     return data!.position!.inMilliseconds;
//   });
// });
final stateProvider = StateProvider.autoDispose<PlayerState>(
    (ref) => PlayerState(false, ProcessingState.idle));

final save = Provider.autoDispose((ref) {
  final f = ref.watch(stateProvider.select((value) => value.playing));
  final play = ref.read(playProvider);
  DataBaseProvider.dbProvider.addVoiceOrUpdate(play!);
});
final loadProvider = StateProvider.autoDispose((ref) => false);

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    audioPlayer.playerStateStream.listen((event) {
      final s = ref.read(stateProvider.state);
      final search = ref.read(playProvider.state);
      if (s.state.playing && !event.playing) {
// int po = ProviderScope.containerOf(context)
//     .read(processProvider.state)
//     .state;
// value!.position = Duration(milliseconds: po);
        DataBaseProvider.dbProvider.addVoiceOrUpdate(search.state!);
      }
      s.state = event;
      if (kDebugMode) {
        print(event.processingState);
      }
      switch (event.processingState) {
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          break;
        case ProcessingState.buffering:
          break;
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          search.state = search.state!
              .copyWith(position: Duration.zero, idx: search.state!.idx! + 1);
          initResource(search.state, ref);
          break;
      }
    });
    audioPlayer.positionStream.listen((event) {
      if (ref.read(stateProvider.state).state.playing) {
        final f = ref.read(playProvider.state);
        f.state = f.state!.copyWith(position: event);
        if (kDebugMode) {}
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2.2,
        title: Row(
          children: const [
            SizedBox(
              width: 4,
            ),
            Text(
              '听书楼',
              style: TextStyle(fontSize: 20),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(7.0, 9, 0, 0), child: WebState()),
            SizedBox(
              width: 14,
            ),
            LoadingWidget()
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(
              Icons.search_outlined,
              size: 25,
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 70, top: 10),
        color: Colors.white10,
        child: const HistoryList(),
      ),
      bottomSheet: const PlayBar(),
      // bottomSheet: const PlayBar()
    );
  }
}

class LoadingWidget extends ConsumerWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(loadProvider);
    return SizedBox(
      height: 14,
      width: 14,
      child: p
          ? LoadingAnimationWidget.fallingDot(
              color: Colors.white,
              size: 20,
            )
          : null,
    );
  }
}
