import 'dart:async';

import 'package:flutter/material.dart';
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
    WidgetsFlutterBinding.ensureInitialized();
  }
}
