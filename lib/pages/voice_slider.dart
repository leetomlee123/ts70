import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/index.dart';

class VoiceSlider extends ConsumerWidget {
  const VoiceSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(positionProvider);
    final p1 = ref.read(playProvider.state);
    final p = ref.read(positionProvider.state);
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
              p.state =  value.toInt();
            },
            onChangeEnd: (double value) async {
              await audioPlayer.seek(Duration(seconds: value.toInt()));
              await audioPlayer.play();
            },
            value: p.state.toDouble(),
            label: DateUtil.formatDateMs(Duration(seconds: p.state).inMilliseconds,
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
            children: const [
              PositionWidget(),
              Spacer(),
              DurationWidget(),
            ],
          ),
        )
      ],
    );
  }
}

class PositionWidget extends ConsumerWidget {
  const PositionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(positionProvider);
    return Text(
      DateUtil.formatDateMs(Duration(seconds: data).inMilliseconds, format: 'mm:ss'),
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}

class DurationWidget extends ConsumerWidget {
  const DurationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(playProvider);
    return Text(
      DateUtil.formatDateMs(data!.duration!.inMilliseconds, format: 'mm:ss'),
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}
