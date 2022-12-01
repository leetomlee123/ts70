import 'package:flutter/material.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/services/services.dart';

class SearchNotifier extends ChangeNotifier {
  var result = <Search>[];
  var temp = <List<Search>>[];

  SearchNotifier() {
    searchController.stream.listen((event) {
      add(event);
    });
  }

  void search(String keyword) {
    result.clear();
    temp.clear();
    notifyListeners();
    ListenApi().search(keyword);
  }

  void add(var data) {
    temp.add(data);
    formatData();
    notifyListeners();
  }

  formatData() {
    result=[];
    int length = temp.length;
    bool loop = true;
    int j = 0;
    while (loop) {
      int len = result.length;
      bool flag = true;
      for (int i = length - 1; i >= 0; i--) {
        var temp2 = temp[i];
        var length = temp2.length;
        if (length > j) {
          result.add(temp2[j]);
          flag = false;
        }
      }
      j++;
      if (flag && len == result.length) {
        break;
      }
    }
  }

  void clear() {
    result.clear();
    notifyListeners();
  }
}
