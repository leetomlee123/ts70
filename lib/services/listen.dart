import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/utils/request.dart';
import 'package:uuid/uuid.dart';

var streamController = StreamController.broadcast();

var uuid = const Uuid();

class ListenApi {


  Future<List<Chapter>?> imageLink() async {
    List<Chapter>? result = [];
    final key = uuid.v4().substring(10).replaceAll("-", "");
    final data = {
      "email": "$key@qq.com",
      "name": key,
      "passwd": key,
      "repasswd": key,
      "code": 0
    };
    await Request().postForm("https://jsmao.xyz/auth/register", params: data);
    await Request().postForm("https://jsmao.xyz/auth/login", params: data);
    final res3 = await Request().get("https://jsmao.xyz/user");
    Document document = parse(res3);
    final v2ray = document
        .getElementsByClassName('btn-v2ray')[0]
        .attributes['data-clipboard-text'];
    final reg = RegExp(r"oneclickImport(.*)");
    result.add(Chapter(name: "v2ray", index: v2ray));

    final ss = reg.allMatches(res3);

    for (var element in ss) {
      final r = element.group(0);
      final sss = r!.split("'");
      if (sss[3].isNotEmpty) {
        result.add(Chapter(name: sss[1], index: sss[3]));
      }
    }
    Request().clear();
    return result;
  }
}
