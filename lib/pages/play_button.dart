import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ts70/main.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/event_bus.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(stateProvider.select((value) => value.playing));
    final p = ref.read(playProvider.state);
    return IconButton(
        key: ValueKey(f),
        iconSize: 45,
        onPressed: () async {
          if (f) {
            await audioPlayer.pause();
            await DataBaseProvider.dbProvider.addVoiceOrUpdate(p.state!);
          } else {
            if (ref.read(stateProvider).processingState== ProcessingState.ready) {
              await audioPlayer.play();
            } else {
              eventBus.fire(PlayEvent());
            }
          }
        },
        icon: Icon(
          f ? Icons.pause : Icons.play_arrow_rounded,
          color: Colors.white,
        ));
  }
}
