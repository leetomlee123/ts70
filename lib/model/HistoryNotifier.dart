import 'package:flutter/material.dart';
import 'package:ts70/pages/model.dart';
import 'package:ts70/utils/database_provider.dart';

class HistoryNotifier extends ChangeNotifier {
  var todos = <Search>[];
  HistoryNotifier() {
    DataBaseProvider.dbProvider.voices().then((value) {
      todos = value;
    });
  }

  // Let's allow the UI to add todos.
  void addTodo(Search todo) {
    todos.add(todo);
    notifyListeners();
  }

  // Let's allow removing todos
  void removeTodo(String? todoId) {
    todos.remove(todos.firstWhere((element) => element.id == todoId));
    notifyListeners();
  }
}
