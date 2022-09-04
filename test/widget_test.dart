// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ts70/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    var split4 = "murl5204604393 = '.mp3';";
    var split5 ="url5204604393 = ''";

    var split7 = split4.split("=");
    var split8 = split5.split("=");
    var s ="'http://musica.its1.net/jueshijianshen/4652bdf70f0bd7bb45e12a66c81aa05f'+murl5204604393+'?key=d6b1b46d206043e2b7039874577774d6_1662293803'";
    s = s.replaceAll("+", "");
    s = s.replaceAll(
        split7[0].trim(), split4.substring(split4.indexOf("=") + 1));
    s = s.replaceAll(
        split8[0].trim(), split5.substring(split5.indexOf("=") + 1));

    String link = s
        .replaceAll("'", "")
        .replaceAll("+", "")
        .replaceAll(";", "")
        .replaceAll(" ", "")
        .trim();
    print(link);
  });
}
