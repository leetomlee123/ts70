import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ts70/main.dart';
import 'package:ts70/pages/chapter_list.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/pages/speed.dart';
import 'package:ts70/pages/timer.dart';
import 'package:ts70/pages/voice_slider.dart';
import 'package:ts70/pages/vpn.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/event_bus.dart';
import 'package:ts70/utils/screen.dart';

const iconSize = 40.0;

class PlayBar extends ConsumerWidget {
  const PlayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(playProvider);
    ref.watch(historyProvider);
    final data = ref.read(playProvider.state).state;
    var ps = ref.read(playProvider.state);
    if (data!.title == null) return Container();
    return Container(
        height: 245,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        width: Screen.width,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.black),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
                            fontSize: 20,
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
                    backgroundImage: CachedNetworkImageProvider(
                        data.cover ?? "",
                        maxWidth: 131,
                        maxHeight: 131),
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
                      if (ref.read(stateEventProvider) ==
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
                      ref.read(positionProvider.state).state = 0;
                      await DataBaseProvider.dbProvider
                          .addVoiceOrUpdate(search.state!);
                      ref.read(refreshProvider.state).state =
                          DateUtil.getNowDateMs();
                      eventBus.fire(PlayEvent());
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
                      ref.read(positionProvider.state).state = 0;


                      await DataBaseProvider.dbProvider
                          .addVoiceOrUpdate(search.state!);
                      ref.read(refreshProvider.state).state =
                          DateUtil.getNowDateMs();
                      eventBus.fire(PlayEvent());
                    },
                    icon: const Icon(Icons.skip_next_outlined)),
                IconButton(
                    iconSize: iconSize,
                    color: Colors.white,
                    onPressed: () async {
                      if (ref.read(stateEventProvider)==
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
        ));
  }
}
