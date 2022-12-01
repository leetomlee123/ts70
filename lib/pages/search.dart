import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/model/SearchNotifier.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/utils/database_provider.dart';

// final keyProvider = StateProvider.autoDispose((ref) => '');
// final topProvider = StateProvider.autoDispose((ref) => true);
// final sProvider = FutureProvider.autoDispose<List<TopRank>?>((ref) async {
//   final ss = await ListenApi().getTop("");
//   return ss;
// });
// final resultProvider = FutureProvider.autoDispose<List<Search>?>((ref) async {
//   final keyword = ref.watch(keyProvider);
//
//   return await ListenApi().search(keyword);
// });
final searchProvider = ChangeNotifierProvider<SearchNotifier>((ref) {
  return SearchNotifier();
});
final FocusNode focusNode = FocusNode();

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return SearchViewState();
  }
}

class SearchViewState extends State<SearchPage> {
  final ScrollController? scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController!.addListener(() {
      focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Input(),

      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Result(),
        ),
      ),
    );
  }
}

class Input extends ConsumerWidget {
  final TextEditingController _textEditingController = TextEditingController();

  Input({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      autofocus: false,
      focusNode: focusNode,
      cursorHeight: 25,
      controller: _textEditingController,
      onChanged: (v) {
        ref.read(searchProvider.notifier).search(v);
      },
      decoration: InputDecoration(
          hintText: 'Search',
          alignLabelWithHint: true,
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.close_outlined,
            ),
            onPressed: () {
              _textEditingController.text = "";
              ref.read(searchProvider.notifier).clear();
            },
          ),
          border: InputBorder.none),
    );
  }
}

//
// class ViewBody extends ConsumerWidget {
//   const ViewBody({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final p = ref.watch(topProvider);
//     return p ? const Top() : const Result();
//   }
// }
//
// class Top extends ConsumerWidget {
//   const Top({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final f = ref.watch(sProvider);
//     return f.when(
//         data: (data) {
//           return ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemBuilder: ((context, index) {
//               final model = data[index];
//               return GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: () async {
//                   // Navigator.of(context).pop();
//                   // await audioPlayer.pause();
//                   // int result = await DataBaseProvider.dbProvider
//                   //     .addVoiceOrUpdate(model);
//                   // ref.read(refreshProvider.state).state =
//                   //     DateUtil.getNowDateMs();
//                   // await audioPlayer.stop();
//                 },
//                 child: Container(
//                   height: 100,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 10,
//                   ),
//                   child: Column(
//                     children: [
//                       Text(model.name ?? ""),
//                       Row(
//                         children: [
//                           const Icon(Icons.person),
//                           Text(model.a ?? ""),
//                           const Spacer(),
//                           const Icon(Icons.voice_chat),
//                           Text(model.b ?? "")
//                         ],
//                       )
//                     ],
//                   ),
//                   // child: ListTile(
//                 ),
//               );
//             }),
//             itemCount: data!.length,
//             itemExtent: 130,
//           );
//         },
//         error: (error, stackTrace) => const Center(
//               child: Text('Ops...'),
//             ),
//         loading: () => const Center(
//                 child: Text(
//               'loading...',
//               style: TextStyle(color: Colors.white),
//             )));
//   }
// }

class Result extends ConsumerWidget {
  const Result({super.key});

  format(String url) {
    print(url);
    if (url.contains("70")) {
      return "麒麟听书";
    } else {
      return "听书宝";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(searchProvider);
    return ListView.builder(
      cacheExtent: 500,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      addRepaintBoundaries: false,
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        final model = f.result[index];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            Navigator.of(context).pop();
            await audioPlayer.stop();
            await DataBaseProvider.dbProvider.addVoiceOrUpdate(model);
            ref.read(playProvider.notifier).state = model;
            // eventBus.fire(PlayEvent(play: false));
          },
          child: Container(
            height: 110,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CachedNetworkImage(
                    imageUrl: model.cover ?? "",
                    fit: BoxFit.cover,
                    maxWidthDiskCache: 157,
                    maxHeightDiskCache: 210,
                    width: 60,
                    height: 80,
                    // ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                            model.title ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              // color: Colors.white
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(format(
                              model.cover ?? "",
                            )),
                          )
                        ],
                      ),
                      Text(
                        model.desc ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          // color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        model.bookMeta ?? "",
                        maxLines: 1,
                        style: const TextStyle(
                          // color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // child: ListTile(
          ),
        );
      },
      itemCount: f.result.length,
      itemExtent: 110,
    );
    // return f.when(
    //     data: (data) {
    //       return ListView.builder(
    //         cacheExtent: 500,
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         addRepaintBoundaries: false,
    //         addAutomaticKeepAlives: false,
    //         itemBuilder: (context, index) {
    //           final model = data[index];
    //
    //           return  GestureDetector(
    //               behavior: HitTestBehavior.opaque,
    //               onTap: () async {
    //                 Navigator.of(context).pop();
    //                 await audioPlayer.stop();
    //                 await DataBaseProvider.dbProvider.addVoiceOrUpdate(model);
    //                 ref.read(playProvider.notifier).state = model;
    //                 // eventBus.fire(PlayEvent(play: false));
    //               },
    //               child: Container(
    //                 height: 100,
    //                 padding: const EdgeInsets.symmetric(
    //                   vertical: 10,
    //                 ),
    //                 child: Row(
    //                   children: [
    //                     CachedNetworkImage(
    //                       imageUrl: model.cover ?? "",
    //                       fit: BoxFit.cover,
    //                       maxWidthDiskCache: 157,
    //                       maxHeightDiskCache: 210,
    //                       width: 60,
    //                       height: 80,
    //                       // ),
    //                       errorWidget: (context, url, error) =>
    //                           const Icon(Icons.error),
    //                     ),
    //                     const SizedBox(
    //                       width: 20,
    //                     ),
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                         children: [
    //                           Text(
    //                             model.title ?? "",
    //                             style: const TextStyle(
    //                                 fontWeight: FontWeight.bold,
    //                                 fontSize: 16,
    //                                 color: Colors.white),
    //                             maxLines: 1,
    //                             overflow: TextOverflow.ellipsis,
    //                           ),
    //                           Text(
    //                             model.desc ?? "",
    //                             maxLines: 2,
    //                             overflow: TextOverflow.clip,
    //                             style: const TextStyle(
    //                               color: Colors.white,
    //                               fontSize: 14,
    //                             ),
    //                           ),
    //                           Text(
    //                             model.bookMeta ?? "",
    //                             maxLines: 1,
    //                             style: const TextStyle(
    //                               color: Colors.white,
    //                               fontSize: 14,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     )
    //                   ],
    //                 ),
    //                 // child: ListTile(
    //               ),
    //
    //           );
    //         },
    //         itemCount: data!.length,
    //         itemExtent: 110,
    //       );
    //     },
    //     error: (error, stackTrace) => const Center(
    //           child: Text('Ops...'),
    //         ),
    //     loading: () => const Center(
    //             child: Text(
    //           'loading...',
    //           style: TextStyle(color: Colors.white),
    //         )));
  }
}
