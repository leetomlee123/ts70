import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/services/listen.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Text('一个神奇的网站'),
        centerTitle: true,
      ),
      body: Center(
          child: TextButton(
        onPressed: () {
          ListenApi().register();
        },
        child: const Text('GET IMAGE LINK'),
      )),
    );
  }
}
