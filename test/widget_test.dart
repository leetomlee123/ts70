// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/utils/request.dart';

Future<void> main() async {
String host = "https://m.70ts.cc";
    var link = "$host/tingshu/777/p1.html";
    var res = await Request().get(link);
    Document document = parse(res);
    var list = document.querySelectorAll("select")[0].children;

    int len = list.length;
    List<Chapter>? result = [];
    for (int i = 0; i < len; i++) {
      var e = list[i];
      
      
      // result.add(Chapter(name: e.text, index: i.toString()));
      print(e.text);
    }
}
