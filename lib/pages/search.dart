import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/services.dart';
import 'package:ts70/utils/database_provider.dart';

final keyProvider = StateProvider.autoDispose((ref) => '');
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
    // TODO: implement initState
    super.initState();
    scrollController!.addListener(() {
      focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
            ),
            onPressed: () {},
          ),
          border: InputBorder.none),
    );
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
            itemBuilder: ((context, index) {
              final model = data[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  int result =
                      await DataBaseProvider.dbProvider.addVoiceOrUpdate(model);
                  if (kDebugMode) {
                    print('dddd $result');
                  }
                  final state = ref.read(refreshProvider.state);
                  state.state = state.state ? false : true;
                },
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: model.cover ?? "",
                        fit: BoxFit.cover,
                        width: 80,
                        height: 120,
                        placeholder: (context, url) =>
                            LoadingAnimationWidget.dotsTriangle(
                          color: Colors.white,
                          size: 60,
                        ),
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
                                  fontWeight: FontWeight.bold, fontSize: 20),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              model.desc ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.clip,
                            ),
                            Text(
                              model.bookMeta ?? "",
                              maxLines: 1,
                            ),
                          ],
                        ),
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
              child: Text('loading...'),
            ));
  }
}
