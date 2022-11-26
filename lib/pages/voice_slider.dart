import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/index.dart';

class VoiceSlider extends ConsumerWidget {
  const VoiceSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(playProvider.select((value) => value!.duration));
    final position = ref.watch(playProvider.select((value) => value!.position));
    final p = ref.read(playProvider.notifier);
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
              p.state = p.state!.copyWith(position: value.toInt());
            },
            onChangeEnd: (double value) async {
              await audioPlayer.seek(Duration(seconds: value.toInt()));
              await audioPlayer.play();
            },
            value: position!.toDouble(),
            label: DateUtil.formatDateMs(
                Duration(seconds: position).inMilliseconds,
                format: 'mm:ss'),
            divisions: duration,
            max: duration!.toDouble(),
            min: -1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                DateUtil.formatDateMs(
                    Duration(seconds: position).inMilliseconds,
                    format: 'mm:ss'),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              const Spacer(),
              Text(
                DateUtil.formatDateMs(
                    Duration(seconds: duration).inMilliseconds,
                    format: 'mm:ss'),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              )
            ],
          ),
        )
      ],
    );
  }
}
