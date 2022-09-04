// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/play_status.dart';
import 'package:ts70/pages/search.dart';
import 'package:ts70/pages/web_state.dart';

final loadProvider = StateProvider.autoDispose((ref) => false);
late AudioPlayer audioPlayer;
late AudioSource audioSource;


class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    audioPlayer=AudioPlayer();
    return Scaffold(
        appBar: AppBar(
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
                  padding: EdgeInsets.fromLTRB(7.0, 9, 0, 0),
                  child: WebState()),
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
                  new MaterialPageRoute(
                      builder: (context) => const SearchPage()),
                );
              },
              icon: const Icon(
                Icons.search_outlined,
                size: 25,
              ),
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.only(bottom: 70, top: 10),
          color: Colors.white70,
          child: const HistoryList(),
        ),
        bottomSheet: const PlayStatus());
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
