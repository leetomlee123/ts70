import 'package:flutter/cupertino.dart';
import 'package:ts70/model/model.dart';

class PlayManage extends ChangeNotifier {
  bool play = false;
  List<Search>? list;

  PlayManage({this.list = const []});

  void toggle() {
    play = play ? false : true;
    notifyListeners();
  }
}
