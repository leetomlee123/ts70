import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:sp_util/sp_util.dart';
import 'package:ts70/firebase_options.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/request.dart';

/// 全局配置
class Global {
  /// 用户配置

  /// 是否第一次打开
  static bool isFirstOpen = false;

  /// 是否离线登录
  static bool isOfflineLogin = false;

  /// 是否 release

  /// init
  static Future init() async {
    // 运行初始
    // if (Platform.isIOS || Platform.isAndroid) {
    //   if (!await Permission.storage.request().isGranted) {
    //     return;
    //   }
    // }
    // Ruquest 模块初始化
    // PowerImageBinding();

    // ///添加全局power_image的加载方式
    // PowerImageLoader.instance.setup(PowerImageSetupOptions(renderingTypeTexture,
    //     errorCallbackSamplingRate: null,
    //     errorCallback: (PowerImageLoadException exception) {}));
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    ListenApi().checkSite("sk");
    Request();
    // 本地存储初始化
    await SpUtil.getInstance();
    await DataBaseProvider.dbProvider.voices();
    //init audioservice
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
    if (Platform.isAndroid) {
      SystemUiOverlayStyle style = const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light);
      SystemChrome.setSystemUIOverlayStyle(style);
    }
  }
}
