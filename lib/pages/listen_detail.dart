import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ts70/pages/chapter_list.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/utils/Screen.dart';

class ListenDetail extends ConsumerWidget {
  const ListenDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playProvider);
    var ps = ref.read(playProvider.state);

    return Scaffold(
      appBar: AppBar(
        title: Text(p!.title ?? ""),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                width: 100,
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(p.cover ?? ""),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("第${(p.idx ?? 0) + 1}集"),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(p.bookMeta ?? ""),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.menu_open_outlined,
                            size: 32,
                          ),
                          Text("播放列表"),
                        ],
                      ),
                      onTap: () => showMaterialModalBottomSheet(
                        context: context,
                        builder: (context) => SizedBox(
                          height: Screen.height * .8,
                          child: const ChapterList(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.fast_forward,
                            size: 32,
                          ),
                          Text("倍速"),
                        ],
                      ),
                      onTap: () {},
                    )
                  ],
                ),
              ),
              SizedBox(
                width: Screen.width,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: VoiceSlider(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      iconSize: 40,
                      onPressed: () async {
                        if (ref
                                .read(stateProvider.state)
                                .state
                                .processingState ==
                            ProcessingState.idle) return;
                        int p1 = max(p.position!.inSeconds - 10, 0);
                        ps.state = p.copyWith(position: Duration(seconds: p1));
                        await audioPlayer.seek(ps.state!.position);
                      },
                      icon: const Icon(Icons.replay_10_outlined)),
                  IconButton(
                      iconSize: 40,
                      onPressed: () {
                        if (p.idx == 0) return;
                        p.position = Duration.zero;
                        // p.duration = Duration.zero;
                        p.idx = p.idx! - 1;
                        ps.state =
                            p.copyWith(position: Duration.zero, idx: p.idx);
                        initResource(p, ref);
                      },
                      icon: const Icon(Icons.skip_previous_outlined)),
                  const PlayButton(),
                  IconButton(
                      iconSize: 40,
                      onPressed: () {
                        p.position = Duration.zero;
                        // p.duration = Duration.zero;
                        p.idx = p.idx! + 1;
                        ps.state =
                            p.copyWith(position: Duration.zero, idx: p.idx);
                        initResource(p, ref);
                      },
                      icon: const Icon(Icons.skip_next_outlined)),
                  IconButton(
                      iconSize: 40,
                      onPressed: () async {
                        if (ref
                                .read(stateProvider.state)
                                .state
                                .processingState ==
                            ProcessingState.idle) return;
                        int p1 = min(p.position!.inSeconds + 10,
                            ps.state!.duration!.inSeconds);
                        ps.state = p.copyWith(position: Duration(seconds: p1));
                        await audioPlayer.seek(ps.state!.position);
                      },
                      icon: const Icon(Icons.forward_10_outlined)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoiceSlider extends ConsumerWidget {
  const VoiceSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playProvider);
    return Row(
      children: [
        Text(
          DateUtil.formatDateMs(p!.position!.inMilliseconds, format: 'mm:ss'),
        ),
        Expanded(
          child: SizedBox(
            height: 40,
            child: Slider(
              onChangeStart: (value) {},
              onChanged: (double value) {},
              onChangeEnd: (double value) {},
              value: p.position!.inSeconds.toDouble(),
              label: DateUtil.formatDateMs(p.position!.inMilliseconds, format: 'mm:ss'),
              min: .0,
              divisions: p
              .duration!.inSeconds,
              max: p.duration!.inSeconds.toDouble(),
            ),
          ),
        ),
        Text(
          DateUtil.formatDateMs(p.duration!.inMilliseconds, format: 'mm:ss'),
        ),
      ],
    );
  }
}
