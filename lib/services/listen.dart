import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/utils/request.dart';

var streamController = StreamController.broadcast();

class ListenApi {
  //  String host = "https://m.70ts.cc";
  String host = "https://www.70tsw.com";
  String host2 = "https://www.70ts.cc";

  void checkSite() async {
    Response res = await Request().getBase(host);

    streamController.add(res.statusCode);
    var data = res.data;
    Document document = parse(data);
    Node e = document.querySelectorAll(".list-ul").first;
    var list = e.children.map((e) {
      final c =
          e.querySelector("a>img")!.attributes['data-original'].toString();
      return Search(
          id: e
              .querySelector("a")!
              .attributes['href']
              .toString()
              .split("/")[2]
              .split(".")[0],
          cover: c.startsWith("http") ? c : host + c,
          title: e.querySelector("a>figcaption")!.text.toString());
    }).toList();
    streamController.add(list);
  }

  Future<List<TopRank>?> getTop(String rank) async {
    var res = await Request().getBase(host);
    Document document = parse(res);
    List<Element> es = document.querySelector(".top-ul")!.children;
    return es.map((element) {
      final v1 = element.querySelector("h4>a");
      final v2 = element.querySelector("p")!.children;
      return TopRank(
          id: v1!.attributes['href'],
          name: v1.text,
          a: v2[0].querySelector("a")!.text,
          b: v2[1].querySelector("a")!.text);
    }).toList();
  }

  Future<List<Search>?> search(String keyword, CancelToken cancelToken) async {
    if (keyword.isEmpty) return const [];
    var res = await Request().postForm1("$host/novelsearch/search/result.html",
        params:
            "searchword=${Uri.encodeQueryComponent(keyword)}&searchtype=novelname",
        cancelToken: cancelToken);
    // final params = {"searchtype": "novelname", "searchword": keyword};
    // var res = await Request().postForm("$host/novelsearch/search/result.html",
    //     params: params, cancelToken: cancelToken);
    Document document = parse(res);

    List<Element> es = document.querySelector(".list-works")!.children;
    var result = es.map((e) {
      final cover =
          e.querySelector("div>a>img")!.attributes['data-original'].toString();
      final id = e
          .querySelector("div>a")!
          .attributes['href']
          .toString()
          .split("/")[2]
          .split(".")[0];
      final title = e.querySelector("dl>dt>a")!.text.toString();
      final desc = e.querySelector('dl>dd.list-book-des')!.text.trim();
      final bookMeta =
          "${e.querySelector("dl>dd.list-book-cs>span:nth-child(1)")!.text}/${e.querySelector("dl>dd.list-book-cs>span:nth-child(3)")!.text}";
      return Search(
        id: id,
        cover: cover.startsWith("http") ? cover : host + cover,
        title: title,
        desc: desc,
        bookMeta: bookMeta,
      );
    }).toList();
    return result;
  }

  Future<List<Chapter>?> getChapters(String page, String id) async {
    var link =
        "$host/tingshu/$id/${int.parse(page) == 1 ? "" : '/p$page.html'}";
    var res = await Request().get(link);
    Document document = parse(res);
    List<Element> list = document.querySelector("#playlist>ul")!.children;
    var result = list.map((e) {
      String s = e.text;
      String ss = e.querySelector("span")!.text;
      return Chapter(name: s.replaceAll(ss, "").replaceAll("\n", "").trim());
    }).toList();
    return result;
  }

  Future<List<Chapter>?> getOptions(Search? search) async {
    var link = "$host/tingshu/${search!.id}";
    var res = await Request().get(link);
    Document document = parse(res);
    List<Element> list = document.querySelectorAll("select")[1].children;
    int len = list.length;
    List<Chapter>? result = [];
    for (int i = 0; i < len; i++) {
      Element e = list[i];
      result.add(Chapter(name: e.text, index: (i + 1).toString()));
    }
    return result;
  }

  Future<String> chapterUrl(Search? search) async {
    try {
      int idx = search!.idx ?? 0;
      int page = (idx ~/ 30) + 1;
      var link = "$host/tingshu/${search.id}${page == 1 ? "" : '/p$page.html'}";
      var res = await Request().get(link);
      Document document = parse(res);
      List<Element> list = document.querySelector("#playlist>ul")!.children;
      int index = idx % 30;
      String chapterUrl =
          host + list[index].querySelector("a")!.attributes['href']!;
      res = await Request().get(chapterUrl);
      document = parse(res);
      chapterUrl = host + document.querySelector("iframe")!.attributes['src']!;
      res = await Request().get(chapterUrl);
      document = parse(res);
      Element e = document.querySelectorAll('script').last;
      // print(e.text);
      List<String> split = e.text.split('\n');
      var split4 = split[7];
      var split5 = split[8];

      var split7 = split4.split("=");
      var split8 = split5.split("=");
      var s = e.text
          .substring(e.text.indexOf("mp3:") + 4, e.text.indexOf("}).jPlayer"));
      s = s.replaceAll("+", "");
      s = s.replaceAll(
          split7[0].trim(), split4.substring(split4.indexOf("=") + 1));
      s = s.replaceAll(
          split8[0].trim(), split5.substring(split5.indexOf("=") + 1));
      s = s.replaceAll(
          split7[0].trim(), split4.substring(split4.indexOf("=") + 1));
      link = s
          .replaceAll("'", "")
          .replaceAll("+", "")
          .replaceAll(";", "")
          .replaceAll(" ", "")
          .trim();
      if (kDebugMode) {
        print("link: $link");
      }
      return link;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return "";
  }
}
