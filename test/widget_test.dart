// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For china, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  final text = """
    function importSublink(client) {
      if (client == 'quantumult') {
        oneclickImport('quantumult', '');
      }
      if (client == 'quantumultx') {
        oneclickImport('quantumultx', 'https://api.jsm.one/link/twgexw2prGYmvyDD?list=quantumultx');
      }
      if (client == 'shadowrocket') {
        oneclickImport('shadowrocket','https://api.jsm.one/link/twgexw2prGYmvyDD?list=shadowrocket')
      };
      if (client == 'surfboard') {
        oneclickImport('surfboard','https://api.jsm.one/link/twgexw2prGYmvyDD?surfboard=1')
      };
      if (client == 'surge2') {
        oneclickImport('surge','https://api.jsm.one/link/twgexw2prGYmvyDD?surge=2')
      };
      if (client == 'surge3') {
        oneclickImport('surge3','https://api.jsm.one/link/twgexw2prGYmvyDD?surge=3')
      };
      if (client == 'surge4') {
        oneclickImport('surge3','https://api.jsm.one/link/twgexw2prGYmvyDD?surge=4')
      };
      if (client == 'clash') {
        oneclickImport('clash','https://api.jsm.one/link/twgexw2prGYmvyDD?clash=1')
      };
      if (client == 'ssr') {
        oneclickImport('ssr','https://api.jsm.one/link/twgexw2prGYmvyDD?sub=1')
      }
    }

    appName = "加速猫";

    setTimeout(loadTrafficChart(), 3000);
  
""";

  final reg = RegExp(r"oneclickImport(.*)");

  final s = reg.stringMatch(text);
  final ss = reg.allMatches(text);

  ss.forEach(
    (element) {
      final result = element.group(0);
      print(result);
    },
  );

  print(s);
}
