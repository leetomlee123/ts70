import 'package:bot_toast/bot_toast.dart';
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
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/Screen.dart';

initResource(Search? search, WidgetRef ref) async {
  final state = ref.read(loadProvider.state);
  String url = "";
  state.state = true;
  try {
    url = "";
    url = await ListenApi().chapterUrl(search);
  } catch (e) {
    state.state = false;
  }
  if (url.isEmpty) {
    BotToast.showText(text: "获取资源链接失败,请重试...");
    state.state = false;
    return;
  }
  state.state = false;

  // await audioPlayer.pause();
  try {
    audioSource = AudioSource.uri(
      Uri.parse(url),
      tag: MediaItem(
        id: '1',
        album: search!.title,
        title: "${search.title}-第${search.idx ?? 0 + 1}回",
        artUri: Uri.parse(search.cover ?? ""),
      ),
    );
    if (kDebugMode) {
      print("loading network resource");
    }
    await audioPlayer.setAudioSource(audioSource);
    // await DataBaseProvider.dbProvider.addVoiceOrUpdate(search);
    // ref.read(refreshProvider.state).state=DateUtil.getNowDateMs();
    final duration = await audioPlayer.load();
    final play = ref.read(playProvider.state);
    play.state = play.state!.copyWith(duration: duration);
    await audioPlayer.seek(search.position);

    if (kDebugMode) {
      print("play ${audioPlayer.processingState}");
    }
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
    final data = ref.watch(playProvider);
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            color: Colors.white),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                data!.cover ?? "",
              ),
              radius: 25,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: Text(
                        data.title ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const PositionWidget()
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
            ),
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
    final data = ref.watch(playProvider);
    return Text(
      "${DateUtil.formatDateMs(data!.position!.inMilliseconds, format: 'mm:ss')}/${DateUtil.formatDateMs(data.duration!.inMilliseconds, format: 'mm:ss')}",
      style: const TextStyle(fontSize: 12),
    );
  }
}
