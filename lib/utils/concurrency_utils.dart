import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ConcurrencyUtils {
  // Process tasks in batches with concurrency limit
  static Future<List<T>> processInBatches<T>({
    required List<Future<T> Function()> tasks,
    int maxConcurrent = 5,
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = <T>[];
    final completer = Completer<List<T>>();
    var running = 0;
    var index = 0;
    var completed = 0;
    final total = tasks.length;

    void startNext() {
      if (index >= tasks.length) {
        if (running == 0) {
          completer.complete(results);
        }
        return;
      }

      running++;
      final task = tasks[index++];
      task().then((result) {
        results.add(result);
        running--;
        completed++;
        onProgress?.call(completed, total);
        startNext();
      }).catchError((error) {
        debugPrint('Task error: $error');
        running--;
        completed++;
        onProgress?.call(completed, total);
        startNext();
      });
    }

    // Start initial batch of tasks
    for (var i = 0; i < maxConcurrent && i < tasks.length; i++) {
      startNext();
    }

    return completer.future;
  }

  /// Process large data in an independent isolate
  static Future<T> computeIsolate<T, P>(
    FutureOr<T> Function(P message) callback,
    P message,
  ) async {
    // Get RootIsolateToken
    final rootToken = ui.RootIsolateToken.instance!;

    if (message is Map) {
      (message as Map<String, dynamic>)['rootToken'] = rootToken;
    }

    return compute((P msg) async {
      if (msg is Map) {
        final token =
            (msg as Map<String, dynamic>)['rootToken'] as ui.RootIsolateToken;
        BackgroundIsolateBinaryMessenger.ensureInitialized(token);
      }
      return await callback(msg);
    }, message);
  }
}
