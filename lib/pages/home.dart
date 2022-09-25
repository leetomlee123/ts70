import 'dart:async';

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
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';

AudioPlayer audioPlayer = AudioPlayer();
late LockCachingAudioSource audioSource;
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

// AppLifecycleState appLifeCycle = AppLifecycleState.resumed;

// class Index extends StatefulWidget {
//   const Index({super.key});

//   @override
//   State<StatefulWidget> createState() {
//     return IndexState();
//   }
// }

// class IndexState extends State<Index> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); //添加观察者
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     WidgetsBinding.instance.removeObserver(this); //添加观察者
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // appLifeCycle = state;
//     switch (state) {
//       case AppLifecycleState.detached:
//         if (kDebugMode) {
//           print('detached');
//         }
//         // 应用任然托管在flutter引擎上,但是不可见.
//         // 当应用处于这个状态时,引擎没有视图的运行.要不就是当引擎第一次初始化时处于attach视        图中,要不就是由于导航弹出导致的视图销毁后
//         break;
//       case AppLifecycleState.inactive:
//         if (kDebugMode) {
//           print('inactive');
//         }

//         // 应用在一个不活跃的状态,不会收到用户的输入
//         // 在ios上,这个状态相当于应用或者flutter托管的视图在前台不活跃状态运行.当有电话进来时候应用转到这个状态等
//         // 在安卓上,这个状态相当于应用或者flutter托管的视图在前台不活跃状态运行.另外一个activity获得焦点时,应用转到这个状态.比如分屏,电话等
//         //   在这状态的应用应该假设他们是可能被paused的.
//         break;
//       case AppLifecycleState.paused:
//         if (kDebugMode) {
//           print('paused');
//         }

//         //应用当前对于用户不可见,不会响应用户输入,运行在后台.

//         break;
//       case AppLifecycleState.resumed:
//         if (kDebugMode) {
//           print('resumed');
//         }

//         // 应用可见,响应用户输入
//         break;
//       default:
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Home();
//   }
// }
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
        await audioSource.clearCache();
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
    ref.read(historyProvider);

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
          )
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
