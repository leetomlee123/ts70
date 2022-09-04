import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/play_status.dart';


class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(playingProvider);
    return IconButton(
        key: ValueKey(f),
        iconSize: 50,
        onPressed: () {
          final state=ref.read(playingProvider.state);
          state.state=state.state?false:true;
        },
        icon: Icon(f ? Icons.pause : Icons.play_arrow_outlined));
  }
}
