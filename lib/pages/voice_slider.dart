import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/seek_bar.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/play_bar.dart';

class VoiceSlider extends ConsumerWidget {
  const VoiceSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(playProvider.select((value) => value!.position));
    final p1 = ref.read(playProvider.state);
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Slider(
            activeColor: Colors.white,
            onChangeStart: (value) async {
              await audioPlayer.pause();
            },
            onChanged: (double value) async {
              p1.state = p1.state!
                  .copyWith(position: Duration(seconds: value.toInt()));
            },
            onChangeEnd: (double value) async {
              await audioPlayer.seek(Duration(seconds: value.toInt()));
              await audioPlayer.play();
            },
            value: p1.state!.position!.inSeconds.toDouble(),
            label: DateUtil.formatDateMs(p1.state!.position!.inMilliseconds,
                format: 'mm:ss'),
            divisions: p1.state!.duration!.inSeconds,
            max: p1.state!.duration!.inSeconds.toDouble(),
            min: -1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const PositionWidget(),
              const Spacer(),
              Text(
                  DateUtil.formatDateMs(p1.state!.duration!.inMilliseconds,
                      format: 'mm:ss'),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }
}
