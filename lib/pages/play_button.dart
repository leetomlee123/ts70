import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/utils/database_provider.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(stateProvider);
    return IconButton(
        key: ValueKey(f),
        iconSize: 50,
        onPressed: () async {
          if(f.playing){
            await audioPlayer.pause();
            final p = ref.read(playProvider);
            p.whenData((value) =>  DataBaseProvider.dbProvider.addVoiceOrUpdate(value!));
          }else{
            if (f.processingState== ProcessingState.ready) {
              await audioPlayer.play();
            } else {
              final p = ref.read(playProvider);
              p.whenData((value) => initResource(value, ref));
            }
          }
        },
        icon: Icon(f.playing ? Icons.pause : Icons.play_arrow_outlined));
  }
}
