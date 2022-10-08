import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/main.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/services.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/event_bus.dart';

final keyProvider = StateProvider.autoDispose((ref) => '');
final topProvider = StateProvider.autoDispose((ref) => true);
final sProvider = FutureProvider.autoDispose<List<TopRank>?>((ref) async {
  final ss = await ListenApi().getTop("");
  return ss;
});
final resultProvider = FutureProvider.autoDispose<List<Search>?>((ref) async {
  final keyword = ref.watch(keyProvider);
  final cancelToken = CancelToken();
  // 当provider被销毁时，取消http请求
  ref.onDispose(() => cancelToken.cancel());
  return await ListenApi().search(keyword, cancelToken);
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
        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          controller: scrollController,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Result(),
          ),
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
      cursorColor: Colors.white,
      cursorHeight: 25,
      controller: _textEditingController,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) {
        ref.read(keyProvider.state).state = v;
      },
      decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.white),
          alignLabelWithHint: true,
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.close_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              _textEditingController.text = "";
              ref.read(keyProvider.state).state = '';
            },
          ),
          border: InputBorder.none),
    );
  }
}

class MyCustomClass {
  WidgetRef ref;
  Search model;

  MyCustomClass(this.model, this.ref);

  Future<void> myAsyncMethod(
      BuildContext context, VoidCallback onSuccess) async {
    int result = await DataBaseProvider.dbProvider.addVoiceOrUpdate(model);
    if (kDebugMode) {
      print('dddd $result');
    }
    ref.read(refreshProvider.state).state = DateUtil.getNowDateMs();
    onSuccess.call();
  }
}

class ViewBody extends ConsumerWidget {
  const ViewBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(topProvider);
    return p ? const Top() : const Result();
  }
}

class Top extends ConsumerWidget {
  const Top({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(sProvider);
    return f.when(
        data: (data) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              final model = data[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  // Navigator.of(context).pop();
                  // await audioPlayer.pause();
                  // int result = await DataBaseProvider.dbProvider
                  //     .addVoiceOrUpdate(model);
                  // ref.read(refreshProvider.state).state =
                  //     DateUtil.getNowDateMs();
                  // await audioPlayer.stop();
                },
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Text(model.name ?? ""),
                      Row(
                        children: [
                          const Icon(Icons.person),
                          Text(model.a ?? ""),
                          const Spacer(),
                          const Icon(Icons.voice_chat),
                          Text(model.b ?? "")
                        ],
                      )
                    ],
                  ),
                  // child: ListTile(
                ),
              );
            }),
            itemCount: data!.length,
            itemExtent: 130,
          );
        },
        error: (error, stackTrace) => const Center(
              child: Text('Ops...'),
            ),
        loading: () => const Center(
                child: Text(
              'loading...',
              style: TextStyle(color: Colors.white),
            )));
  }
}

class Result extends ConsumerWidget {
  const Result({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(resultProvider);
    return f.when(
        data: (data) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            addRepaintBoundaries: false,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final model = data[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.of(context).pop();
                  await audioPlayer.stop();
                  await DataBaseProvider.dbProvider.addVoiceOrUpdate(model);
                  ref.read(refreshProvider.state).state =
                      DateUtil.getNowDateMs();
                  ref.read(playProvider.state).state = model;
                  eventBus.fire(PlayEvent(play: false));
                },
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CachedNetworkImage(
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
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              model.title ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              model.desc ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              model.bookMeta ?? "",
                              maxLines: 1,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  // child: ListTile(
                ),
              );
            },
            itemCount: data!.length,
            itemExtent: 130,
          );
        },
        error: (error, stackTrace) => const Center(
              child: Text('Ops...'),
            ),
        loading: () => const Center(
                child: Text(
              'loading...',
              style: TextStyle(color: Colors.white),
            )));
  }
}
