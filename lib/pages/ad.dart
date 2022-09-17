// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// // ca-app-pub-6006602100377888~2117864747
// // ca-app-pub-6006602100377888/1902242327
// final BannerAd myBanner = BannerAd(
//   adUnitId: 'ca-app-pub-6006602100377888/1902242327',
//   size: AdSize.fluid,
//   request: const AdRequest(),
//   listener: const BannerAdListener(),
// );

// final p = FutureProvider.autoDispose((ref) {
//   myBanner.load();
//   ref.onDispose(() {
//     myBanner.dispose();
//   });
// });

// class Ad extends ConsumerWidget {
//   const Ad({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final s = ref.watch(p);
//     return s.when(
//         data: (data) {
//           final AdWidget adWidget = AdWidget(ad: myBanner);
//           final Container adContainer = Container(
//             alignment: Alignment.center,
//             // color: Colors.red,
//             // width: myBanner.size.width.toDouble(),
//             // height: myBanner.size.height.toDouble(),
//             child: adWidget,
//           );
//           return adContainer;
//         },
//         error: (e, v) => const Center(
//               child: Text('Ops...',style: TextStyle(color: Colors.white)),
//             ),
//         loading: () => const Center(
//               child: Text('loading...',style: TextStyle(color: Colors.white),),
//             ));
//   }
// }
