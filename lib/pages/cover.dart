import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ts70/pages/index.dart';
import 'package:ts70/utils/screen.dart';

final width = Screen.width * .23;
final width1 = Screen.width * .9;
final height1 = width1*.8;

class Cover extends ConsumerWidget {
  const Cover({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = ref.watch(playProvider.select((value) => value!.cover));
    return CachedNetworkImage(
      imageUrl: cover!,
      width: width1,
      height: height1,
      fit: BoxFit.fitWidth,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(cover ?? ""),
          radius: width,
        ),
        Image.asset(
          'assets/disk.png',
          width: width1,
        ),
      ],
    );
  }
}

// class Cover extends StatefulWidget {
//   const Cover({super.key});

//   @override
//   State<StatefulWidget> createState() {
//     return CoverState();
//   }
// }

// class CoverState extends State with TickerProviderStateMixin {
//  /// 重复播放前需要停顿一下的控制器
//   late final AnimationController _delayRepeatController;

//   /// 延时重复播放动画
//   late final Animation<double> _delayAnimation;

//   @override
//   void initState() {
//    _delayRepeatController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )
//     //  添加动画监听
//       ..addListener(() {
//         // 获取动画当前的状态
//         var status = _delayRepeatController.status;
//         if (status == AnimationStatus.completed) {
//           // 延时1秒
//           Future.delayed(const Duration(seconds: 1), () {
//             //从0开始向前播放
//             _delayRepeatController.forward(from: 0.0);
//           });
//         }
//       })
//       ..forward();

//     _delayAnimation =
//         Tween<double>(begin: 0, end: 1).animate(_delayRepeatController);
//     super.initState();


//   }

//   @override
//   Widget build(BuildContext context) {
//     return RotationTransition(
//         turns: _delayAnimation, child: const StoryCover());
//   }
// }

