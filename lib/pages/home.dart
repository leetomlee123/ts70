// ignore_for_file: unnecessary_new

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/search.dart';
import 'package:ts70/pages/web_state.dart';
import 'package:ts70/utils/database_provider.dart';

final refreshProvider = StateProvider.autoDispose((ref) => false);
final historyProvider = FutureProvider.autoDispose<List<Search>?>((ref) async {
  final refresh = ref.watch(refreshProvider);
  if (kDebugMode) {
    print('refresh');
  }
  return await DataBaseProvider.dbProvider.voices();
});
final processProvider = Provider((ref) => "");
final stateProvider = StateProvider.autoDispose<PlayerState>(
    (ref) => PlayerState(false, ProcessingState.idle));
final watchProvider = Provider.autoDispose((ref) {
  final p = ref.watch(stateProvider);
  switch (ref.read(stateProvider.state).state.processingState) {
    case ProcessingState.idle:
      print('idle');
      break;
    case ProcessingState.loading:
      print('loading');
      break;
    case ProcessingState.buffering:
      print('buffering');
      break;
    case ProcessingState.ready:
      print('ready');
      break;
    case ProcessingState.completed:
      print('completed');
      next();
      break;
  }
});
final playProvider = FutureProvider.autoDispose<Search?>((ref) {
  final keyword = ref.watch(historyProvider);
  Search? search = keyword.value![0];
  return search;
});
final save = Provider.autoDispose((ref) {
  final f = ref.watch(stateProvider.select((value) => value.playing));
  final play = ref.read(playProvider);
  DataBaseProvider.dbProvider.addVoiceOrUpdate(play.value!);
});
final loadProvider = StateProvider.autoDispose((ref) => false);
late AudioPlayer audioPlayer;
late AudioSource audioSource;

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioPlayer.playerStateStream.listen((event) {
      ProviderScope.containerOf(context).read(stateProvider.state).state =
          event;
    });
    audioPlayer.positionStream.listen((Duration p) {
      // if (!moving.value) {
      //   if (audioPlayer.playing &&
      //       playerState.value != ProcessingState.completed) {
      //     // Get.log(playerState.value.name);
      //
      //     model.update((val) {
      //       val!.position = p;
      //     });
      //   }
      // }
    });

    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
