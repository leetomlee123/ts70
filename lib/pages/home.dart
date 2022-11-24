import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/pages/online_check.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/search.dart';

// ThemeData themeData = ThemeData(textTheme: const TextTheme(bodyText1: TextStyle(color: Colors.white)));

class Home extends ConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fff = ref.watch(playProvider);
    return Container(
      padding: const EdgeInsets.only(top: 36),
      color: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Text('听书楼', style: Theme.of(context).textTheme.headline4),
              const Padding(
                  padding: EdgeInsets.fromLTRB(7.0, 9, 0, 0),
                  child: WebState()),
              const SizedBox(
                width: 14,
              ),
              const LoadingWidget(),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                icon: const Icon(
                  Icons.search_outlined,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryList()),
                  );
                },
                icon: const Icon(
                  Icons.history,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: ref.read(playProvider)!.cover ?? "",
              width: 250,
              height: 250,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(fff!.title ?? "", style: Theme.of(context).textTheme.headline4),
          const SizedBox(
            height: 5,
          ),
          Text("${fff.bookMeta ?? ""}   第${fff.idx! + 1}回",
              style: Theme.of(context).textTheme.subtitle2),
          const Spacer(),
          const PlayBar(),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 2.2,
        title: Row(
          children: const [
            SizedBox(
              width: 4,
            ),
            Text(
              '听书楼',
              style: TextStyle(fontSize: 20),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(7.0, 9, 0, 0), child: WebState()),
            SizedBox(
              width: 14,
            ),
            LoadingWidget()
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(
              Icons.search_outlined,
              size: 25,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryList()),
              );
            },
            icon: const Icon(
              Icons.history,
              size: 25,
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     ref.read(historyProvider).when(
          //           data: (data) async {
          //             await PostGreSqlProvider.dbProvider.syncDbCloud(data??[]);
          //           },
          //           error: (error, stackTrace) {
          //             BotToast.showText(text: error.toString());
          //           },
          //           loading: () {},
          //         );
          //   },
          //   icon: const Icon(
          //     Icons.cloud_sync,
          //     size: 25,
          //   ),
          // )
        ],
      ),
      body: Container(
        color: Colors.transparent,
        child: Stack(
          children: const [
            // HeaderImages(),
            // HeaderCategory(),
            // Ad(),
            Align(
              alignment: Alignment.bottomCenter,
              child: PlayBar(),
            )
          ],
        ),
      ),
      // bottomSheet: const PlayBar(),
    );
  }
}

class LoadingWidget extends ConsumerWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(loadProvider);
    return SizedBox(
      height: 14,
      width: 14,
      child: p
          ? LoadingAnimationWidget.fallingDot(
              color: Colors.white,
              size: 20,
            )
          : null,
    );
  }
}
