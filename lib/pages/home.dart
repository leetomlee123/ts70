import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/online_check.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/search.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/postgresql_provider.dart';

AudioPlayer audioPlayer = AudioPlayer();
late AudioSource audioSource;
final refreshProvider =
    StateProvider.autoDispose((ref) => DateUtil.getNowDateMs());
final playProvider = StateProvider.autoDispose<Search?>((ref) => Search());
final speedProvider = StateProvider.autoDispose<double>((ref) => 1.0);
final cronProvider = StateProvider.autoDispose<int>((ref) => 0);
final historyProvider = FutureProvider.autoDispose<List<Search>?>((ref) async {
  if (kDebugMode) {
    print('start refresh');
  }
  ref.watch(refreshProvider);
  if (kDebugMode) {
    print('end refresh');
  }
  List<Search> history = await DataBaseProvider.dbProvider.voices();
  if (history.isNotEmpty) {
    ref.read(playProvider.state).state = history.first;
  }
  return history;
});

final stateProvider = StateProvider.autoDispose<PlayerState>(
    (ref) => PlayerState(false, ProcessingState.idle));

final save = Provider.autoDispose((ref) {
  final f = ref.watch(stateProvider.select((value) => value.playing));
  final play = ref.read(playProvider);
  DataBaseProvider.dbProvider.addVoiceOrUpdate(play!);
});
final loadProvider = StateProvider.autoDispose((ref) => false);
int completed = 0;
Timer? timerInstance;


class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    ProviderContainer ref = ProviderScope.containerOf(context);

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
        // await audioSource.clearCache();
        search.state = search.state!.copyWith(
            position: Duration.zero,
            duration: const Duration(seconds: 1),
            url: "",
            idx: search.state!.idx! + 1);
        await DataBaseProvider.dbProvider.addVoiceOrUpdate(search.state!);
        ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
        await initResource(context);
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

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
//  ref.read(historyProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
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
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(
              Icons.search_outlined,
              size: 25,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryList()),
              );
            },
            icon: const Icon(
              Icons.history,
              size: 25,
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     ref.read(historyProvider).when(
          //           data: (data) async {
          //             await PostGreSqlProvider.dbProvider.syncDbCloud(data??[]);
          //           },
          //           error: (error, stackTrace) {
          //             BotToast.showText(text: error.toString());
          //           },
          //           loading: () {},
          //         );
          //   },
          //   icon: const Icon(
          //     Icons.cloud_sync,
          //     size: 25,
          //   ),
          // )
        ],
      ),
      body: Container(
        color: Colors.black87,
        child: Stack(
          children: const [
            // HeaderImages(),
            // HeaderCategory(),
            // Ad(),
            Align(
              alignment: Alignment.bottomCenter,
              child: PlayBar(),
            )
          ],
        ),
      ),
      // bottomSheet: const PlayBar(),
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
