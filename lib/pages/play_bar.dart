import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ts70/pages/chapter_list.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_button.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/Screen.dart';
import 'package:ts70/utils/database_provider.dart';

// initResource(BuildContext context) async {
//   final loadState =
//   ProviderScope.containerOf(context).read(loadProvider.state);
//   Search? search =
//       ProviderScope.containerOf(context).read(playProvider).value;
//
//   String url = "";
//   loadState.state = true;
//   try {
//     url = "";
//     url = await ListenApi().chapterUrl(search);
//   } catch (e) {
//     loadState.state = false;
//   }
//   if (url.isEmpty) {
//     BotToast.showText(text: "获取资源链接失败,请重试...");
//     loadState.state = false;
//     return;
//   }
//   await audioPlayer.pause();
//   try {
//     audioSource = AudioSource.uri(
//       Uri.parse(url),
//       tag: MediaItem(
//         id: '1',
//         album: search!.title,
//         title: "${search.title}-第${search.idx ?? 0 + 1}回",
//         artUri: Uri.parse(search.cover ?? ""),
//       ),
//     );
//     await audioPlayer.setAudioSource(audioSource);
//     var duration = (await audioPlayer.load())!;
//     search.duration = duration;
//     // await DataBaseProvider.dbProvider.addVoiceOrUpdate(search);
//     // final state = ref.read(refreshProvider.state);
//     // state.state = state.state ? false : true;
//     loadState.state = false;
//     await audioPlayer.seek(search.position);
//     await audioPlayer.play();
//   } on PlayerException catch (e) {
//     loadState.state = false;
//     // playerState.value = ProcessingState.idle;
//     // playing.value = false;
//     BotToast.showText(text: "加载音频资源失败,请重试....");
//   } on PlayerInterruptedException catch (e) {
//     print("Connection aborted: ${e.message}");
//     await audioPlayer.pause();
//   } catch (e) {}
//   return 1;
// }
initResource(Search? search, var ref) async {
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
    await audioPlayer.setAudioSource(audioSource);
    var duration = (await audioPlayer.load())!;
    search.duration = duration;
    await DataBaseProvider.dbProvider.addVoiceOrUpdate(search);
    final state1 = ref.read(refreshProvider.state);
    state1.state = state1.state ? false : true;
    state.state = false;

    await audioPlayer.seek(search.position);
    audioPlayer.play();
  } on PlayerException catch (e) {
    state.state = false;
    // playerState.value = ProcessingState.idle;
    // playing.value = false;
    BotToast.showText(text: "加载音频资源失败,请重试....");
  } on PlayerInterruptedException catch (e) {
    if (kDebugMode) {
      print("Connection aborted: ${e.message}");
    }
    // await audioPlayer.pause();
  } catch (e) {}
  return 1;
}

next() {}

class PlayBar extends ConsumerWidget {
  const PlayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(playProvider);
    return f.when(
        data: (data) {
          return GestureDetector(
            // onTap: () => Get.toNamed(AppRoutes.detail),
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
                      builder: (context) => const ChapterList(),
                    ),
                    icon: const Icon(Icons.playlist_play_outlined),
                    iconSize: 50,
                  ),
                  const SizedBox(
                    width: 10,
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

class PositionWidget extends ConsumerWidget {
  const PositionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.read(playProvider).value;
    final data1 = ref.watch(processProvider);

    return Text(
      "${DateUtil.formatDateMs(data1, format: 'mm:ss')}/${DateUtil.formatDateMs(data!.duration!.inMilliseconds, format: 'mm:ss')}",
      style: const TextStyle(fontSize: 12),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}
