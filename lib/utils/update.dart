// import 'dart:io';

// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_xupdate/flutter_xupdate.dart';

// class UpdateApp {
//   static String updateUrl =
//       "https://raw.githubusercontent.com/leetomlee123/minio/main/output-metadata.json";
//   static void enableChangeDownLoadType() {
//     FlutterXUpdate.checkUpdate(
//       url: updateUrl,
//       overrideGlobalRetryStrategy: true,
//       enableRetry: true,
//     );
//   }

//   ///初始化
//   static void initXUpdate() {
//     if (Platform.isAndroid) {
//       FlutterXUpdate.init(

//               ///是否输出日志
//               debug: true,

//               ///是否使用post请求
//               isPost: false,

//               ///post请求是否是上传json
//               isPostJson: false,

//               ///请求响应超时时间
//               timeout: 25000,

//               ///是否开启自动模式
//               isWifiOnly: false,

//               ///是否开启自动模式
//               isAutoMode: false,

//               ///需要设置的公共参数
//               supportSilentInstall: false,

//               ///在下载过程中，如果点击了取消的话，是否弹出切换下载方式的重试提示弹窗
//               enableRetry: false)
//           .then((value) {
//         //  updateMessage("初始化成功: $value");
//         if (kDebugMode) {
//           print("update app init success");
//         }
//         enableChangeDownLoadType();
//       }).catchError((error) {
//         if (kDebugMode) {
//           print(error);
//         }
//       });
//       // https://raw.githubusercontent.com/leetomlee123/minio/main/output-metadata.json
//       //  FlutterXUpdate.setErrorHandler(
//       //      onUpdateError: (Map<String, dynamic> message) async {
//       //    print(message);
//       //    setState(() {
//       //      _message = "$message";
//       //    });
//       //  });
//     } else {
//       BotToast.showText(text: "ios暂不支持XUpdate更新");
//     }
//   }
// }
