import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/listen.dart';
import 'package:ts70/utils/database_provider.dart';
import 'package:ts70/utils/request.dart';

import 'firebase_options.dart';

/// 全局配置
class Global {
  /// 用户配置
  /// 是否第一次打开
  static bool isFirstOpen = false;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static List<Search> history = [];

  /// 是否离线登录
  static bool isOfflineLogin = false;

  /// 是否 release

  /// init
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (kDebugMode) {
      print("app init env ");
    }

    ListenApi().checkSite();
    Request();
    // UpdateApp.initXUpdate();
    // 本地存储初始化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    history = await DataBaseProvider.dbProvider.voices();
    await FlutterDisplayMode.setHighRefreshRate();
    // await DataBaseProvider.dbProvider.voices();
    // PostGreSqlProvider.dbProvider.databaseVoice;
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
    if (kDebugMode) {
      print("init env done");
    }
  }
}
