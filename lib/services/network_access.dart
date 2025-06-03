import 'dart:async';
import 'dart:io';

Future<bool> checkConnectivity({
  Duration timeout = const Duration(seconds: 1),
}) {
  final completer = Completer<bool>();

  Timer(timeout, () {
    if (!completer.isCompleted) {
      completer.complete(false);
    }
  });

  InternetAddress.lookup('example.com')
      .then((result) {
        if (!completer.isCompleted) {
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        }
      })
      .catchError((error) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

  return completer.future;
}
