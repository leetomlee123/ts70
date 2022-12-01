import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:ts70/utils/event_bus.dart';
import 'package:ts70/utils/screen.dart';

class PlayBar extends ConsumerWidget {
  const PlayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: const [
        VoiceSlider(),
        VoiceActionBar(),
        ToolBar(),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}

class VoiceActionBar extends ConsumerWidget {
  const VoiceActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ps = ref.read(playProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            onPressed: () async {
              if (ref.read(stateEventProvider) == ProcessingState.idle) {
                return;
              }
              int p1 = max(ps.state!.position! - 10, 0);
              ps.state = ps.state!.copyWith(position: p1);
              await audioPlayer.seek(Duration(seconds: p1));
            },
            icon: const Icon(Icons.replay_10_outlined)),
        IconButton(
            onPressed: () async {
              if (ps.state!.idx == 0) return;
              final search = ref.read(playProvider.notifier);
              await audioPlayer.stop();
              search.state = search.state!.copyWith(
                  position: 0,
                  duration: 1,
                  url: "",
                  idx: search.state!.idx! - 1);
              eventBus.fire(PlayEvent());
            },
            icon: const Icon(Icons.skip_previous_outlined)),
        const PlayButton(),
        IconButton(
            onPressed: () async {
              final search = ref.read(playProvider.notifier);
              await audioPlayer.stop();
              search.state = search.state!.copyWith(
                  position: 0,
                  duration: 1,
                  url: "",
                  idx: search.state!.idx! + 1);

              eventBus.fire(PlayEvent());
            },
            icon: const Icon(Icons.skip_next_outlined)),
        IconButton(
            onPressed: () async {
              if (ref.read(stateEventProvider) == ProcessingState.idle) {
                return;
              }
              int p1 = min(ps.state!.position! + 10, ps.state!.duration!);
              ps.state = ps.state!.copyWith(position: p1);
              await audioPlayer.seek(Duration(seconds: p1));
            },
            icon: const Icon(Icons.forward_10_outlined)),
      ],
    );
  }
}

class ToolBar extends ConsumerWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              showMaterialModalBottomSheet(
                context: context,
                // backgroundColor: Colors.black,
                builder: (context) => SizedBox(
                  height: Screen.height * .7,
                  child: const Chapters(),
                ),
              );
            },
            icon: const Icon(
              Icons.menu,
            )),
        const Spacer(),
        IconButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: "187905651"));
              BotToast.showText(text: "QQ群号已复制到粘贴板");
            },
            icon: const Icon(
              Icons.support_agent,
            )),
        // IconButton(
        //     onPressed: () async {
        //       showMaterialModalBottomSheet(
        //         context: context,
        //         backgroundColor: Colors.black,
        //         builder: (context) => SizedBox(
        //           height: Screen.height * .7,
        //           child: const Vpn(),
        //         ),
        //       );
        //     },
        //     icon: const Icon(
        //       Icons.vpn_lock,
        //     )),
        IconButton(
            onPressed: () {
              showMaterialModalBottomSheet(
                context: context,
                // backgroundColor: Colors.black,
                builder: (context) => SizedBox(
                  height: Screen.height * .7,
                  child: const Speed(),
                ),
              );
            },
            icon: const Icon(
              Icons.speed,
            )),
        IconButton(
            onPressed: () {
              showMaterialModalBottomSheet(
                context: context,
                // backgroundColor: Colors.black,
                builder: (context) => SizedBox(
                  height: Screen.height * .7,
                  child: const CountTimer(),
                ),
              );
            },
            icon: const Icon(
              Icons.timer,
            ))
      ],
    );
  }
}

class VoiceInfo extends ConsumerWidget {
  const VoiceInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(playProvider.select((value) => value!.id));
    final title = ref.watch(playProvider.select((value) => value!.title));
    final bookMeta = ref.watch(playProvider.select((value) => value!.bookMeta));
    final idx = ref.watch(playProvider.select((value) => value!.idx));
    final cover = ref.watch(playProvider.select((value) => value!.cover));

    return Visibility(
      visible: id != null,
      replacement: const SizedBox(
        height: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          ClipOval(
            child: Image(
              image: CachedNetworkImageProvider(cover ?? ""),
              height: 230,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            title ?? "",
            style: const TextStyle(
                fontSize: 20,  fontWeight: FontWeight.bold),
          ),
          Text(
            "${bookMeta ?? ""}   第${idx! + 1}回",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
