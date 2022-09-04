import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/Screen.dart';
initResource(Search? search, var ref) async {
  audioPlayer.playerStateStream.listen((state) {
    switch (state.processingState) {
      case ProcessingState.idle:
        break;
      case ProcessingState.loading:
        break;
      case ProcessingState.buffering:
        break;
      case ProcessingState.ready:
        break;
      case ProcessingState.completed:
        next();
        break;
    }
  });
  audioPlayer.positionStream.listen((Duration p) {
    // if (!moving.value) {
    //   if (audioPlayer.playing &&
    //       playerState.value != ProcessingState.completed) {
    //     // Get.log(playerState.value.name);
    //
    //     model.update((val) {
    //       val!.position = p;
    //     });
    //   }
    // }
  });
  String url = "";
  ref.read(loadProvider.state).state=true;
  try {
    url = "";
    url = await ListenApi().chapterUrl(search);
  } catch (e) {
    ref.read(loadProvider.state).state=false;
  }
  if (url.isEmpty) {
    BotToast.showText(text: "获取资源链接失败,请重试...");
    ref.read(loadProvider.state).state=false;
    return;
  }
  await audioPlayer.pause();
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
    await audioPlayer.setAudioSource(audioSource);
    var duration = (await audioPlayer.load())!;
    search.duration = duration;
    // await DataBaseProvider.dbProvider.addVoiceOrUpdate(search);
    // final state = ref.read(refreshProvider.state);
    // state.state = state.state ? false : true;
    ref.read(loadProvider.state).state=false;

    await audioPlayer.seek(search.position);
    await audioPlayer.play();
  } on PlayerException catch (e) {
    ref.read(loadProvider.state).state=false;
    // playerState.value = ProcessingState.idle;
    // playing.value = false;
    BotToast.showText(text: "加载音频资源失败,请重试....");
  } on PlayerInterruptedException catch (e) {
    print("Connection aborted: ${e.message}");
    await audioPlayer.pause();
  } catch (e) {
  }
  return 1;
}
final processProvider=Provider((ref) => "");
final playProvider = FutureProvider.autoDispose<Search?>((ref) {
  final keyword = ref.watch(historyProvider);
  Search? search=keyword.value![0];
  return search;
});
next(){}
class PlayBar extends ConsumerWidget {
  const PlayBar({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(playProvider);
    return f.when(
        data: (data) {
          initResource(data, ref);
          return GestureDetector(
            // onTap: () => Get.toNamed(AppRoutes.detail),
            child: Container(
              height: 70,
              width: Screen.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
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
                            width: 180,
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
                      Text(
                        "${DateUtil.formatDateMs(data.position!.inMilliseconds, format: 'mm:ss')}/${DateUtil.formatDateMs(data.duration!.inMilliseconds, format: 'mm:ss')}",
                        style: const TextStyle(fontSize: 12),
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
                    onPressed: () => {
                      // if (model.value.count! > 0)
                      //   {
                      //     Get.bottomSheet(
                      //       ListenChapters(),
                      //       elevation: 2,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(20.0),
                      //           topRight: Radius.circular(20.0),
                      //         ),
                      //       ),
                      //     )
                      //   }
                    },
                    icon: const Icon(Icons.playlist_play_outlined),
                    iconSize: 30,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => const Center(
              child: Text('Ops...'),
            ),
        loading: () => const Center(
              child: Text('loading...'),
            ));
  }
}
