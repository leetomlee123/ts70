import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/home.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/pages/play_bar.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/Screen.dart';
import 'package:ts70/utils/database_provider.dart';

final pageProvider = Provider<bool>((_)=>false);
final chapterProvider = FutureProvider<ChapterProvider>((ref) async {
  final play = ref.read(playProvider);
  final result = await ListenApi().getChapters(play.value!);
  return ChapterProvider(chapters: result, search: play.value);
});

class ChapterList extends ConsumerWidget {
  const ChapterList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f1 = ref.watch(pageProvider);
    final f = ref.read(chapterProvider);
    final play = ref.read(playProvider).value;
    return f.when(
        data: (data) {
          return SizedBox(
            height: Screen.height*.8,
            child: SingleChildScrollView(
              controller: f.value!.refreshController,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: ((context, index) {
                  final model = data.chapters![index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      Navigator.pop(context);
                      play.idx = index;
                      int result = await DataBaseProvider.dbProvider
                          .addVoiceOrUpdate(play);
                      if (kDebugMode) {
                        print('dddd $result');
                      }
                      await initResource(play, ref);
                      // print("ok");
                      // final state = ref.read(refreshProvider.state);
                      // state.state = state.state ? false : true;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${model.name}",
                            style: TextStyle(
                                color:
                                    index == play!.idx ? Colors.lightBlue : null,
                                fontSize: 22),
                          ),
                          const Spacer(),
                          Offstage(
                            offstage: index != play.idx,
                            child: const Icon(
                              Icons.check,
                              color: Colors.lightBlue,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                itemCount: data.chapters!.length,
                itemExtent: 40,
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
