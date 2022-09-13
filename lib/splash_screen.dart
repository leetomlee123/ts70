import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:ts70/global.dart';
import 'package:ts70/pages/home.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Lottie.asset('assets/lottie.json',
            height: MediaQuery.of(context).size.height * 1,
            animate: true, onLoaded: (_) {
      Global.init().then((value) {
        print("进入第一页");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      });
    }));
    // TODO: implement build
    throw UnimplementedError();
  }
}
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Lottie.asset('assets/lottie.json',
//             height: MediaQuery.of(context).size.height * 1,
//             animate: true, onLoaded: (_) {
//       Global.init().then((value) {
//         print("进入第一页");
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const Home()),
//         );
//       });
//     }));
//   }
// }
