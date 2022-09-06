// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:ts70/utils/request.dart';

Future<void> main() async {
  // String host = "https://m.70ts.cc";
  // var link = "$host/tingshu/777";
  // var res = await Request().get(link);
  // Document document = parse(res);
  // List<Element> list = document.querySelector("#playlist>ul")!.children;
  // int index = 1;
  // String chapterUrl =
  //     host + list[index].querySelector("a")!.attributes['href']!;
  // res = await Request().get(chapterUrl);
  // document = parse(res);
  // chapterUrl = host + document.querySelector("iframe")!.attributes['src']!;
  // res = await Request().get(chapterUrl);
  // document = parse(res);
  // Element e = document.querySelectorAll('script').last;
  // // print(e.text);
  // List<String> split = e.text.split('\n');
  // var split4 = split[7];
  // var split5 = split[8];

  // var split7 = split4.split("=");
  // var split8 = split5.split("=");
  // var s = e.text
  //     .substring(e.text.indexOf("mp3:") + 4, e.text.indexOf("}).jPlayer"));
  // s = s.replaceAll("+", "");
  // s = s.replaceAll(split7[0].trim(), split4.substring(split4.indexOf("=") + 1));
  // s = s.replaceAll(split8[0].trim(), split5.substring(split5.indexOf("=") + 1));
  // s = s.replaceAll(split7[0].trim(), split4.substring(split4.indexOf("=") + 1));
  // link = s
  //     .replaceAll("'", "")
  //     .replaceAll("+", "")
  //     .replaceAll(";", "")
  //     .replaceAll(" ", "")
  //     .trim();
  // print(link);

  print(1 % 30);
}
