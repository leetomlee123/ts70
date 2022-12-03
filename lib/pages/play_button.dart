import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ts70/main.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/utils/event_bus.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});
  Widget _buildLoadingView() {
    return const SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(statePlayProvider);
    final p = ref.watch(loadProvider);
    return IconButton(
        iconSize: 60,
        key: ValueKey(f),
        onPressed: () async {
          if (f) {
            await audioPlayer.pause();
          } else {
            if (ref.read(stateEventProvider) == ProcessingState.ready) {
              await audioPlayer.play();
            } else {
              eventBus.fire(PlayEvent());
            }
          }
        },
        icon: p
            ? _buildLoadingView()
            : Icon(
                f ? Icons.pause : Icons.play_arrow_rounded,
              ));
  }
}
