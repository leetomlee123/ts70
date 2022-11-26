import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ts70/pages/history_list.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/pages/online_check.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/pages/search.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context),
      child: Container(
        padding: const EdgeInsets.only(top: 46,left: 10,right: 10),
        color: Colors.transparent,
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 4,
                ),
                Text(
                  '听书楼',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
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
                  ),
                ),
              ],
            )
          ],
        ),
      ),
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
