import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:ts70/pages/index.dart';

const Color _kBackgroundColor = Color(0xffa0a0a0);
PaletteGenerator? paletteGenerator;

final bgProvider = FutureProvider.autoDispose<Color>((ref) async {
  final f = ref.watch(playProvider.select((value) => value!.cover));
  paletteGenerator = await PaletteGenerator.fromImageProvider(
    CachedNetworkImageProvider(f ?? ""),
    maximumColorCount: 20,
  );
  return paletteGenerator!.darkMutedColor!.color;
});

class BgColor extends ConsumerWidget {
  const BgColor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(bgProvider);
    final ff = Container(
      color: _kBackgroundColor,
    );
    return p.when(
      data: (data) {
        return Container(
          color: data,
        );
      },
      error: (error, stackTrace) => ff,
      loading: () => ff,
    );
  }
}
