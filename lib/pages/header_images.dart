// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ts70/pages/model.dart';
// import 'package:ts70/services/listen.dart';

// final headers = StateProvider<List<Search>?>((ref) => const []);

// class HeaderImages extends ConsumerWidget {
//   const HeaderImages({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final p = ref.watch(headers.state);
//     streamController.stream.listen((event) {
//       if (event is List) {
//         p.state = event as List<Search>?;
//         streamController.close();
//       }
//     });
//     // final List<Widget> imageSliders = p.state!
//     //     .map((item) => Container(
//     //           width: MediaQuery.of(context).size.width,
//     //           margin: const EdgeInsets.all(5.0),
//     //           child: ClipRRect(
//     //               borderRadius: const BorderRadius.all(Radius.circular(5.0)),
//     //               child: Container(decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(item.cover??""))),child: Column(children: [
//     //                 Container(
//     //                         decoration: const BoxDecoration(
//     //                           gradient: LinearGradient(
//     //                             colors: [
//     //                               Color.fromARGB(200, 0, 0, 0),
//     //                               Color.fromARGB(0, 0, 0, 0)
//     //                             ],
//     //                             begin: Alignment.bottomCenter,
//     //                             end: Alignment.topCenter,
//     //                           ),
//     //                         ),
//     //                         padding: const EdgeInsets.symmetric(
//     //                             vertical: 10.0, horizontal: 20.0),
//     //                         child: Text(
//     //                           item.title ?? "",
//     //                           style: const TextStyle(
//     //                             color: Colors.white,
//     //                             fontSize: 16.0,
//     //                             fontWeight: FontWeight.bold,
//     //                           ),
//     //                         ),
//     //                       )
//     //               ],),),
//     //               // child: Stack(
//     //               //   fit: StackFit.expand,
//     //               //   children: <Widget>[
//     //               //     // Image(, fit: BoxFit.cover, width: 120.0),
//     //               //     Image(
//     //               //         image: CachedNetworkImageProvider(item.cover ?? ""),
//     //               //         fit: BoxFit.fill,
//     //               //        ),
//     //               //     Positioned(
//     //               //       bottom: 0.0,
//     //               //       left: 0.0,
//     //               //       right: 0.0,
//     //               //       child: Container(
//     //               //         decoration: const BoxDecoration(
//     //               //           gradient: LinearGradient(
//     //               //             colors: [
//     //               //               Color.fromARGB(200, 0, 0, 0),
//     //               //               Color.fromARGB(0, 0, 0, 0)
//     //               //             ],
//     //               //             begin: Alignment.bottomCenter,
//     //               //             end: Alignment.topCenter,
//     //               //           ),
//     //               //         ),
//     //               //         padding: const EdgeInsets.symmetric(
//     //               //             vertical: 10.0, horizontal: 20.0),
//     //               //         child: Text(
//     //               //           item.title ?? "",
//     //               //           style: const TextStyle(
//     //               //             color: Colors.white,
//     //               //             fontSize: 20.0,
//     //               //             fontWeight: FontWeight.bold,
//     //               //           ),
//     //               //         ),
//     //               //       ),
//     //               //     ),
//     //               //   ],
//     //               // )
//     //           ),
//     //         ))
//     //     .toList();

//     // return ListView.builder(itemBuilder: (context,index){
//     //   final e=p.state![index];
//     //   return Stack(
//     //     children: [
//     //       Image(image: CachedNetworkImageProvider(e.cover ?? "")),
//     //       Align(
//     //         alignment: Alignment.bottomCenter,
//     //         child: Text(e.title ?? ""),
//     //       ),
//     //     ],
//     //   );
//     // },);
//     return GridView.count(
//       shrinkWrap: true,
//       //?????????Widget????????????
//       crossAxisSpacing: 10.0,
//       //?????????Widget????????????
//       mainAxisSpacing: 30.0,
//       //GridView?????????
//       padding: const EdgeInsets.all(10.0),
//       //?????????Widget??????
//       crossAxisCount: 3,
//       //???Widget????????????
//       childAspectRatio: 1.5,
//       //???Widget??????
//       children: p.state!.map((e) {
//         return ClipRRect(
//           borderRadius: const BorderRadius.all(Radius.circular(5.0)),
//           child: Stack(
//             fit: StackFit.passthrough,
//             children: [
//               Image(
//                 image: CachedNetworkImageProvider(e.cover ?? ""),
//                 fit: BoxFit.cover,
//               ),
//               Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       // color: Colors.white
//                       // gradient: LinearGradient(
//                       //   colors: [
//                       //     Color.fromARGB(200, 0, 0, 0),
//                       //     Color.fromARGB(0, 0, 0, 0)
//                       //   ],
//                       //   begin: Alignment.bottomLeft,
//                       //   end: Alignment.bottomRight,
//                       // ),
//                     ),
//                     child: Text(
//                       e.title ?? "",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14.0,
//                         // fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   )),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
