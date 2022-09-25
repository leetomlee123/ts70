import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ts70/pages/chapter_list.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/listen_detail.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/pages/speed.dart';
import 'package:ts70/pages/timer.dart';
import 'package:ts70/pages/voice_slider.dart';
import 'package:ts70/pages/vpn.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/screen.dart';
import 'package:ts70/utils/database_provider.dart';

initResource(BuildContext context) async {
  ProviderContainer ref = ProviderScope.containerOf(context);
  final state = ref.read(loadProvider.state);
  final play = ref.read(playProvider.state);
  String url = play.state!.url ?? "";
  state.state = true;
  try {
    if (play.state!.url!.isEmpty) {
      url = "";
      url = await compute(ListenApi().chapterUrl, play.state);
      if (url.isEmpty) {
        // BotToast.showText(text: "fetch resource failed,please try it again");
        state.state = false;
        return;
      }
      play.state = play.state!.copyWith(url: url);
      await DataBaseProvider.dbProvider.addVoiceOrUpdate(play.state!);
    }
    audioSource = LockCachingAudioSource(
      Uri.parse(url),
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
    play.state = play.state!.copyWith(duration: duration);
    await audioPlayer.seek(play.state!.position);
    if (kDebugMode) {
      print("play ${audioPlayer.processingState}");
    }
    state.state = false;
    await DataBaseProvider.dbProvider.addVoiceOrUpdate(play.state!);
    // await audioPlayer.setSpeed(20);
    await audioPlayer.play();
  } catch (e) {
    state.state = false;
    if (kDebugMode) {
      print(e);
    }
  }
}

class PlayBar extends ConsumerWidget {
  const PlayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(playProvider);
    ref.watch(historyProvider);
    final data = ref.read(playProvider.state).state;
    var ps = ref.read(playProvider.state);
    if (kDebugMode) {
      print("refresh play bar");
    }
    if (data!.title == null) return Container();
    return Container(
        height: 250,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        width: Screen.width,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.black),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title ?? "",
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${data.bookMeta ?? ""}   第${data.idx! + 1}回",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(data.cover ?? ""),
                    radius: 25,
                  ),
                ],
              ),
            ),
            const VoiceSlider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    iconSize: iconSize,
                    color: Colors.white,
                    onPressed: () async {
                      if (ref.read(stateProvider.state).state.processingState ==
                          ProcessingState.idle) return;
                      int p1 = max(ps.state!.position!.inSeconds - 10, 0);
                      ps.state =
                          ps.state!.copyWith(position: Duration(seconds: p1));
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
                          url: "",
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
                          url: "",
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
                      if (ref.read(stateProvider.state).state.processingState ==
                          ProcessingState.idle) return;
                      int p1 = min(ps.state!.position!.inSeconds + 10,
                          ps.state!.duration!.inSeconds);
                      ps.state =
                          ps.state!.copyWith(position: Duration(seconds: p1));
                      await audioPlayer.seek(ps.state!.position);
                    },
                    icon: const Icon(Icons.forward_10_outlined)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      showMaterialModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        builder: (context) => SizedBox(
                          height: Screen.height * .7,
                          child: const ChapterList(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    )),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: "187905651"));
                      BotToast.showText(text: "QQ群号已复制到粘贴板");
                    },
                    icon: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () async {

                      showMaterialModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        builder: (context) => SizedBox(
                          height: Screen.height * .7,
                          child: const Vpn(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.vpn_lock,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      showMaterialModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        builder: (context) => SizedBox(
                          height: Screen.height * .7,
                          child: const Speed(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.speed,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      showMaterialModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        builder: (context) => SizedBox(
                          height: Screen.height * .7,
                          child: const CountTimer(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.timer,
                      color: Colors.white,
                    ))
              ],
            )
          ],
        )
        // child: Row(
        //   children: [
        //     const SizedBox(
        //       width: 10,
        //     ),
        //     Image(
        //       image: CachedNetworkImageProvider(data.cover ?? ""),
        //       height: 40,
        //       width: 40,
        //       fit: BoxFit.fitWidth,
        //     ),
        //     const SizedBox(
        //       width: 10,
        //     ),
        //     Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Row(
        //           children: [
        //             SizedBox(
        //               width: 160,
        //               child: Text(
        //                 data.title ?? "",
        //                 style:
        //                     const TextStyle(fontSize: 18, color: Colors.white),
        //               ),
        //             ),
        //           ],
        //         ),
        //         const SizedBox(
        //           height: 10,
        //         ),
        //         // const PositionWidget()
        //         Row(
        //           children: [
        //             const PositionWidget(),
        //             Text(
        //               "/${DateUtil.formatDateMs(data.duration!.inMilliseconds, format: 'mm:ss')}",
        //               style: const TextStyle(fontSize: 12, color: Colors.white),
        //             )
        //           ],
        //         )
        //       ],
        //     ),
        //     const Spacer(),
        //     AnimatedSwitcher(
        //         transitionBuilder: (child, anim) {
        //           return ScaleTransition(scale: anim, child: child);
        //         },
        //         duration: const Duration(milliseconds: 300),
        //         child: const PlayButton()),
        //     const SizedBox(
        //       width: 5,
        //     ),
        //     IconButton(
        //         onPressed: () => showMaterialModalBottomSheet(
        //               context: context,
        //               builder: (context) => SizedBox(
        //                 height: Screen.height * .8,
        //                 child: const ChapterList(),
        //               ),
        //             ),
        //         icon: const Icon(Icons.playlist_play_outlined),
        //         iconSize: 40,
        //         color: Colors.white),
        //     const SizedBox(
        //       width: 30,
        //     ),
        //   ],
        // ),

        );
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ListenDetail()),
      ),
      child: Container(
        height: 70,
        width: Screen.width,
        decoration: const BoxDecoration(
            // borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            color: Colors.black),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Image(
              image: CachedNetworkImageProvider(data.cover ?? ""),
              height: 40,
              width: 40,
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(
                        data.title ?? "",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                // const PositionWidget()
                Row(
                  children: [
                    const PositionWidget(),
                    Text(
                      "/${DateUtil.formatDateMs(data.duration!.inMilliseconds, format: 'mm:ss')}",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  ],
                )
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
                transitionBuilder: (child, anim) {
                  return ScaleTransition(scale: anim, child: child);
                },
                duration: const Duration(milliseconds: 300),
                child: const PlayButton()),
            const SizedBox(
              width: 5,
            ),
            IconButton(
                onPressed: () => showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: Screen.height * .8,
                        child: const ChapterList(),
                      ),
                    ),
                icon: const Icon(Icons.playlist_play_outlined),
                iconSize: 40,
                color: Colors.white),
            const SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class PositionWidget extends ConsumerWidget {
  const PositionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(playProvider.select((value) => value!.position));
    return Text(
      DateUtil.formatDateMs(data!.inMilliseconds, format: 'mm:ss'),
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}
