import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/utils/request.dart';

class ListenApi {
  static String host = "https://m.70ts.cc";

  Future<int?> checkSite(String sk) async {
    var res = await Request().getBase(host);
    return res;
  }

  Future<List<Search>?> search(String keyword, CancelToken cancelToken) async {
    if (keyword.isEmpty) return const [];
    var res = await Request().postForm1("$host/novelsearch/search/result.html",
        params: "searchword=${Uri.encodeQueryComponent(keyword)}",
        cancelToken: cancelToken);
    Document document = parse(res);

    List<Element> es = document.querySelectorAll(".book-li");
    var result = es.map((e) {
      final c = e
          .getElementsByClassName("book-cover")[0]
          .attributes['data-original']
          .toString();
      final metas = e.querySelectorAll('.book-meta>a');
      return Search(
        id: e
            .querySelector("a")!
            .attributes['href']
            .toString()
            .split("/")[2]
            .split(".")[0],
        cover: c.startsWith("http") ? c : host + c,
        title: e.querySelector(".book-title>a")!.text.toString(),
        desc: e.getElementsByClassName('book-desc')[0].text.trim(),
        bookMeta: "${metas[0].text}/${metas[1].text}",
      );
    }).toList();
    return result;
  }

  Future<List<Chapter>?> getChapters(String page, String id) async {
    var link = "$host/tingshu/$id/${int.parse(page)==1?"":'/p$page.html'}";
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
    List<Element> list = document.querySelectorAll("select")[0].children;

    int len = list.length;
    List<Chapter>? result = [];
    for (int i = 0; i < len; i++) {
      Element e = list[i];
      result.add(Chapter(name: e.text, index: (i + 1).toString()));
    }
    return result;
  }

  Future<String> chapterUrl(Search? search) async {
    print(search);
    int idx = search!.idx ?? 0;
    int page = (idx ~/ 30) + 1;
    var link = "$host/tingshu/${search.id}${page==1?"":'/p$page.html'}";
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
  }
}
