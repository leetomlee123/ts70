import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/online_check.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/search.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/event_bus.dart';




class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
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
        color: Colors.black87,
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
