import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:ts70/pages/index.dart';



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
          Theme.of(context).copyWith(primaryColor: data.lightMutedColor?.color??Colors.black);
          return Container(
            decoration:  BoxDecoration(
              color: data.darkMutedColor?.color??Colors.black
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     data.darkVibrantColor!.color,
              //     data.dominantColor!.color,
              //     data.darkMutedColor!.color,
              //   ],
              //   // ),
              // ),
            ),
          );
        },
        loading: () => defaultBgWidget,
        error: (Object error, StackTrace? stackTrace) => defaultBgWidget);
  }
}
