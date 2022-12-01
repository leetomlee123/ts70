// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For china, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
var s='{"url":"http:\/\/t3344t.tingchina.com\/yousheng\/\u7384\u5e7b\u5947\u5e7b\/\u4e07\u53e4\u795e\u5e1d\/0001.mp3?key=714a82ef7a048ec3fb0158857b1c2f00_694472778"}';
var jsonDecode2 = jsonDecode(s);


print(jsonDecode(s)['url']);
  // var list=[[11,22,33,44,55],["aa","bb","cc","dd"],["a1","b2","c3","d4","x1"]];
  // var temp=[];
  //
  // int length = list.length;
  //
  // bool loop = true;
  // int j = 0;
  // while (loop) {
  //   int len=temp.length;
  //   bool flag=true;
  //   for (int i = length - 1; i >= 0; i--) {
  //     var temp2 = list[i];
  //     var length = temp2.length;
  //     if(length>j){
  //       temp.add(temp2[j]);
  //       flag=false;
  //     }
  //   }
  //   j++;
  //   if(flag&&len==temp.length){
  //     break;
  //   }
  // }
  //
  // for (var value in temp) {
  //   print(value);
  // }

}
