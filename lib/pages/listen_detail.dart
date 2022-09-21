import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ts70/pages/ad.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/pages/voice_slider.dart';
import 'package:ts70/utils/Screen.dart';
import 'package:ts70/utils/database_provider.dart';
const iconSize=40.0;
class ListenDetail extends ConsumerWidget {
  const ListenDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   ref.watch(playProvider.select((value) => value!.idx));
   ref.watch(playProvider.select((value) => value!.id));
    var ps = ref.read(playProvider.state);

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  width: 100,
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(ps.state!.cover ?? ""),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "第${(ps.state!.idx ?? 0) + 1}集",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(ps.state!.bookMeta ?? "",
                      style: const TextStyle(color: Colors.white)),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       GestureDetector(
                //         child: Column(
                //           children: const [
                //             Icon(
                //               Icons.menu_open_outlined,
                //               size: 32,
                //             ),
                //             Text("播放列表"),
                //           ],
                //         ),
                //         onTap: () => showMaterialModalBottomSheet(
                //           context: context,
                //           builder: (context) => SizedBox(
                //             height: Screen.height * .8,
                //             child: const ChapterList(),
                //           ),
                //         ),
                //       ),
                //       GestureDetector(
                //         child: Column(
                //           children: const [
                //             Icon(
                //               Icons.fast_forward,
                //               size: 32,
                //             ),
                //             Text("倍速"),
                //           ],
                //         ),
                //         onTap: () {},
                //       )
                //     ],
                //   ),
                // ),
                SizedBox(
                  width: Screen.width,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: VoiceSlider(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        iconSize: iconSize,
                        color: Colors.white,
                        onPressed: () async {
                          if (ref
                                  .read(stateProvider.state)
                                  .state
                                  .processingState ==
                              ProcessingState.idle) return;
                          int p1 = max(ps.state!.position!.inSeconds - 10, 0);
                          ps.state = ps.state!.copyWith(position: Duration(seconds: p1));
                          await audioPlayer.seek(ps.state!.position);
                        },
                        icon: const Icon(Icons.replay_10_outlined)),
                    IconButton(
                        iconSize: iconSize,
                        color: Colors.white,
                        onPressed: () async {
                          if (ps.state!.idx == 0) return;
                          final search = ref.read(playProvider.state);
                          await audioPlayer.stop();
                          search.state = search.state!.copyWith(
                              position: Duration.zero,
                              duration: const Duration(seconds: 1),
                              idx: search.state!.idx! - 1);
                          await DataBaseProvider.dbProvider
                              .addVoiceOrUpdate(search.state!);
                          ref.read(refreshProvider.state).state =
                              DateUtil.getNowDateMs();
                          await initResource(context);
                        },
                        icon: const Icon(Icons.skip_previous_outlined)),
                    const PlayButton(),
                    IconButton(
                        iconSize: iconSize,
                        color: Colors.white,
                        onPressed: () async {
                          final search = ref.read(playProvider.state);
                          await audioPlayer.stop();
                          search.state = search.state!.copyWith(
                              position: Duration.zero,
                              duration: const Duration(seconds: 1),
                              idx: search.state!.idx! + 1);
                          await DataBaseProvider.dbProvider
                              .addVoiceOrUpdate(search.state!);
                          ref.read(refreshProvider.state).state =
                              DateUtil.getNowDateMs();
                          await initResource(context);
                        },
                        icon: const Icon(Icons.skip_next_outlined)),
                    IconButton(
                        iconSize: iconSize,
                        color: Colors.white,
                        onPressed: () async {
                          if (ref
                                  .read(stateProvider.state)
                                  .state
                                  .processingState ==
                              ProcessingState.idle) return;
                          int p1 = min(ps.state!.position!.inSeconds + 10,
                              ps.state!.duration!.inSeconds);
                          ps.state = ps.state!.copyWith(position: Duration(seconds: p1));
                          await audioPlayer.seek(ps.state!.position);
                        },
                        icon: const Icon(Icons.forward_10_outlined)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

