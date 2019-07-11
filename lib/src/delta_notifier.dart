import 'package:flutter/foundation.dart';
import 'package:delta_notifier/src/delta_listenable.dart';

class DeltaNotifer<T> implements DeltaListenable<T> {
  ObserverList<DeltaHandler<T>> _listeners = ObserverList<DeltaHandler<T>>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  @override
  void addListener(DeltaHandler<T> listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  @override
  void removeListener(DeltaHandler<T> listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  @protected
  void notifyListeners(T delta) {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      final localListeners = List<DeltaHandler<T>>.from(_listeners);
      for (var listener in localListeners) {
        try {
          if (_listeners.contains(listener)) listener(delta);
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'foundation library',
            context: ErrorDescription(
                'while dispatching notifications for $runtimeType'),
            informationCollector: () sync* {
              yield DiagnosticsProperty<DeltaNotifer<T>>(
                'The $runtimeType sending notification was',
                this,
                style: DiagnosticsTreeStyle.errorProperty,
              );
            },
          ));
        }
      }
    }
  }
}