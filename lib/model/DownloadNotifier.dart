import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ts70/model/model.dart';
import 'package:ts70/services/services.dart';

class DownloadNotifier extends ChangeNotifier {
  var temp = .0;
  late StreamSubscription streamSubscription;

  DownloadNotifier() {
    streamSubscription = downloadController.stream.listen((event) {
      add(event);
    });
  }
  @override
  void dispose() {
    super.dispose();
    streamSubscription.pause();
  }

  void add(double p) {
    temp = p;
    notifyListeners();
  }
}
