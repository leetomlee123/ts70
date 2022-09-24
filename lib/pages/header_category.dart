import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/utils/screen.dart';

class HeaderCategory extends ConsumerWidget {
  const HeaderCategory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        height: 200,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        width: Screen.width,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.black),child: Row(children: [
Column(children: const [Icon(Icons.category),Text('分类')],),
Column(children: const [Image(image: CachedNetworkImageProvider("")),Text('排行')],),
Column(children: const [Image(image: CachedNetworkImageProvider("")),Text('完本')],),
Column(children: const [Image(image: CachedNetworkImageProvider("")),Text('新书')],),


    ],),);
  }



}
