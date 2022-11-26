import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:ts70/pages/index.dart';

final bgProvide = FutureProvider.autoDispose<Color>((ref) async {
  final cover = ref.watch(playProvider.select((value) => value!.cover));
  if (kDebugMode) {
    print("bgImage source url $cover");
  }
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
    CachedNetworkImageProvider(cover!),
    maximumColorCount: 20,
  );
  return paletteGenerator.dominantColor!.color;
});

class BgColor extends ConsumerWidget {
  const BgColor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = ref.watch(bgProvide);
    final defaultBgWidget = Container(
      color: Colors.black,
    );
    return bg.when(
        data: (data) {
          return Container(
            color: data,
          );
        },
        loading: () => defaultBgWidget,
        error: (Object error, StackTrace? stackTrace) => defaultBgWidget);
  }
}
