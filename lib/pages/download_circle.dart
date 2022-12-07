import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ts70/model/DownloadNotifier.dart';
final searchProvider = ChangeNotifierProvider.autoDispose<DownloadNotifier>((ref) {
  return DownloadNotifier();
});
class DownloadCircle extends ConsumerWidget {
  const DownloadCircle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final percent=ref.watch(searchProvider);

    return CircularPercentIndicator(
      radius: 10.0,
      lineWidth: 5.0,
      percent: percent.temp,
      // center: Text("100%"),
      progressColor: Colors.black,
    );
  }
}
