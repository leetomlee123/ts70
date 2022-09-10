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
    final p = ref.read(playProvider.state);
    return IconButton(
        key: ValueKey(f),
        iconSize: 45,
        onPressed: () async {
          if(f.playing){
            await audioPlayer.pause();
            await DataBaseProvider.dbProvider.addVoiceOrUpdate(p.state!);
          }else{
            if (f.processingState== ProcessingState.ready) {
             await audioPlayer.play();
            } else {
             initResource(ref);
            }
          }
        },
        icon: Icon(f.playing ? Icons.pause : Icons.play_arrow_rounded,color: Colors.white,));
  }
}
