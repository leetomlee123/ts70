import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nil/nil.dart';
import 'package:ts70/pages/chapter_list.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/listen_detail.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/Screen.dart';

initResource(WidgetRef ref) async {
  final state = ref.read(loadProvider.state);
  final play = ref.read(playProvider.state);
  String url = "";
  state.state = true;
  try {
    url = "";
    url = await ListenApi().chapterUrl(play.state);
    if (url.isEmpty) {
      // BotToast.showText(text: "fetch resource failed,please try it again");
      state.state = false;
      return;
    }
    audioSource = AudioSource.uri(
      Uri.parse(url),
      tag: MediaItem(
        id: '1',
        album: play.state!.title,
        title: "${play.state!.title}-第${(play.state!.idx ?? 0) + 1}回",
        artUri: Uri.parse(play.state!.cover ?? ""),
      ),
    );
    if (kDebugMode) {
      print("loading network resource");
    }
    await audioPlayer.setAudioSource(audioSource);
    final duration = await audioPlayer.load();
    play.state = play.state!.copyWith(duration: duration);
    await audioPlayer.seek(play.state!.position);
    if (kDebugMode) {
      print("play ${audioPlayer.processingState}");
    }
    state.state = false;
    await audioPlayer.play();
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}

class PlayBar extends ConsumerWidget {
  const PlayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(playProvider.select((value) => value!.id));
    final data = ref.read(playProvider.state).state;
    if (kDebugMode) {
      print("refresh play bar");
    }
    if (data!.title == null) return nil;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ListenDetail()),
      ),
      child: Container(
        height: 70,
        width: Screen.width,
        decoration: const BoxDecoration(
            // borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            color: Colors.black),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(5)),
                clipBehavior: Clip.antiAlias,
                // child: Image.network(data.cover ?? "",height: 45,width: 45,fit: BoxFit.fitWidth,)),
                child: Image(
                    image: CachedNetworkImageProvider(data.cover ?? ""),
                    height: 45,
                    width: 45,
                    fit: BoxFit.fitWidth)),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(
                        data.title ?? "",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                // const PositionWidget()
                Row(
                  children: [
                    const PositionWidget(),
                    Text(
                      "/${DateUtil.formatDateMs(data.duration!.inMilliseconds, format: 'mm:ss')}",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  ],
                )
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
                transitionBuilder: (child, anim) {
                  return ScaleTransition(scale: anim, child: child);
                },
                duration: const Duration(milliseconds: 300),
                child: const PlayButton()),
            const SizedBox(
              width: 5,
            ),
            IconButton(
                onPressed: () => showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: Screen.height * .8,
                        child: const ChapterList(),
                      ),
                    ),
                icon: const Icon(Icons.playlist_play_outlined),
                iconSize: 40,
                color: Colors.white),
            const SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class PositionWidget extends ConsumerWidget {
  const PositionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(playProvider.select((value) => value!.position));
    return Text(
      DateUtil.formatDateMs(data!.inMilliseconds, format: 'mm:ss'),
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}
